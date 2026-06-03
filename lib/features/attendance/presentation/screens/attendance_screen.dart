import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/attendance_log.dart';
import '../providers/attendance_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  Color _getIndicatorColor(double percent, double requiredPercent, ThemeData theme) {
    if (percent >= requiredPercent) {
      return theme.colorScheme.secondary; // Green
    } else if (percent >= requiredPercent - 5.0) {
      return theme.colorScheme.tertiary; // Orange (danger zone)
    } else {
      return theme.colorScheme.error; // Red
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
        content: Text('Logged ${status.name.toUpperCase()} for ${subject.name}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(attendanceLogsProvider.notifier).deleteLog(log.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    

    // Calculate Overall Stats
    int totalPresent = 0;
    int totalClasses = 0;

    for (final subject in subjects) {
      final stats = ref.watch(subjectStatsProvider(subject));
      totalPresent += stats['present'] as int;
      totalClasses += stats['total'] as int;
    }

    final double overallPercent = totalClasses == 0 ? 100.0 : (totalPresent / totalClasses) * 100;
    final double requiredThreshold = ref.watch(minAttendanceProvider);
    final Color overallColor = _getIndicatorColor(overallPercent, requiredThreshold, theme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/attendance/timetable'),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: CustomScrollView(
        slivers: [
          // Overall Summary Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: overallColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: overallColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Overall Attendance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: overallColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${overallPercent.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: overallColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: overallPercent / 100.0,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: overallColor,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Required: ${requiredThreshold.toStringAsFixed(0)}%',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Attended: $totalPresent / $totalClasses classes',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (subjects.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No subjects added yet.',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add Subject" below to setup your timetable.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = subjects[index];
                    final stats = ref.watch(subjectStatsProvider(subject));
                    final double percent = stats['percentage'] as double;
                    final int present = stats['present'] as int;
                    final int total = stats['total'] as int;
                    final int absent = stats['absent'] as int;
                    
                    final Color indicatorColor = _getIndicatorColor(percent, subject.minAttendancePercent, theme);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push('/attendance/detail/${subject.id}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Subject Header & Percentage
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (subject.facultyName != null)
                                          Text(
                                            subject.facultyName!,
                                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: indicatorColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      '${percent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: indicatorColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percent / 100.0,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: indicatorColor,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Stats text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Present: $present | Absent: $absent | Total: $total',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Req: ${subject.minAttendancePercent.toStringAsFixed(0)}%',
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Quick action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Present'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: theme.colorScheme.secondary,
                                        side: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.4)),
                                      ),
                                      onPressed: () => _quickLog(context, ref, subject, AttendanceStatus.present),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Absent'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: theme.colorScheme.error,
                                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                                      ),
                                      onPressed: () => _quickLog(context, ref, subject, AttendanceStatus.absent),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.block, size: 16),
                                      label: const Text('Cancel'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        side: const BorderSide(color: Colors.grey),
                                      ),
                                      onPressed: () => _quickLog(context, ref, subject, AttendanceStatus.cancelled),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: subjects.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
