import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/storage/backup_restore_service.dart';
import '../../../../core/config/app_info.dart';
import '../providers/settings_providers.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../gpa/presentation/providers/gpa_providers.dart';
import '../../../gpa/domain/entities/grading_system.dart';
import '../../../internals/presentation/providers/internals_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _restoreController = TextEditingController();

  // Custom Grading System Form State
  final _sysNameController = TextEditingController();
  final _maxPointsController = TextEditingController(text: '10');
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

  Future<void> _exportData() async {
    final data = BackupRestoreService.exportBackup();
    await Clipboard.setData(ClipboardData(text: data));
    if (mounted) {
      AppSnackBar.success(context, 'Data exported and copied to clipboard');
    }
  }

  Future<void> _importData() async {
    final jsonStr = _restoreController.text.trim();
    if (jsonStr.isEmpty) {
      AppSnackBar.error(context, 'Please paste backup data first');
      return;
    }

    try {
      jsonDecode(jsonStr); // Just to validate JSON
    } catch (e) {
      AppSnackBar.error(context, 'Invalid JSON format');
      return;
    }

    final success = await BackupRestoreService.importBackup(jsonStr);

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
      AppSnackBar.error(context, 'Please enter valid grade letter and points');
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
      AppSnackBar.error(context, 'Please enter grading system name');
      return;
    }

    if (_customGradesMap.isEmpty) {
      AppSnackBar.error(context, 'Please add at least one grade to the map');
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
      AppSnackBar.success(context, 'Grading System "$name" saved and selected');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final minAttendance = ref.watch(minAttendanceProvider);
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // ── Aesthetics ──
            const SectionHeader(title: 'Aesthetics'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Theme Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_suggest_rounded),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Attendance Rule ──
            const SectionHeader(title: 'Attendance Rule'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimum Attendance Requirement: ${minAttendance.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: minAttendance,
                    min: 50,
                    max: 100,
                    divisions: 10,
                    activeColor: theme.colorScheme.primary,
                    label: '${minAttendance.toStringAsFixed(0)}%',
                    onChanged: (val) {
                      ref.read(minAttendanceProvider.notifier).setMinAttendance(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Custom Grading Scale ──
            const SectionHeader(title: 'Custom Grading Scale'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _sysNameController,
                    decoration: const InputDecoration(
                      labelText: 'Scale Name',
                      hintText: 'e.g. Cambridge A-Levels',
                      prefixIcon: Icon(Icons.school_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxPointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Points',
                      hintText: 'e.g. 10 or 4',
                      prefixIcon: Icon(Icons.military_tech_rounded),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Text(
                    'Add Letter Grades',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _gradeLetterController,
                          decoration: const InputDecoration(
                            labelText: 'Grade',
                            hintText: 'e.g. A+',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _gradePointController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Points',
                            hintText: 'e.g. 9.5',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _addGradeToMap,
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_customGradesMap.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _customGradesMap.entries.map((entry) {
                        return InputChip(
                          label: Text('${entry.key}: ${entry.value}'),
                          onDeleted: () {
                            setState(() {
                              _customGradesMap.remove(entry.key);
                            });
                          },
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Custom Grade Scale'),
                      onPressed: _saveCustomGradingSystem,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Backup & Restore ──
            const SectionHeader(title: 'Backup & Restore'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Export your logs, grades, and attendance database to move them to another device or save for backup.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Export Data (Copy JSON)'),
                    onPressed: _exportData,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                  Text(
                    'Paste your exported JSON database backup code here to restore all data.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _restoreController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Paste backup JSON code here...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Import Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    onPressed: _importData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Application & Legal ──
            const SectionHeader(title: 'Application & Legal'),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About Student Companion'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/about'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/privacy'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.gavel_rounded),
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/licenses'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('Send Feedback'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _launchUrl('mailto:sundram.devv@gmail.com'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.star_outline_rounded),
                    title: const Text('Rate App'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _launchUrl('https://github.com/sundramdotdev/student_companion'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share App'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _launchUrl('https://github.com/sundramdotdev/student_companion'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code_rounded),
                    title: const Text('GitHub Repository'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _launchUrl('https://github.com/sundramdotdev/student_companion'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.system_update_alt_rounded),
                    title: const Text('App Version'),
                    subtitle: Text('${appInfo.version} (Build ${appInfo.buildNumber})'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ── Footer ──
            Center(
              child: Column(
                children: [
                  Text(
                    appInfo.appName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${appInfo.version}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
