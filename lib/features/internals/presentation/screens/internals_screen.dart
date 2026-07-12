import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../providers/internals_providers.dart';
import '../../../../core/widgets/widgets.dart';

class InternalsScreen extends ConsumerWidget {
  const InternalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Assessments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: subjects.isEmpty
          ? EmptyState(
              icon: Icons.assignment_rounded,
              title: 'No subjects configured',
              description: 'Add subjects under the Attendance tab to start tracking internal marks.',
              actionLabel: 'Add Subject',
              onAction: () => context.push('/attendance/timetable'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final stats = ref.watch(subjectInternalsStatsProvider(subject.id));

                final double earned = stats['earnedWeighted'] as double;
                final double totalWeightage = stats['totalWeightage'] as double;
                final double percent = stats['percentage'] as double;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push('/internals/subject/${subject.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                subject.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${percent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: totalWeightage == 0 ? 0.0 : earned / totalWeightage,
                            backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            color: theme.colorScheme.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Evaluated: ${earned.toStringAsFixed(1)} / ${totalWeightage.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Remaining: ${(100.0 - totalWeightage).toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
