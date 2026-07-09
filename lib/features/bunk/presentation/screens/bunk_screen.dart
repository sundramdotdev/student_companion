import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/bunk_calculator.dart';

class BunkScreen extends ConsumerStatefulWidget {
  const BunkScreen({super.key});

  @override
  ConsumerState<BunkScreen> createState() => _BunkScreenState();
}

class _BunkScreenState extends ConsumerState<BunkScreen> {
  final Map<String, bool> _simulatedBunkSubjects = {};
  int _classesToMiss = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    final minAttendance = ref.watch(minAttendanceProvider);

    // Initialize simulation state
    if (_simulatedBunkSubjects.isEmpty && subjects.isNotEmpty) {
      for (final subject in subjects) {
        _simulatedBunkSubjects[subject.id] = false;
      }
    }

    // Overall projections for whole day bunk
    int currentOverallPresent = 0;
    int currentOverallTotal = 0;
    int simulatedOverallPresent = 0;
    int simulatedOverallTotal = 0;

    for (final subject in subjects) {
      final stats = ref.read(subjectStatsProvider(subject));
      final present = stats['present'] as int;
      final total = stats['total'] as int;
      currentOverallPresent += present;
      currentOverallTotal += total;
      final shouldBunk = _simulatedBunkSubjects[subject.id] ?? false;
      simulatedOverallPresent += present;
      simulatedOverallTotal += total + (shouldBunk ? 1 : 0);
    }

    final double currentOverallPercent = currentOverallTotal == 0
        ? 100.0
        : (currentOverallPresent / currentOverallTotal) * 100;
    final double simulatedOverallPercent = simulatedOverallTotal == 0
        ? 100.0
        : (simulatedOverallPresent / simulatedOverallTotal) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Bunk Planner')),
      body: subjects.isEmpty
          ? EmptyState(
              icon: Icons.analytics_rounded,
              title: 'No subjects configured',
              description: 'Add subjects in the Attendance tab to start planning your bunks smartly.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Subject Eligibility ──
                  const SectionHeader(title: 'Bunk Eligibility'),
                  ...subjects.map((subject) {
                    final stats = ref.watch(subjectStatsProvider(subject));
                    final present = stats['present'] as int;
                    final total = stats['total'] as int;
                    final result = BunkCalculator.calculate(
                      present: present,
                      total: total,
                      requiredPercent: subject.minAttendancePercent,
                    );
                    final statusColor = result.isSafe ? AppColors.success : AppColors.danger;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
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
                                  const SizedBox(height: 4),
                                  Text(
                                    result.statusMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                Text(
                                  '${result.currentPercentage.toStringAsFixed(1)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                StatusChip(
                                  label: result.isSafe ? 'Safe' : 'Low',
                                  color: statusColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // ── Section 2: Whole-Day Bunk Simulator ──
                  const SectionHeader(title: 'Whole-Day Simulator'),
                  Text(
                    'Select classes to simulate bunking and see the projected impact.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        ...subjects.map((subject) {
                          return SwitchListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              subject.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: _simulatedBunkSubjects[subject.id] ?? false,
                            onChanged: (val) {
                              setState(() {
                                _simulatedBunkSubjects[subject.id] = val;
                              });
                            },
                          );
                        }),
                        const Divider(height: 24),
                        // Before → After comparison
                        Row(
                          children: [
                            Expanded(
                              child: _ComparisonMetric(
                                label: 'Current',
                                value: '${currentOverallPercent.toStringAsFixed(1)}%',
                                color: AppColors.attendanceStatus(currentOverallPercent, minAttendance),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: _ComparisonMetric(
                                label: 'Projected',
                                value: '${simulatedOverallPercent.toStringAsFixed(1)}%',
                                color: AppColors.attendanceStatus(simulatedOverallPercent, minAttendance),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section 3: Future Projection ──
                  const SectionHeader(title: 'Future Projection'),
                  AppCard(
                    child: Column(
                      children: [
                        // Scenario selector — stacked vertically to avoid overflow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simulation Scenario',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: _classesToMiss,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Miss 1 Class')),
                                DropdownMenuItem(value: 3, child: Text('Miss 3 Classes')),
                                DropdownMenuItem(value: 7, child: Text('Miss 1 Week')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _classesToMiss = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Projection results
                        ...subjects.map((subject) {
                          final stats = ref.read(subjectStatsProvider(subject));
                          final present = stats['present'] as int;
                          final total = stats['total'] as int;
                          final currentPercent = stats['percentage'] as double;
                          final int missCount = _classesToMiss == 7
                              ? subject.schedules.length
                              : _classesToMiss;
                          final double projectedPercent =
                              (total + missCount) == 0
                                  ? 100.0
                                  : (present / (total + missCount)) * 100.0;
                          final bool remainsSafe = projectedPercent >= subject.minAttendancePercent;
                          final statusColor = remainsSafe ? AppColors.success : AppColors.danger;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${currentPercent.toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${projectedPercent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Small metric display for before/after comparison.
class _ComparisonMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComparisonMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
