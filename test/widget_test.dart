import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_companion/main.dart';
import 'package:student_companion/core/storage/hive_service.dart';
import 'package:student_companion/features/attendance/domain/entities/schedule.dart';
import 'package:student_companion/features/attendance/domain/entities/subject.dart';
import 'package:student_companion/features/attendance/domain/entities/attendance_log.dart';
import 'package:student_companion/features/gpa/domain/entities/grading_system.dart';
import 'package:student_companion/features/gpa/domain/entities/semester.dart';
import 'package:student_companion/features/internals/domain/entities/assessment.dart';

void main() {
  setUp(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);

    try {
      Hive.registerAdapter(ScheduleAdapter());
      Hive.registerAdapter(SubjectAdapter());
      Hive.registerAdapter(AttendanceStatusAdapter());
      Hive.registerAdapter(AttendanceLogAdapter());
      Hive.registerAdapter(GradingSystemAdapter());
      Hive.registerAdapter(SGPAEntryAdapter());
      Hive.registerAdapter(SemesterAdapter());
      Hive.registerAdapter(AssessmentAdapter());
    } catch (_) {
      // Adapters might already be registered in previous tests
    }

    HiveService.settingsBox = await Hive.openBox(HiveService.settingsBoxName);
    HiveService.subjectsBox = await Hive.openBox<Subject>(HiveService.subjectsBoxName);
    HiveService.attendanceLogsBox = await Hive.openBox<AttendanceLog>(HiveService.attendanceLogsBoxName);
    HiveService.gradingSystemsBox = await Hive.openBox<GradingSystem>(HiveService.gradingSystemsBoxName);
    HiveService.semestersBox = await Hive.openBox<Semester>(HiveService.semestersBoxName);
    HiveService.assessmentsBox = await Hive.openBox<Assessment>(HiveService.assessmentsBoxName);

    // Seed default settings
    await HiveService.settingsBox.put('min_attendance', 75.0);
    await HiveService.settingsBox.put('selected_grading_system_id', '10_point');
  });

  testWidgets('App landing test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that our app name is visible in the App Bar / Title
    expect(find.text('Student Companion'), findsAtLeast(1));
  });
}
