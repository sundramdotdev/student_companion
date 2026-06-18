import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/backup_restore_service.dart';
import '../../../gpa/domain/entities/grading_system.dart';
import '../../../gpa/presentation/providers/gpa_providers.dart';
import '../providers/settings_providers.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../internals/presentation/providers/internals_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _restoreController = TextEditingController();
  
  // Custom grading system form fields
  final _sysNameController = TextEditingController();
  final _maxPointsController = TextEditingController(text: '10');
  
  // Custom grade map inputs
  final _gradeLetterController = TextEditingController();
  final _gradePointController = TextEditingController();
  final Map<String, double> _customGradesMap = {};

  @override
  void dispose() {
    _restoreController.dispose();
    _sysNameController.dispose();
    _maxPointsController.dispose();
    _gradeLetterController.dispose();
    _gradePointController.dispose();
    super.dispose();
  }

  void _exportData() {
    final jsonStr = BackupRestoreService.exportBackup();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup data copied to Clipboard!')),
    );
  }

  Future<void> _importData() async {
    final input = _restoreController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste the backup JSON first.')),
      );
      return;
    }

    final success = await BackupRestoreService.importBackup(input);

    if (success) {
      // Reload all providers state
      ref.read(subjectsProvider.notifier).loadSubjects();
      ref.read(attendanceLogsProvider.notifier).loadLogs();
      ref.read(semestersProvider.notifier).loadSemesters();
      ref.read(assessmentsProvider.notifier).loadAssessments();
      ref.read(gradingSystemsProvider.notifier).loadSystems();
      
      _restoreController.clear();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text('Your student data, timetable, and settings have been restored successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Failed'),
            content: const Text('Invalid backup JSON format. Please verify the copied backup data and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _addGradeToMap() {
    final letter = _gradeLetterController.text.trim().toUpperCase();
    final points = double.tryParse(_gradePointController.text);

    if (letter.isEmpty || points == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid grade letter and points.')),
      );
      return;
    }

    setState(() {
      _customGradesMap[letter] = points;
      _gradeLetterController.clear();
      _gradePointController.clear();
    });
  }

  Future<void> _saveCustomGradingSystem() async {
    final name = _sysNameController.text.trim();
    final maxPts = double.tryParse(_maxPointsController.text) ?? 10.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter grading system name.')),
      );
      return;
    }

    if (_customGradesMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one grade to the map.')),
      );
      return;
    }

    final newSys = GradingSystem(
      id: const Uuid().v4(),
      name: name,
      maxPoints: maxPts,
      grades: Map.from(_customGradesMap),
    );

    await ref.read(gradingSystemsProvider.notifier).addSystem(newSys);
    await ref.read(selectedGradingSystemIdProvider.notifier).selectSystem(newSys.id);

    setState(() {
      _sysNameController.clear();
      _maxPointsController.text = '10';
      _customGradesMap.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grading System "$name" saved and selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final minAttendance = ref.watch(minAttendanceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 16),
            // Theme selector Card
            Text('Aesthetics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Theme Mode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('Dark')),
                        ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text('System')),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Attendance settings Card
            Text('Attendance Rule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minimum Attendance Requirement: ${minAttendance.toStringAsFixed(0)}%', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Slider(
                      value: minAttendance,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      label: '${minAttendance.toStringAsFixed(0)}%',
                      onChanged: (val) {
                        ref.read(minAttendanceProvider.notifier).setMinAttendance(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Custom grading system form Card
            Text('Create Custom Grading Scale', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _sysNameController,
                      decoration: const InputDecoration(labelText: 'Scale Name (e.g. Cambridge A-Levels)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxPointsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Maximum Points (e.g. 10 or 4)', border: OutlineInputBorder()),
                    ),
                    const Divider(height: 32),
                    Text('Add Letter Grades', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _gradeLetterController,
                            decoration: const InputDecoration(labelText: 'Grade (e.g. A+)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _gradePointController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Points (e.g. 9.5)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addGradeToMap,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_customGradesMap.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        children: _customGradesMap.entries.map((entry) {
                          return Chip(
                            label: Text('${entry.key}: ${entry.value}'),
                            onDeleted: () {
                              setState(() {
                                _customGradesMap.remove(entry.key);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Custom Grade Scale'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: _saveCustomGradingSystem,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Backup & Restore Card
            Text('Backup & Restore Data', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Export your logs, grades, and attendance database to move them to another device or save for backup.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Export Data (Copy JSON)'),
                      onPressed: _exportData,
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Paste your exported JSON database backup code here to restore all data.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _restoreController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Paste backup JSON code here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Import Backup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: theme.colorScheme.onTertiary,
                      ),
                      onPressed: _importData,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'design and developed by Sundramdotdev',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
