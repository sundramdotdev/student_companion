import 'dart:convert';
import 'hive_service.dart';
import '../../features/attendance/domain/entities/subject.dart';
import '../../features/attendance/domain/entities/attendance_log.dart';
import '../../features/gpa/domain/entities/grading_system.dart';
import '../../features/gpa/domain/entities/semester.dart';
import '../../features/internals/domain/entities/assessment.dart';

class BackupRestoreService {
  // Export all Hive boxes to a single JSON String
  static String exportBackup() {
    final Map<String, dynamic> backupMap = {
      'subjects': HiveService.subjectsBox.values.map((s) => s.toJson()).toList(),
      'attendance_logs': HiveService.attendanceLogsBox.values.map((log) => log.toJson()).toList(),
      'grading_systems': HiveService.gradingSystemsBox.values.map((sys) => sys.toJson()).toList(),
      'semesters': HiveService.semestersBox.values.map((sem) => sem.toJson()).toList(),
      'assessments': HiveService.assessmentsBox.values.map((a) => a.toJson()).toList(),
      'settings': Map<String, dynamic>.from(HiveService.settingsBox.toMap()),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  // Import Hive boxes from JSON String
  static Future<bool> importBackup(String jsonString) async {
    try {
      final Map<String, dynamic> backupMap = json.decode(jsonString);

      // Clear all boxes first
      await HiveService.subjectsBox.clear();
      await HiveService.attendanceLogsBox.clear();
      await HiveService.gradingSystemsBox.clear();
      await HiveService.semestersBox.clear();
      await HiveService.assessmentsBox.clear();
      await HiveService.settingsBox.clear();

      // Restore settings
      if (backupMap['settings'] != null) {
        final settings = Map<String, dynamic>.from(backupMap['settings']);
        for (final entry in settings.entries) {
          await HiveService.settingsBox.put(entry.key, entry.value);
        }
      }

      // Restore subjects
      if (backupMap['subjects'] != null) {
        for (final jsonMap in backupMap['subjects']) {
          final subject = Subject.fromJson(Map<String, dynamic>.from(jsonMap));
          await HiveService.subjectsBox.put(subject.id, subject);
        }
      }

      // Restore attendance logs
      if (backupMap['attendance_logs'] != null) {
        for (final jsonMap in backupMap['attendance_logs']) {
          final log = AttendanceLog.fromJson(Map<String, dynamic>.from(jsonMap));
          await HiveService.attendanceLogsBox.put(log.id, log);
        }
      }

      // Restore grading systems
      if (backupMap['grading_systems'] != null) {
        for (final jsonMap in backupMap['grading_systems']) {
          final system = GradingSystem.fromJson(Map<String, dynamic>.from(jsonMap));
          await HiveService.gradingSystemsBox.put(system.id, system);
        }
      }

      // Restore semesters
      if (backupMap['semesters'] != null) {
        for (final jsonMap in backupMap['semesters']) {
          final semester = Semester.fromJson(Map<String, dynamic>.from(jsonMap));
          await HiveService.semestersBox.put(semester.id, semester);
        }
      }

      // Restore assessments
      if (backupMap['assessments'] != null) {
        for (final jsonMap in backupMap['assessments']) {
          final assessment = Assessment.fromJson(Map<String, dynamic>.from(jsonMap));
          await HiveService.assessmentsBox.put(assessment.id, assessment);
        }
      }

      return true;
    } catch (e) {
      // Return false in case of any parsing or insertion error
      return false;
    }
  }
}
