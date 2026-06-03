import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/assessment.dart';
import '../providers/internals_providers.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../attendance/domain/entities/subject.dart';

class SubjectInternalsScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const SubjectInternalsScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectInternalsScreen> createState() => _SubjectInternalsScreenState();
}

class _SubjectInternalsScreenState extends ConsumerState<SubjectInternalsScreen> {
  final _passingMarksController = TextEditingController(text: '40');

  // Form states for adding assessment
  final _nameController = TextEditingController();
  final _maxMarksController = TextEditingController();
  final _obtainedMarksController = TextEditingController();
  final _weightageController = TextEditingController();
  
  String _selectedType = 'Assignment';
  DateTime? _dueDate;

  final List<String> _assessmentTypes = [
    'Assignment',
    'Presentation',
    'Practical',
    'Lab Work',
    'Class Test',
    'Internal Test',
    'Mid Semester',
    'Attendance Marks',
    'Project Submission',
    'Custom'
  ];

  @override
  void dispose() {
    _passingMarksController.dispose();
    _nameController.dispose();
    _maxMarksController.dispose();
    _obtainedMarksController.dispose();
    _weightageController.dispose();
    super.dispose();
  }

  void _addAssessment() {
    final name = _selectedType == 'Custom' ? _nameController.text.trim() : _selectedType;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter custom assessment name')));
      return;
    }

    final maxMarks = double.tryParse(_maxMarksController.text) ?? 100.0;
    final obtainedMarks = double.tryParse(_obtainedMarksController.text) ?? 0.0;
    final weightage = double.tryParse(_weightageController.text) ?? 10.0;

    if (obtainedMarks > maxMarks) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obtained marks cannot exceed max marks')));
      return;
    }

    // Check if total weightage will exceed 100
    final stats = ref.read(subjectInternalsStatsProvider(widget.subjectId));
    final currentWeight = stats['totalWeightage'] as double;
    if (currentWeight + weightage > 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Total weightage cannot exceed 100%. Remaining: ${(100.0 - currentWeight).toStringAsFixed(0)}%')),
      );
      return;
    }

    final assessment = Assessment(
      id: const Uuid().v4(),
      subjectId: widget.subjectId,
      name: _selectedType == 'Custom' ? name : '',
      type: _selectedType,
      maxMarks: maxMarks,
      obtainedMarks: obtainedMarks,
      weightage: weightage,
      dueDate: _dueDate,
    );

    ref.read(assessmentsProvider.notifier).addAssessment(assessment);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assessment saved successfully.')));

    // Reset controllers
    setState(() {
      _nameController.clear();
      _maxMarksController.clear();
      _obtainedMarksController.clear();
      _weightageController.clear();
      _dueDate = null;
    });
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Find subject name
    final subjects = ref.watch(subjectsProvider);
    final subject = subjects.firstWhere(
      (s) => s.id == widget.subjectId,
      orElse: () => const Subject(id: '', name: 'Not Found', minAttendancePercent: 75, creditHours: 0, schedules: []),
    );

    if (subject.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assessments')),
        body: const Center(child: Text('Subject not found.')),
      );
    }

    final repo = ref.read(internalsRepositoryProvider);
    final targetPass = double.tryParse(_passingMarksController.text) ?? 40.0;
    
    final passResult = repo.calculatePassingRequirements(
      subjectId: widget.subjectId,
      passingMarksThreshold: targetPass,
    );

    final assessments = ref.watch(assessmentsProvider)
        .where((a) => a.subjectId == widget.subjectId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${subject.name} - Internals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passing Requirement Calculator Card
            Text('Passing Calculator & Prediction', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: passResult['isAlreadyPassed'] 
                  ? theme.colorScheme.secondary.withValues(alpha: 0.08) 
                  : passResult['isImpossible'] 
                      ? theme.colorScheme.error.withValues(alpha: 0.08)
                      : theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Passing Marks Threshold (out of 100):',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _passingMarksController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {}); // Re-trigger build to recalculate passing criteria
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Weighted Marks:', style: theme.textTheme.bodySmall),
                        Text(
                          '${(passResult['currentEarned'] as double).toStringAsFixed(1)} / ${(passResult['evaluatedWeightage'] as double).toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (passResult['isAlreadyPassed'])
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          const Text('Congrats! You have already passed this course.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    else if (passResult['isImpossible'])
                      Row(
                        children: [
                          Icon(Icons.dangerous, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Warning: Mathematically impossible to reach passing score with remaining assessments.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Marks Still Needed:', style: theme.textTheme.bodySmall),
                          Text(
                            '${(passResult['neededToPass'] as double).toStringAsFixed(1)} Marks',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Prediction: You need to average at least ${(passResult['requiredPercentageOnRemaining'] as double).toStringAsFixed(1)}% in the remaining ${(passResult['remainingWeightage'] as double).toStringAsFixed(0)}% weightage of assessments to pass.',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form to Add Assessment
            Text('Add Internal Assessment', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                            items: _assessmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedType = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_selectedType == 'Custom') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Custom Assessment Name', border: OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _obtainedMarksController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Obtained Marks', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _maxMarksController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Max Marks', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Weightage',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(_dueDate == null ? 'Due Date' : DateFormat('MM-dd').format(_dueDate!)),
                            onPressed: _pickDueDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Save Assessment Marks'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: _addAssessment,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Assessments List
            Text('Evaluations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (assessments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No assessments logged yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assessments.length,
                itemBuilder: (context, index) {
                  final assessment = assessments[index];
                  final nameDisplay = assessment.type == 'Custom' ? assessment.name : assessment.type;
                  final double weightedScore = (assessment.obtainedMarks / assessment.maxMarks) * assessment.weightage;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.assessment)),
                      title: Text(nameDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Marks: ${assessment.obtainedMarks.toStringAsFixed(1)} / ${assessment.maxMarks.toStringAsFixed(0)} | Weight: ${assessment.weightage.toStringAsFixed(0)}%',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('+${weightedScore.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              ref.read(assessmentsProvider.notifier).deleteAssessment(assessment.id);
                            },
                          ),
                        ],
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
