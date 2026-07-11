import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../attendance/domain/entities/subject.dart';
import '../../../attendance/domain/entities/schedule.dart';
import '../../../attendance/domain/entities/attendance_log.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../gpa/presentation/providers/gpa_providers.dart';
import '../../../internals/presentation/providers/internals_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _quickLog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
    AttendanceStatus status,
  ) {
    HapticFeedback.lightImpact();
    final log = AttendanceLog(
      id: const Uuid().v4(),
      subjectId: subject.id,
      dateTime: DateTime.now(),
      status: status,
    );
    ref.read(attendanceLogsProvider.notifier).logAttendance(log);
    AppSnackBar.show(
      context,
      message: 'Marked ${subject.name} as ${status.name}',
      icon: status == AttendanceStatus.present
          ? Icons.check_circle_rounded
          : status == AttendanceStatus.absent
              ? Icons.cancel_rounded
              : Icons.block_rounded,
      iconColor: status == AttendanceStatus.present
          ? AppColors.success
          : status == AttendanceStatus.absent
              ? AppColors.danger
              : null,
      actionLabel: 'UNDO',
      onAction: () => ref.read(attendanceLogsProvider.notifier).deleteLog(log.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    final assessments = ref.watch(assessmentsProvider);
    final minAttendance = ref.watch(minAttendanceProvider);
    final cgpa = ref.watch(cgpaProvider);

    // 1. Today's classes
    final todayWeekdayStr = _getWeekdayName(DateTime.now().weekday);
    final List<Map<String, dynamic>> todayClasses = [];

    for (final subject in subjects) {
      for (final schedule in subject.schedules) {
        if (schedule.dayOfWeek.toLowerCase() == todayWeekdayStr.toLowerCase()) {
          todayClasses.add({'subject': subject, 'schedule': schedule});
        }
      }
    }

    todayClasses.sort((a, b) {
      final schedA = a['schedule'] as Schedule;
      final schedB = b['schedule'] as Schedule;
      final timeA = schedA.startHour * 60 + schedA.startMinute;
      final timeB = schedB.startHour * 60 + schedB.startMinute;
      return timeA.compareTo(timeB);
    });

    // 2. Attendance summary & risks
    int totalPresent = 0;
    int totalClasses = 0;
    final List<Subject> atRiskSubjects = [];

    for (final subject in subjects) {
      final stats = ref.watch(subjectStatsProvider(subject));
      final double percent = stats['percentage'] as double;
      final present = stats['present'] as int;
      final total = stats['total'] as int;

      totalPresent += present;
      totalClasses += total;

      if (percent < subject.minAttendancePercent) {
        atRiskSubjects.add(subject);
      }
    }

    final double overallPercent = totalClasses == 0
        ? 100.0
        : (totalPresent / totalClasses) * 100;

    // 3. Upcoming deadlines
    final upcomingAssessments = assessments
        .where((a) => a.dueDate != null && a.dueDate!.isAfter(DateTime.now()))
        .toList();
    upcomingAssessments.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // 4. Internal marks
    double totalEarnedWeighted = 0.0;
    double totalWeightageEvaluated = 0.0;

    for (final subject in subjects) {
      final stats = ref.watch(subjectInternalsStatsProvider(subject.id));
      totalEarnedWeighted += stats['earnedWeighted'] as double;
      totalWeightageEvaluated += stats['totalWeightage'] as double;
    }
    final double overallInternalsPercent = totalWeightageEvaluated == 0
        ? 0.0
        : (totalEarnedWeighted / totalWeightageEvaluated) * 100;

    final attendanceColor = AppColors.attendanceStatus(overallPercent, minAttendance);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Greeting Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => context.push('/settings'),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Stat Cards Row ──
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Attendance',
                          value: '${overallPercent.toStringAsFixed(1)}%',
                          subtitle: '$totalPresent / $totalClasses classes',
                          icon: Icons.event_note_rounded,
                          valueColor: attendanceColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'CGPA',
                          value: cgpa.toStringAsFixed(2),
                          subtitle: 'Cumulative',
                          icon: Icons.school_rounded,
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Today's Classes ──
                  SectionHeader(
                    title: "Today's Classes",
                    trailing: Text(
                      todayWeekdayStr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (todayClasses.isEmpty)
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.coffee_rounded,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'No classes scheduled today',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...todayClasses.asMap().entries.map((entry) {
                      final item = entry.value;
                      final subject = item['subject'] as Subject;
                      final schedule = item['schedule'] as Schedule;
                      final startStr =
                          '${schedule.startHour.toString().padLeft(2, '0')}:${schedule.startMinute.toString().padLeft(2, '0')}';
                      final endStr =
                          '${schedule.endHour.toString().padLeft(2, '0')}:${schedule.endMinute.toString().padLeft(2, '0')}';

                      // Check if class is current
                      final now = DateTime.now();
                      final nowMinutes = now.hour * 60 + now.minute;
                      final startMinutes = schedule.startHour * 60 + schedule.startMinute;
                      final endMinutes = schedule.endHour * 60 + schedule.endMinute;
                      final isCurrent = nowMinutes >= startMinutes && nowMinutes < endMinutes;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          border: isCurrent
                              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                              : null,
                          child: Row(
                            children: [
                              // Time column
                              SizedBox(
                                width: 52,
                                child: Column(
                                  children: [
                                    Text(
                                      startStr,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      endStr,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Divider
                              Container(
                                width: 3,
                                height: 36,
                                margin: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Subject info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isCurrent)
                                      Text(
                                        'In progress',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Quick log
                              PopupMenuButton<AttendanceStatus>(
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                tooltip: 'Log Attendance',
                                onSelected: (status) =>
                                    _quickLog(context, ref, subject, status),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: AttendanceStatus.present,
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                        SizedBox(width: 8),
                                        Text('Present'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: AttendanceStatus.absent,
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel_rounded, color: AppColors.danger, size: 18),
                                        SizedBox(width: 8),
                                        Text('Absent'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: AttendanceStatus.cancelled,
                                    child: Row(
                                      children: [
                                        Icon(Icons.block_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Cancelled'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),

                  // ── Attendance Danger Zone ──
                  if (atRiskSubjects.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Attendance Alert',
                      trailing: StatusChip(
                        label: '${atRiskSubjects.length} at risk',
                        color: AppColors.danger,
                      ),
                    ),
                    AppCard(
                      border: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: atRiskSubjects.map((subject) {
                          final stats = ref.watch(subjectStatsProvider(subject));
                          final percent = stats['percentage'] as double;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.warning_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            title: Text(
                              subject.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${percent.toStringAsFixed(1)}% — needs ${subject.minAttendancePercent.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: TextButton(
                              onPressed: () => context.push(
                                '/attendance/detail/${subject.id}',
                              ),
                              child: const Text('Recover'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Internal Assessment ──
                  const SectionHeader(title: 'Internal Assessment'),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Evaluated',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${overallInternalsPercent.toStringAsFixed(1)}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overallInternalsPercent / 100.0,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weight evaluated: ${totalWeightageEvaluated.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Upcoming Deadlines ──
                  const SectionHeader(title: 'Upcoming Deadlines'),
                  if (upcomingAssessments.isEmpty)
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success.withValues(alpha: 0.5),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'No upcoming deadlines',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...upcomingAssessments
                        .take(3)
                        .map((item) {
                      final dateStr = DateFormat('EEE, d MMM').format(item.dueDate!);
                      final daysLeft = item.dueDate!.difference(DateTime.now()).inDays;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: AppColors.warning,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.type == 'Custom' ? item.name : item.type,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label: daysLeft == 0
                                    ? 'Today'
                                    : daysLeft == 1
                                        ? 'Tomorrow'
                                        : '$daysLeft days',
                                color: daysLeft <= 2 ? AppColors.danger : AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
