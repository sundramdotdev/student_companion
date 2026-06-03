import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
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
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _manualLog() {
    final log = AttendanceLog(
      id: const Uuid().v4(),
      subjectId: widget.subjectId,
      dateTime: _selectedDate,
      status: _selectedStatus,
    );
    ref.read(attendanceLogsProvider.notifier).logAttendance(log);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance log added manually.')),
    );
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}? All associated attendance logs will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(subjectsProvider.notifier).deleteSubject(subject.id);
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to attendance tab
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Monthly trends parser
  List<BarChartGroupData> _buildTrendGroups(List<AttendanceLog> logs, ThemeData theme) {
    // Group logs by month
    final Map<int, List<AttendanceLog>> logsByMonth = {};
    for (final log in logs) {
      if (log.status == AttendanceStatus.cancelled) continue;
      final month = log.dateTime.month;
      logsByMonth.putIfAbsent(month, () => []).add(log);
    }

    final List<BarChartGroupData> groups = [];
    final currentMonth = DateTime.now().month;

    // Show last 5 months
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
              color: percentage >= 75.0 ? theme.colorScheme.secondary : theme.colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
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
    
    // Find matching subject
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
        body: const Center(child: Text('Subject not found.')),
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
        .where((l) => l.subjectId == subject.id)
        .toList();
    subjectLogs.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final Color statusColor = bunkResult.isSafe ? theme.colorScheme.secondary : theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteSubject(subject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Info Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('CREDITS', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('${subject.creditHours}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('REQUIRED', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('${subject.minAttendancePercent.toStringAsFixed(0)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('ATTENDANCE', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('${percent.toStringAsFixed(1)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: statusColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bunk Calculator Status Card
            Card(
              color: statusColor.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      bunkResult.isSafe ? Icons.check_circle : Icons.warning,
                      color: statusColor,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bunkResult.isSafe ? 'Safe Zone' : 'Danger Zone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bunkResult.statusMessage,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Trend Chart Card
            if (subjectLogs.isNotEmpty) ...[
              Text(
                'Attendance Monthly Trend',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 25 == 0) {
                                      return Text('${value.toInt()}%', style: const TextStyle(fontSize: 8));
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(_getMonthName(value.toInt()), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: _buildTrendGroups(subjectLogs, theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Add Manual Attendance log
            Text(
              'Add Manual Log',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                            onPressed: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<AttendanceStatus>(
                            initialValue: _selectedStatus,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              border: OutlineInputBorder(),
                            ),
                            items: AttendanceStatus.values
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.name.toUpperCase()),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add Historical Log'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: _manualLog,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Class Timetable Slots list
            Text(
              'Timetable Schedule',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: subject.schedules.map((schedule) {
                    final startStr = '${schedule.startHour.toString().padLeft(2, '0')}:${schedule.startMinute.toString().padLeft(2, '0')}';
                    final endStr = '${schedule.endHour.toString().padLeft(2, '0')}:${schedule.endMinute.toString().padLeft(2, '0')}';
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.calendar_view_week),
                      title: Text(schedule.dayOfWeek),
                      trailing: Text('$startStr - $endStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Log History list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log History (${subjectLogs.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subjectLogs.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear History'),
                          content: const Text('Are you sure you want to clear all history for this subject? This action is permanent.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                for (final log in subjectLogs) {
                                  ref.read(attendanceLogsProvider.notifier).deleteLog(log.id);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (subjectLogs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No attendance has been logged yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjectLogs.length,
                itemBuilder: (context, index) {
                  final log = subjectLogs[index];
                  final dateStr = DateFormat('EEE, d MMM yyyy').format(log.dateTime);
                  
                  Color statusColor = Colors.grey;
                  if (log.status == AttendanceStatus.present) statusColor = theme.colorScheme.secondary;
                  if (log.status == AttendanceStatus.absent) statusColor = theme.colorScheme.error;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        child: Icon(
                          log.status == AttendanceStatus.present
                              ? Icons.check
                              : log.status == AttendanceStatus.absent
                                  ? Icons.close
                                  : Icons.block,
                          color: statusColor,
                        ),
                      ),
                      title: Text(dateStr),
                      subtitle: Text('Status: ${log.status.name.toUpperCase()}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {
                          ref.read(attendanceLogsProvider.notifier).deleteLog(log.id);
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
