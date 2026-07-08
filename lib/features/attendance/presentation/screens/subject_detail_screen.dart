import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/attendance_log.dart';
import '../providers/attendance_providers.dart';
import '../../../bunk/domain/bunk_calculator.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  AttendanceStatus _selectedStatus = AttendanceStatus.present;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _manualLog() {
    HapticFeedback.lightImpact();
    final log = AttendanceLog(
      id: const Uuid().v4(),
      subjectId: widget.subjectId,
      dateTime: _selectedDate,
      status: _selectedStatus,
    );
    ref.read(attendanceLogsProvider.notifier).logAttendance(log);
    AppSnackBar.success(context, 'Attendance log added successfully');
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
            'Are you sure you want to delete ${subject.name}? All associated attendance logs will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(subjectsProvider.notifier).deleteSubject(subject.id);
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to attendance tab
              AppSnackBar.show(context, message: 'Subject deleted');
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  // Monthly trends parser
  List<BarChartGroupData> _buildTrendGroups(List<AttendanceLog> logs, ThemeData theme) {
    final Map<int, List<AttendanceLog>> logsByMonth = {};
    for (final log in logs) {
      if (log.status == AttendanceStatus.cancelled) continue;
      final month = log.dateTime.month;
      logsByMonth.putIfAbsent(month, () => []).add(log);
    }

    final List<BarChartGroupData> groups = [];
    final currentMonth = DateTime.now().month;

    for (int i = 4; i >= 0; i--) {
      var month = currentMonth - i;
      if (month <= 0) month += 12;

      final monthLogs = logsByMonth[month] ?? [];
      final present = monthLogs.where((l) => l.status == AttendanceStatus.present).length;
      final total = monthLogs.length;

      final double percentage = total == 0 ? 0.0 : (present / total) * 100.0;

      groups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: percentage,
              color: percentage >= 75.0 ? AppColors.success : AppColors.warning,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  String _getMonthName(int monthValue) {
    final date = DateTime(2026, monthValue);
    return DateFormat('MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);

    final subject = subjects.firstWhere(
      (s) => s.id == widget.subjectId,
      orElse: () => const Subject(
        id: '',
        name: 'Not Found',
        minAttendancePercent: 75.0,
        creditHours: 0,
        schedules: [],
      ),
    );

    if (subject.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Details')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Not Found',
          description: 'The requested subject could not be found.',
        ),
      );
    }

    final stats = ref.watch(subjectStatsProvider(subject));
    final double percent = stats['percentage'] as double;
    final int present = stats['present'] as int;
    final int total = stats['total'] as int;

    final bunkResult = BunkCalculator.calculate(
      present: present,
      total: total,
      requiredPercent: subject.minAttendancePercent,
    );

    final subjectLogs = ref.watch(attendanceLogsProvider)
        .where((log) => log.subjectId == subject.id)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first

    final statusColor = AppColors.attendanceStatus(percent, subject.minAttendancePercent);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () => _deleteSubject(subject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Card ──
            AppCard(
              border: BorderSide(color: statusColor.withValues(alpha: 0.3)),
              child: Row(
                children: [
                  ProgressRing(
                    percent: percent,
                    color: statusColor,
                    size: 80,
                    strokeWidth: 7,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip.attendance(percent, subject.minAttendancePercent),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$present attended · $total total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bunkResult.statusMessage,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: bunkResult.isSafe ? AppColors.success : AppColors.warning,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Manual Log Section ──
            const SectionHeader(title: 'Log Attendance'),
            AppCard(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<AttendanceStatus>(
                    segments: const [
                      ButtonSegment(
                        value: AttendanceStatus.present,
                        label: Text('Present'),
                        icon: Icon(Icons.check_circle_rounded),
                      ),
                      ButtonSegment(
                        value: AttendanceStatus.absent,
                        label: Text('Absent'),
                        icon: Icon(Icons.cancel_rounded),
                      ),
                      ButtonSegment(
                        value: AttendanceStatus.cancelled,
                        label: Text('Cancelled'),
                        icon: Icon(Icons.block_rounded),
                      ),
                    ],
                    selected: {_selectedStatus},
                    onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                      setState(() {
                        _selectedStatus = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _manualLog,
                      child: const Text('Save Log'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Monthly Trends Chart ──
            const SectionHeader(title: 'Monthly Trends'),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _getMonthName(value.toInt()),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value == 0 || value == 50 || value == 100) {
                              return Text(
                                '${value.toInt()}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildTrendGroups(subjectLogs, theme),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Recent Logs History ──
            const SectionHeader(title: 'History'),
            if (subjectLogs.isEmpty)
              const EmptyState(
                icon: Icons.history_rounded,
                title: 'No logs yet',
                description: 'Your attendance logs will appear here.',
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjectLogs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = subjectLogs[index];
                    final isPresent = log.status == AttendanceStatus.present;
                    final isAbsent = log.status == AttendanceStatus.absent;

                    Color logColor = theme.colorScheme.onSurfaceVariant;
                    IconData logIcon = Icons.block_rounded;
                    
                    if (isPresent) {
                      logColor = AppColors.success;
                      logIcon = Icons.check_circle_rounded;
                    } else if (isAbsent) {
                      logColor = AppColors.danger;
                      logIcon = Icons.cancel_rounded;
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: logColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(logIcon, color: logColor, size: 20),
                      ),
                      title: Text(
                        DateFormat('EEEE, d MMM yyyy').format(log.dateTime),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Logged at ${DateFormat('hh:mm a').format(log.dateTime)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () {
                          ref.read(attendanceLogsProvider.notifier).deleteLog(log.id);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
