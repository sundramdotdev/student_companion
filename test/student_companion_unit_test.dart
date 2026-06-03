import 'package:flutter_test/flutter_test.dart';
import 'package:student_companion/features/bunk/domain/bunk_calculator.dart';
import 'package:student_companion/features/gpa/data/repositories/gpa_repository.dart';
import 'package:student_companion/features/gpa/domain/entities/grading_system.dart';
import 'package:student_companion/features/gpa/domain/entities/semester.dart';

void main() {
  group('Bunk Calculator Tests', () {
    test('Should return safe when attendance is above threshold', () {
      final result = BunkCalculator.calculate(
        present: 8,
        total: 10,
        requiredPercent: 75.0,
      );

      expect(result.currentPercentage, 80.0);
      expect(result.isSafe, true);
      expect(result.maxBunksAllowed, 0); // 8/11 = 72% which is below 75%, so max bunks is 0.
    });

    test('Should calculate correct bunks allowed for higher safety margin', () {
      final result = BunkCalculator.calculate(
        present: 9,
        total: 10,
        requiredPercent: 75.0,
      );

      expect(result.currentPercentage, 90.0);
      expect(result.isSafe, true);
      expect(result.maxBunksAllowed, 2); // 9/12 = 75% which is safe, 9/13 = 69% which is unsafe. So 2 bunks.
    });

    test('Should return correct recovery count when below threshold', () {
      final result = BunkCalculator.calculate(
        present: 5,
        total: 10,
        requiredPercent: 75.0,
      );

      expect(result.currentPercentage, 50.0);
      expect(result.isSafe, false);
      expect(result.recoveryClassesNeeded, 10); // (5+10)/(10+10) = 15/20 = 75%.
    });
  });

  group('GPA Goal Calculator Tests', () {
    final repo = GpaRepository();

    test('Should calculate correct future GPA needed to hit target', () {
      final requiredSgpa = repo.calculateRequiredFutureGPA(
        currentCGPA: 7.0,
        targetCGPA: 8.0,
        completedCredits: 30,
        remainingCredits: 15,
      );

      expect(requiredSgpa, 10.0); // 7*30 + 10*15 = 360 / 45 = 8.0
    });

    test('Should return null if remaining credits are zero', () {
      final requiredSgpa = repo.calculateRequiredFutureGPA(
        currentCGPA: 7.0,
        targetCGPA: 8.0,
        completedCredits: 30,
        remainingCredits: 0,
      );

      expect(requiredSgpa, isNull);
    });
  });

  group('SGPA/CGPA Calculation Tests', () {
    final repo = GpaRepository();
    final system = const GradingSystem(
      id: '10_point',
      name: '10-Point',
      maxPoints: 10.0,
      grades: {
        'O': 10.0,
        'A+': 9.0,
        'A': 8.0,
        'B': 7.0,
      },
    );

    test('Should calculate SGPA correctly for a list of entries', () {
      final semester = const Semester(
        id: 'sem1',
        name: 'Semester 1',
        subjects: [
          SGPAEntry(subjectName: 'Math', credits: 4, grade: 'O'), // 40
          SGPAEntry(subjectName: 'Physics', credits: 3, grade: 'A'), // 24
        ],
      );

      final sgpa = repo.calculateSGPA(semester, system);
      expect(sgpa, closeTo(9.14, 0.01)); // 64 / 7 = 9.1428
    });
  });
}
