import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/semester.dart';
import '../providers/gpa_providers.dart';

class GpaScreen extends ConsumerStatefulWidget {
  const GpaScreen({super.key});

  @override
  ConsumerState<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends ConsumerState<GpaScreen> {
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
    HapticFeedback.lightImpact();

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final nameController = TextEditingController(text: 'Semester $nextNumber');
        final customGpaController = TextEditingController();
        bool useManualGpa = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Add Semester'),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Semester Name',
                      prefixIcon: Icon(Icons.calendar_view_day_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enter GPA manually'),
                    subtitle: const Text('Skip adding individual subjects'),
                    value: useManualGpa,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setSheetState(() {
                        useManualGpa = val;
                      });
                    },
                  ),
                  if (useManualGpa) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customGpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Manual GPA (e.g. 8.5)',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                    ),
                  ],
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
                              context.push('/gpa/semester/${newSem.id}');
                            } else {
                              AppSnackBar.success(context, 'Semester added');
                            }
                          },
                          child: const Text('Add'),
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
    final semesters = ref.watch(semestersProvider);
    final gradingSystems = ref.watch(gradingSystemsProvider);
    final selectedSystemId = ref.watch(selectedGradingSystemIdProvider);
    final activeSystem = ref.watch(selectedGradingSystemProvider);
    final cgpa = ref.watch(cgpaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _addNewSemester,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Semester'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero CGPA Card ──
            AppCard(
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cumulative CGPA',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cgpa.toStringAsFixed(2),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Scale: ${activeSystem.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Grading Scale Selector ──
            const SectionHeader(title: 'Grading Scale'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSystemId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: gradingSystems.map((sys) {
                    return DropdownMenuItem(
                      value: sys.id,
                      child: Text(
                        sys.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

            // ── Semesters List ──
            const SectionHeader(title: 'Semesters'),
            if (semesters.isEmpty)
              const EmptyState(
                icon: Icons.history_edu_rounded,
                title: 'No semesters added',
                description: 'Add your previous and current semesters to track your CGPA accurately.',
              )
            else
              ...semesters.map((semester) {
                final repo = ref.read(gpaRepositoryProvider);
                final sgpa = repo.calculateSGPA(semester, activeSystem);
                final int credits = semester.customGpa != null
                    ? 15
                    : semester.subjects.fold<int>(0, (sum, item) => sum + item.credits);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push('/gpa/semester/${semester.id}'),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              sgpa.toStringAsFixed(1),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                semester.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$credits Credits',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),

            // ── GPA Goal Calculator ──
            const SectionHeader(title: 'Goal Planner'),
            AppCard(
              child: Form(
                key: _goalFormKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _currentCgpController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Current CGPA',
                              prefixIcon: Icon(Icons.timeline_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _targetCgpController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Target CGPA',
                              prefixIcon: Icon(Icons.track_changes_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _completedCreditsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Completed Credits',
                              prefixIcon: Icon(Icons.done_all_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _remainingCreditsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Remaining Credits',
                              prefixIcon: Icon(Icons.hourglass_empty_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateGoal,
                        child: const Text('Calculate Required GPA'),
                      ),
                    ),
                    if (_goalCalculated && _requiredFutureGpa != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _requiredFutureGpa! <= activeSystem.maxPoints
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _requiredFutureGpa! <= activeSystem.maxPoints
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Required Future SGPA',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _requiredFutureGpa!.toStringAsFixed(2),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _requiredFutureGpa! <= activeSystem.maxPoints
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _requiredFutureGpa! <= activeSystem.maxPoints
                                  ? 'This goal is achievable! Stay focused.'
                                  : 'Warning: This exceeds the maximum grade point scale (${activeSystem.maxPoints.toStringAsFixed(0)}). Adjust target.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
