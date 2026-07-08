import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/attendance_log.dart';
import '../providers/attendance_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  void _quickLog(BuildContext context, WidgetRef ref, Subject subject, AttendanceStatus status) {
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
      message: '${status.name[0].toUpperCase()}${status.name.substring(1)} — ${subject.name}',
      icon: status == AttendanceStatus.present
          ? Icons.check_circle_rounded
          : status == AttendanceStatus.absent
              ? Icons.cancel_rounded
              : Icons.block_rounded,
      iconColor: status == AttendanceStatus.present ? AppColors.success : status == AttendanceStatus.absent ? AppColors.danger : null,
      actionLabel: 'UNDO',
      onAction: () => ref.read(attendanceLogsProvider.notifier).deleteLog(log.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    final double requiredThreshold = ref.watch(minAttendanceProvider);

    // Overall stats
    int totalPresent = 0;
    int totalClasses = 0;
    for (final subject in subjects) {
      final stats = ref.watch(subjectStatsProvider(subject));
      totalPresent += stats['present'] as int;
      totalClasses += stats['total'] as int;
    }
    final double overallPercent = totalClasses == 0 ? 100.0 : (totalPresent / totalClasses) * 100;
    final Color overallColor = AppColors.attendanceStatus(overallPercent, requiredThreshold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/attendance/timetable'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Overall Summary ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: AppCard(
                border: BorderSide(color: overallColor.withValues(alpha: 0.3)),
                child: Row(
                  children: [
                    ProgressRing(
                      percent: overallPercent,
                      color: overallColor,
                      size: 80,
                      strokeWidth: 7,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Attendance',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${overallPercent.toStringAsFixed(1)}%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: overallColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusChip.attendance(overallPercent, requiredThreshold),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$totalPresent attended · $totalClasses total · ${requiredThreshold.toStringAsFixed(0)}% required',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Empty / Subject List ──
          if (subjects.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.event_note_rounded,
                title: 'No subjects added yet',
                description: 'Set up your timetable to start tracking attendance across all your subjects.',
                actionLabel: 'Add Subject',
                onAction: () => context.push('/attendance/timetable'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = subjects[index];
                    final stats = ref.watch(subjectStatsProvider(subject));
                    final double percent = stats['percentage'] as double;
                    final int present = stats['present'] as int;
                    final int total = stats['total'] as int;
                    final int absent = stats['absent'] as int;
                    final Color statusColor = AppColors.attendanceStatus(percent, subject.minAttendancePercent);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => context.push('/attendance/detail/${subject.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (subject.facultyName != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subject.facultyName!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                StatusChip.attendance(percent, subject.minAttendancePercent),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (percent / 100.0).clamp(0.0, 1.0),
                                backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                                color: statusColor,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Stats row
                            Row(
                              children: [
                                Text(
                                  '${percent.toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$present present · $absent absent · $total total',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Quick log buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickLogButton(
                                    icon: Icons.check_rounded,
                                    label: 'Present',
                                    color: AppColors.success,
                                    onTap: () => _quickLog(context, ref, subject, AttendanceStatus.present),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickLogButton(
                                    icon: Icons.close_rounded,
                                    label: 'Absent',
                                    color: AppColors.danger,
                                    onTap: () => _quickLog(context, ref, subject, AttendanceStatus.absent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickLogButton(
                                    icon: Icons.remove_rounded,
                                    label: 'Cancel',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    onTap: () => _quickLog(context, ref, subject, AttendanceStatus.cancelled),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

/// Compact quick log button with icon + label.
class _QuickLogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
