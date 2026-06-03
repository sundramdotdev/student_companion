import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter course name')),
      );
      return;
    }

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

    // Reset controllers
    setState(() {
      _nameController.clear();
      _creditsController.text = '3';
    });
  }

  void _removeCourse(Semester semester, int index) {
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
          TextButton(
            onPressed: () {
              ref.read(semestersProvider.notifier).deleteSemester(id);
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
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
        body: const Center(child: Text('Semester not found.')),
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
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deleteSemester(semester.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic SGPA Header Box
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semester SGPA',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on ${semester.subjects.length} course entries',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      sgpa.toStringAsFixed(2),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form to Add Course
            Text('Add Course Entry', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Course Name (e.g. Computer Science)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _creditsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGrade,
                            decoration: const InputDecoration(
                              labelText: 'Grade Earned',
                              border: OutlineInputBorder(),
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
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Course to Semester'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () => _addCourse(semester, gradesList),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List of Course Entries
            Text('Course Entries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (semester.subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No course entries added yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: semester.subjects.length,
                itemBuilder: (context, index) {
                  final subject = semester.subjects[index];
                  final points = activeSystem.grades[subject.grade.toUpperCase()] ?? 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(subject.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${subject.credits} Credits | Grade: ${subject.grade} ($points Pts)'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeCourse(semester, index),
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
