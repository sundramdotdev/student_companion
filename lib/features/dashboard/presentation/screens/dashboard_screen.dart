import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
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

  void _quickLog(BuildContext context, WidgetRef ref, Subject subject, AttendanceStatus status) {
    final log = AttendanceLog(
      id: const Uuid().v4(),
      subjectId: subject.id,
      dateTime: DateTime.now(),
      status: status,
    );
    ref.read(attendanceLogsProvider.notifier).logAttendance(log);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${subject.name} as ${status.name.toUpperCase()}'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => ref.read(attendanceLogsProvider.notifier).deleteLog(log.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    final assessments = ref.watch(assessmentsProvider);
    final minAttendance = ref.watch(minAttendanceProvider);
    final cgpa = ref.watch(cgpaProvider);

    // 1. Today's Classes Calculation
    final todayWeekdayStr = _getWeekdayName(DateTime.now().weekday);
    final List<Map<String, dynamic>> todayClasses = [];

    for (final subject in subjects) {
      for (final schedule in subject.schedules) {
        if (schedule.dayOfWeek.toLowerCase() == todayWeekdayStr.toLowerCase()) {
          todayClasses.add({
            'subject': subject,
            'schedule': schedule,
          });
        }
      }
    }

    // Sort today's classes by start time
    todayClasses.sort((a, b) {
      final schedA = a['schedule'] as Schedule;
      final schedB = b['schedule'] as Schedule;
      final timeA = schedA.startHour * 60 + schedA.startMinute;
      final timeB = schedB.startHour * 60 + schedB.startMinute;
      return timeA.compareTo(timeB);
    });

    // 2. Attendance Summary & Risks
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

    final double overallPercent = totalClasses == 0 ? 100.0 : (totalPresent / totalClasses) * 100;

    // 3. Upcoming Deadlines
    final upcomingAssessments = assessments
        .where((a) => a.dueDate != null && a.dueDate!.isAfter(DateTime.now()))
        .toList();
    upcomingAssessments.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // 4. Overall Internals Marks Evaluated
    double totalEarnedWeighted = 0.0;
    double totalWeightageEvaluated = 0.0;

    for (final subject in subjects) {
      final stats = ref.watch(subjectInternalsStatsProvider(subject.id));
      totalEarnedWeighted += stats['earnedWeighted'] as double;
      totalWeightageEvaluated += stats['totalWeightage'] as double;
    }
    final double overallInternalsPercent = totalWeightageEvaluated == 0 ? 0.0 : (totalEarnedWeighted / totalWeightageEvaluated) * 100;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant Welcome Header
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                'Student Companion',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Statistics Grid (Attendance & GPA Snapshot)
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ATTENDANCE', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${overallPercent.toStringAsFixed(1)}%',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: overallPercent >= minAttendance ? theme.colorScheme.secondary : theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalPresent / $totalClasses Classes',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CGPA SNAPSHOT', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                cgpa.toStringAsFixed(2),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Scale: Standard', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Today's Classes Timetable
                Text('Today\'s Classes ($todayWeekdayStr)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (todayClasses.isEmpty)
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No classes scheduled for today. Rest up!')),
                    ),
                  )
                else
                  ...todayClasses.map((item) {
                    final subject = item['subject'] as Subject;
                    final schedule = item['schedule'] as Schedule;
                    final startStr = '${schedule.startHour.toString().padLeft(2, '0')}:${schedule.startMinute.toString().padLeft(2, '0')}';
                    final endStr = '${schedule.endHour.toString().padLeft(2, '0')}:${schedule.endMinute.toString().padLeft(2, '0')}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.school_outlined),
                        ),
                        title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$startStr - $endStr'),
                        trailing: PopupMenuButton<AttendanceStatus>(
                          icon: const Icon(Icons.check_circle_outline),
                          tooltip: 'Quick Log Attendance',
                          onSelected: (status) => _quickLog(context, ref, subject, status),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: AttendanceStatus.present, child: Text('Present')),
                            const PopupMenuItem(value: AttendanceStatus.absent, child: Text('Absent')),
                            const PopupMenuItem(value: AttendanceStatus.cancelled, child: Text('Cancelled')),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),

                // Attendance Risk warnings
                if (atRiskSubjects.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text('Attendance Danger Zone', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: atRiskSubjects.map((subject) {
                          final stats = ref.watch(subjectStatsProvider(subject));
                          final percent = stats['percentage'] as double;
                          return ListTile(
                            dense: true,
                            title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Current attendance is ${percent.toStringAsFixed(1)}% (Min req: ${subject.minAttendancePercent.toStringAsFixed(0)}%)'),
                            trailing: TextButton(
                              onPressed: () => context.push('/attendance/detail/${subject.id}'),
                              child: const Text('RECOVER'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Internal Marks Summary Box
                Text('Internal Assessment Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Overall Evaluated Marks Ratio:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${overallInternalsPercent.toStringAsFixed(1)}%',
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: overallInternalsPercent / 100.0,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on assessments evaluated across all courses. Total weight evaluated: ${totalWeightageEvaluated.toStringAsFixed(0)}%.',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upcoming Homework / Exam Deadlines
                Text('Upcoming Deadlines', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (upcomingAssessments.isEmpty)
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No upcoming deadlines. Good job!')),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingAssessments.length > 3 ? 3 : upcomingAssessments.length,
                    itemBuilder: (context, index) {
                      final item = upcomingAssessments[index];
                      final dateStr = DateFormat('EEE, d MMM').format(item.dueDate!);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.event_note, color: Colors.amber),
                          title: Text(item.type == 'Custom' ? item.name : item.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Due: $dateStr'),
                        ),
                      );
                    },
                  ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
