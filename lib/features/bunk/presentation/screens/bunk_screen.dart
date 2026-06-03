import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/bunk_calculator.dart';

class BunkScreen extends ConsumerStatefulWidget {
  const BunkScreen({super.key});

  @override
  ConsumerState<BunkScreen> createState() => _BunkScreenState();
}

class _BunkScreenState extends ConsumerState<BunkScreen> {
  // Whole Day Bunk Simulation state
  final Map<String, bool> _simulatedBunkSubjects = {};

  // Future Projection state
  int _classesToMiss = 1; // 1, 3, or weekly classes

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);
    final minAttendance = ref.watch(minAttendanceProvider);

    // Initializing state for simulated bunk subjects if empty
    if (_simulatedBunkSubjects.isEmpty && subjects.isNotEmpty) {
      for (final subject in subjects) {
        _simulatedBunkSubjects[subject.id] = false;
      }
    }

    // Calculate overall projections for whole day bunk
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

      // If simulated bunk today, add 1 to total but 0 to present
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
      appBar: AppBar(title: const Text('Bunk Eligibility & Simulator')),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects configured.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up subjects under the Attendance tab to use the calculator.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Dashboard Status
                  Text(
                    'Current Subject Eligibility',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      final stats = ref.watch(subjectStatsProvider(subject));
                      final present = stats['present'] as int;
                      final total = stats['total'] as int;

                      final result = BunkCalculator.calculate(
                        present: present,
                        total: total,
                        requiredPercent: subject.minAttendancePercent,
                      );

                      final statusColor = result.isSafe
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${result.currentPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.statusMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section 2: Whole Day Bunk Simulation
                  Text(
                    'Whole-Day Bunk Simulator',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select the classes scheduled for today to see the impact of bunking them all.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ...subjects.map((subject) {
                            return CheckboxListTile(
                              dense: true,
                              title: Text(subject.name),
                              value:
                                  _simulatedBunkSubjects[subject.id] ?? false,
                              onChanged: (val) {
                                setState(() {
                                  _simulatedBunkSubjects[subject.id] =
                                      val ?? false;
                                });
                              },
                            );
                          }),
                          const Divider(height: 24),
                          // Simulated Output Panel
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'CURRENT OVERALL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${currentOverallPercent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          currentOverallPercent >= minAttendance
                                          ? theme.colorScheme.secondary
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward),
                              Column(
                                children: [
                                  const Text(
                                    'PROJECTED OVERALL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${simulatedOverallPercent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          simulatedOverallPercent >=
                                              minAttendance
                                          ? theme.colorScheme.secondary
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Future Attendance Projection
                  Text(
                    'Future Projection Simulation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Simulation Scenario:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DropdownButton<int>(
                                value: _classesToMiss,
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Miss 1 Class'),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text('Miss 3 Classes'),
                                  ),
                                  DropdownMenuItem(
                                    value: 7,
                                    child: Text('Miss 1 Week (Entirely)'),
                                  ),
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
                          const SizedBox(height: 12),
                          const Divider(),
                          // Simulated results list
                          ...subjects.map((subject) {
                            final stats = ref.read(
                              subjectStatsProvider(subject),
                            );
                            final present = stats['present'] as int;
                            final total = stats['total'] as int;

                            final currentPercent =
                                stats['percentage'] as double;

                            // Calculate classes missed based on scenario
                            // 1 week means missing number of weekly schedules
                            final int missCount = _classesToMiss == 7
                                ? subject.schedules.length
                                : _classesToMiss;
                            final double projectedPercent =
                                (total + missCount) == 0
                                ? 100.0
                                : (present / (total + missCount)) * 100.0;
                            final bool remainsSafe =
                                projectedPercent >=
                                subject.minAttendancePercent;
                            final statusColor = remainsSafe
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      subject.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${currentPercent.toStringAsFixed(0)}%  ➔  ',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${projectedPercent.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
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
                  ),
                ],
              ),
            ),
    );
  }
}
