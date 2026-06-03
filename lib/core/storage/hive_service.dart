import 'package:hive_flutter/hive_flutter.dart';
import '../../features/attendance/domain/entities/schedule.dart';
import '../../features/attendance/domain/entities/subject.dart';
import '../../features/attendance/domain/entities/attendance_log.dart';
import '../../features/gpa/domain/entities/grading_system.dart';
import '../../features/gpa/domain/entities/semester.dart';
import '../../features/internals/domain/entities/assessment.dart';

class HiveService {
  static const String subjectsBoxName = 'subjects_box';
  static const String attendanceLogsBoxName = 'attendance_logs_box';
  static const String gradingSystemsBoxName = 'grading_systems_box';
  static const String semestersBoxName = 'semesters_box';
  static const String assessmentsBoxName = 'assessments_box';
  static const String settingsBoxName = 'settings_box';

  static late Box<Subject> subjectsBox;
  static late Box<AttendanceLog> attendanceLogsBox;
  static late Box<GradingSystem> gradingSystemsBox;
  static late Box<Semester> semestersBox;
  static late Box<Assessment> assessmentsBox;
  static late Box settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ScheduleAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(AttendanceStatusAdapter());
    Hive.registerAdapter(AttendanceLogAdapter());
    Hive.registerAdapter(GradingSystemAdapter());
    Hive.registerAdapter(SGPAEntryAdapter());
    Hive.registerAdapter(SemesterAdapter());
    Hive.registerAdapter(AssessmentAdapter());

    // Open boxes
    subjectsBox = await Hive.openBox<Subject>(subjectsBoxName);
    attendanceLogsBox = await Hive.openBox<AttendanceLog>(attendanceLogsBoxName);
    gradingSystemsBox = await Hive.openBox<GradingSystem>(gradingSystemsBoxName);
    semestersBox = await Hive.openBox<Semester>(semestersBoxName);
    assessmentsBox = await Hive.openBox<Assessment>(assessmentsBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);

    await _initDefaults();
  }

  Future<void> _initDefaults() async {
    // Default attendance requirement
    if (settingsBox.get('min_attendance') == null) {
      await settingsBox.put('min_attendance', 75.0);
    }

    // Default grading systems if none exist
    if (gradingSystemsBox.isEmpty) {
      final tenPointSystem = GradingSystem(
        id: '10_point',
        name: '10-Point Scale (Standard)',
        maxPoints: 10.0,
        grades: {
          'O': 10.0,
          'A+': 9.0,
          'A': 8.0,
          'B+': 7.0,
          'B': 6.0,
          'C': 5.0,
          'P': 4.0,
          'F': 0.0,
        },
      );

      final fourPointSystem = GradingSystem(
        id: '4_point',
        name: '4-Point Scale (US)',
        maxPoints: 4.0,
        grades: {
          'A': 4.0,
          'A-': 3.7,
          'B+': 3.3,
          'B': 3.0,
          'B-': 2.7,
          'C+': 2.3,
          'C': 2.0,
          'C-': 1.7,
          'D+': 1.3,
          'D': 1.0,
          'F': 0.0,
        },
      );

      await gradingSystemsBox.put(tenPointSystem.id, tenPointSystem);
      await gradingSystemsBox.put(fourPointSystem.id, fourPointSystem);
    }

    // Default selected grading system
    if (settingsBox.get('selected_grading_system_id') == null) {
      await settingsBox.put('selected_grading_system_id', '10_point');
    }
  }

  // Helper method to clear all data (useful for test/reset)
  Future<void> clearAll() async {
    await subjectsBox.clear();
    await attendanceLogsBox.clear();
    await gradingSystemsBox.clear();
    await semestersBox.clear();
    await assessmentsBox.clear();
    await settingsBox.clear();
    await _initDefaults();
  }
}
