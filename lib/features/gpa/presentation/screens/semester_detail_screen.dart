import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/semester.dart';
import '../providers/gpa_providers.dart';

class SemesterDetailScreen extends ConsumerStatefulWidget {
  final String semesterId;
  const SemesterDetailScreen({super.key, required this.semesterId});

  @override
  ConsumerState<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends ConsumerState<SemesterDetailScreen> {
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');

  String? _selectedGrade;

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _addCourse(Semester semester, List<String> availableGrades) {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Please enter course name');
      return;
    }
    
    HapticFeedback.lightImpact();

    final credits = int.tryParse(_creditsController.text) ?? 3;
    final grade = _selectedGrade ?? (availableGrades.isNotEmpty ? availableGrades.first : 'A');

    final updatedSubjects = List<SGPAEntry>.from(semester.subjects)
      ..add(
        SGPAEntry(
          subjectName: _nameController.text.trim(),
          credits: credits,
          grade: grade,
        ),
      );

    final updatedSemester = semester.copyWith(
      subjects: updatedSubjects,
      customGpa: null, // Clear manual GPA since detail entries are active
    );

    ref.read(semestersProvider.notifier).updateSemester(updatedSemester);

    setState(() {
      _nameController.clear();
      _creditsController.text = '3';
    });
  }

  void _removeCourse(Semester semester, int index) {
    HapticFeedback.selectionClick();
    final updatedSubjects = List<SGPAEntry>.from(semester.subjects)..removeAt(index);
    final updatedSemester = semester.copyWith(subjects: updatedSubjects);
    ref.read(semestersProvider.notifier).updateSemester(updatedSemester);
  }

  void _deleteSemester(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester'),
        content: const Text('Are you sure you want to delete this semester? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(semestersProvider.notifier).deleteSemester(id);
              Navigator.pop(context);
              context.pop();
              AppSnackBar.show(context, message: 'Semester deleted');
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semesters = ref.watch(semestersProvider);
    final activeSystem = ref.watch(selectedGradingSystemProvider);

    final semester = semesters.firstWhere(
      (s) => s.id == widget.semesterId,
      orElse: () => const Semester(id: '', name: 'Not Found', subjects: []),
    );

    if (semester.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Semester Details')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Not Found',
          description: 'The requested semester could not be found.',
        ),
      );
    }

    final repo = ref.read(gpaRepositoryProvider);
    final sgpa = repo.calculateSGPA(semester, activeSystem);

    final gradesList = activeSystem.grades.keys.toList();
    if (_selectedGrade == null && gradesList.isNotEmpty) {
      _selectedGrade = gradesList.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(semester.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () => _deleteSemester(semester.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dynamic SGPA Header Box ──
            AppCard(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              border: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester SGPA',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${semester.subjects.length} course entries',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    sgpa.toStringAsFixed(2),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Add Course Form ──
            const SectionHeader(title: 'Add Course Entry'),
            AppCard(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'e.g. Computer Science',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _creditsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Credits',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGrade,
                          decoration: const InputDecoration(
                            labelText: 'Grade Earned',
                            prefixIcon: Icon(Icons.military_tech_rounded),
                          ),
                          items: gradesList.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGrade = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Course'),
                      onPressed: () => _addCourse(semester, gradesList),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Course Entries List ──
            const SectionHeader(title: 'Course Entries'),
            if (semester.subjects.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No courses added',
                description: 'Add courses above to calculate this semester\'s SGPA.',
              )
            else
              ...semester.subjects.asMap().entries.map((entry) {
                final index = entry.key;
                final subject = entry.value;
                final points = activeSystem.grades[subject.grade.toUpperCase()] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              subject.grade,
                              style: theme.textTheme.titleMedium?.copyWith(
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
                                subject.subjectName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${subject.credits} Credits · $points Points',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                          onPressed: () => _removeCourse(semester, index),
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
