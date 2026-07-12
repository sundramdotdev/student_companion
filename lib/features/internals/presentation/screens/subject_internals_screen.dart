import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
      AppSnackBar.error(context, 'Please enter custom assessment name');
      return;
    }

    final maxMarks = double.tryParse(_maxMarksController.text) ?? 100.0;
    final obtainedMarks = double.tryParse(_obtainedMarksController.text) ?? 0.0;
    final weightage = double.tryParse(_weightageController.text) ?? 10.0;

    if (obtainedMarks > maxMarks) {
      AppSnackBar.error(context, 'Obtained marks cannot exceed max marks');
      return;
    }

    // Check if total weightage will exceed 100
    final stats = ref.read(subjectInternalsStatsProvider(widget.subjectId));
    final currentWeight = stats['totalWeightage'] as double;
    if (currentWeight + weightage > 100.0) {
      AppSnackBar.error(
        context,
        'Total weightage cannot exceed 100%. Remaining: ${(100.0 - currentWeight).toStringAsFixed(0)}%',
      );
      return;
    }

    HapticFeedback.lightImpact();

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
    AppSnackBar.success(context, 'Assessment saved successfully');

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _showAddAssessmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Add Assessment'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.assignment_rounded),
                    ),
                    items: _assessmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _selectedType = val);
                        setState(() => _selectedType = val); // Sync parent state too
                      }
                    },
                  ),
                  if (_selectedType == 'Custom') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Name',
                        prefixIcon: Icon(Icons.edit_rounded),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _obtainedMarksController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Obtained',
                            prefixIcon: Icon(Icons.done_all_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxMarksController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Marks',
                            prefixIcon: Icon(Icons.grading_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weightage',
                            prefixIcon: Icon(Icons.percent_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await _pickDueDate();
                            setSheetState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              prefixIcon: Icon(Icons.event_note_rounded),
                            ),
                            child: Text(
                              _dueDate == null ? 'None' : DateFormat('MMM d').format(_dueDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _addAssessment();
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final subjects = ref.watch(subjectsProvider);
    final subject = subjects.firstWhere(
      (s) => s.id == widget.subjectId,
      orElse: () => const Subject(id: '', name: 'Not Found', minAttendancePercent: 75, creditHours: 0, schedules: []),
    );

    if (subject.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assessments')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Not Found',
          description: 'The requested subject could not be found.',
        ),
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
        title: Text(subject.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _showAddAssessmentSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Passing Prediction Card ──
            const SectionHeader(title: 'Passing Predictor'),
            AppCard(
              color: passResult['isAlreadyPassed']
                  ? AppColors.success.withValues(alpha: 0.1)
                  : passResult['isImpossible']
                      ? AppColors.danger.withValues(alpha: 0.1)
                      : null,
              border: BorderSide(
                color: passResult['isAlreadyPassed']
                    ? AppColors.success.withValues(alpha: 0.3)
                    : passResult['isImpossible']
                        ? AppColors.danger.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Passing Marks Threshold (out of 100):',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                          ),
                          onChanged: (val) {
                            setState(() {}); // Re-trigger build
                          },
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Weighted Marks:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(passResult['currentEarned'] as double).toStringAsFixed(1)} / ${(passResult['evaluatedWeightage'] as double).toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (passResult['isAlreadyPassed'])
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success),
                        const SizedBox(width: 8),
                        const Text(
                          'Congrats! You have already passed.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  else if (passResult['isImpossible'])
                    Row(
                      children: [
                        Icon(Icons.dangerous_rounded, color: AppColors.danger),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Warning: Mathematically impossible to reach passing score.',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Marks Still Needed:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(passResult['neededToPass'] as double).toStringAsFixed(1)} Marks',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Prediction: You need to average at least ${(passResult['requiredPercentageOnRemaining'] as double).toStringAsFixed(1)}% in the remaining ${(passResult['remainingWeightage'] as double).toStringAsFixed(0)}% weightage of assessments to pass.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Evaluations List ──
            const SectionHeader(title: 'Evaluations'),
            if (assessments.isEmpty)
              const EmptyState(
                icon: Icons.assignment_turned_in_rounded,
                title: 'No assessments',
                description: 'Add your first assessment to start tracking internal marks.',
              )
            else
              ...assessments.map((assessment) {
                final nameDisplay = assessment.type == 'Custom' ? assessment.name : assessment.type;
                final double weightedScore = (assessment.obtainedMarks / assessment.maxMarks) * assessment.weightage;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.assignment_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameDisplay,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${assessment.obtainedMarks.toStringAsFixed(1)}/${assessment.maxMarks.toStringAsFixed(0)} marks · ${assessment.weightage.toStringAsFixed(0)}% weight',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${weightedScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                ref.read(assessmentsProvider.notifier).deleteAssessment(assessment.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
