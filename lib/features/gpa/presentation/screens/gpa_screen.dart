import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/semester.dart';
import '../providers/gpa_providers.dart';

class GpaScreen extends ConsumerStatefulWidget {
  const GpaScreen({super.key});

  @override
  ConsumerState<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends ConsumerState<GpaScreen> {
  // Goal calculator form state
  final _goalFormKey = GlobalKey<FormState>();
  final _currentCgpController = TextEditingController();
  final _targetCgpController = TextEditingController();
  final _completedCreditsController = TextEditingController();
  final _remainingCreditsController = TextEditingController();
  
  double? _requiredFutureGpa;
  bool _goalCalculated = false;

  @override
  void dispose() {
    _currentCgpController.dispose();
    _targetCgpController.dispose();
    _completedCreditsController.dispose();
    _remainingCreditsController.dispose();
    super.dispose();
  }

  void _calculateGoal() {
    if (!_goalFormKey.currentState!.validate()) return;

    final current = double.parse(_currentCgpController.text);
    final target = double.parse(_targetCgpController.text);
    final completed = int.parse(_completedCreditsController.text);
    final remaining = int.parse(_remainingCreditsController.text);

    final repo = ref.read(gpaRepositoryProvider);
    final requiredGpa = repo.calculateRequiredFutureGPA(
      currentCGPA: current,
      targetCGPA: target,
      completedCredits: completed,
      remainingCredits: remaining,
    );

    setState(() {
      _requiredFutureGpa = requiredGpa;
      _goalCalculated = true;
    });
  }

  void _addNewSemester() {
    final semesters = ref.read(semestersProvider);
    final nextNumber = semesters.length + 1;
    
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: 'Semester $nextNumber');
        final customGpaController = TextEditingController();
        bool useManualGpa = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Semester'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Semester Name'),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Enter GPA directly (manual)'),
                    value: useManualGpa,
                    onChanged: (val) {
                      setDialogState(() {
                        useManualGpa = val ?? false;
                      });
                    },
                  ),
                  if (useManualGpa)
                    TextField(
                      controller: customGpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Enter GPA (e.g. 8.5)'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    double? manualGpa;
                    if (useManualGpa) {
                      manualGpa = double.tryParse(customGpaController.text);
                    }

                    final newSem = Semester(
                      id: const Uuid().v4(),
                      name: name,
                      subjects: [],
                      customGpa: manualGpa,
                    );

                    ref.read(semestersProvider.notifier).addSemester(newSem);
                    Navigator.pop(context);

                    if (!useManualGpa) {
                      // Navigate directly to setup subjects inside semester
                      context.push('/gpa/semester/${newSem.id}');
                    }
                  },
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semesters = ref.watch(semestersProvider);
    final gradingSystems = ref.watch(gradingSystemsProvider);
    final selectedSystemId = ref.watch(selectedGradingSystemIdProvider);
    final activeSystem = ref.watch(selectedGradingSystemProvider);
    final cgpa = ref.watch(cgpaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA & CGPA Manager'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSemester,
        icon: const Icon(Icons.add_road),
        label: const Text('Add Semester'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall CGPA Display
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cumulative CGPA',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cgpa.toStringAsFixed(2),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grading System: ${activeSystem.name}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.stars, size: 64, color: Colors.amber),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Grading System
            Text('Grading Scale', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSystemId,
                  decoration: const InputDecoration(
                    labelText: 'Current Grading Scale',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: gradingSystems.map((sys) {
                    return DropdownMenuItem(
                      value: sys.id,
                      child: Text(sys.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(selectedGradingSystemIdProvider.notifier).selectSystem(id);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Semesters List
            Text('Semesters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (semesters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No semesters added yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: semesters.length,
                itemBuilder: (context, index) {
                  final semester = semesters[index];
                  final repo = ref.read(gpaRepositoryProvider);
                  final sgpa = repo.calculateSGPA(semester, activeSystem);
                  final int credits = semester.customGpa != null 
                      ? 15 
                      : semester.subjects.fold<int>(0, (sum, item) => sum + item.credits);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.school)),
                      title: Text(semester.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$credits Credits | SGPA: ${sgpa.toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push('/gpa/semester/${semester.id}'),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // GPA Goal Calculator Card
            Text('GPA Target Goal Planner', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _goalFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _currentCgpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Current CGPA', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _targetCgpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Target CGPA', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _completedCreditsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Completed Credits', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _remainingCreditsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Remaining Credits', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _calculateGoal,
                        child: const Text('Calculate Required GPA'),
                      ),
                      if (_goalCalculated && _requiredFutureGpa != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _requiredFutureGpa! <= activeSystem.maxPoints
                                ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                                : theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _requiredFutureGpa! <= activeSystem.maxPoints
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Required Future SGPA',
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _requiredFutureGpa!.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _requiredFutureGpa! <= activeSystem.maxPoints
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _requiredFutureGpa! <= activeSystem.maxPoints
                                    ? 'This goal is achievable!'
                                    : 'Warning: This exceeds the maximum grade point scale (${activeSystem.maxPoints.toStringAsFixed(0)}). Adjust target.',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
