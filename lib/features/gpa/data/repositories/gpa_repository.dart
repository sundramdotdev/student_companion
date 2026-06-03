import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/grading_system.dart';
import '../../domain/entities/semester.dart';

class GpaRepository {
  List<Semester> getSemesters() {
    return HiveService.semestersBox.values.toList();
  }

  Future<void> saveSemester(Semester semester) async {
    await HiveService.semestersBox.put(semester.id, semester);
  }

  Future<void> deleteSemester(String id) async {
    await HiveService.semestersBox.delete(id);
  }

  List<GradingSystem> getGradingSystems() {
    return HiveService.gradingSystemsBox.values.toList();
  }

  Future<void> saveGradingSystem(GradingSystem system) async {
    await HiveService.gradingSystemsBox.put(system.id, system);
  }

  Future<void> deleteGradingSystem(String id) async {
    // Prevent deleting default standard systems
    if (id == '10_point' || id == '4_point') return;
    await HiveService.gradingSystemsBox.delete(id);
  }

  String getSelectedGradingSystemId() {
    return HiveService.settingsBox.get('selected_grading_system_id', defaultValue: '10_point');
  }

  Future<void> setSelectedGradingSystemId(String id) async {
    await HiveService.settingsBox.put('selected_grading_system_id', id);
  }

  // Calculate SGPA for a semester
  double calculateSGPA(Semester semester, GradingSystem gradingSystem) {
    if (semester.customGpa != null) return semester.customGpa!;
    if (semester.subjects.isEmpty) return 0.0;

    double totalWeightedPoints = 0.0;
    int totalCredits = 0;

    for (final subject in semester.subjects) {
      final gradePoints = gradingSystem.grades[subject.grade.toUpperCase()];
      if (gradePoints != null) {
        totalWeightedPoints += gradePoints * subject.credits;
        totalCredits += subject.credits;
      }
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedPoints / totalCredits;
  }

  // Calculate overall CGPA
  double calculateCGPA(List<Semester> semesters, GradingSystem gradingSystem) {
    if (semesters.isEmpty) return 0.0;

    double totalWeightedGpa = 0.0;
    int totalCredits = 0;

    for (final semester in semesters) {
      final double sgpa = calculateSGPA(semester, gradingSystem);
      final int semCredits = semester.customGpa != null 
          ? 15 // Default credits fallback if custom GPA is entered directly
          : semester.subjects.fold<int>(0, (sum, sub) => sum + sub.credits);

      if (semCredits > 0) {
        totalWeightedGpa += sgpa * semCredits;
        totalCredits += semCredits;
      }
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedGpa / totalCredits;
  }

  // GPA Goal Calculator
  // Formula: targetCGPA = (currentCGPA * completedCredits + requiredGPA * remainingCredits) / (completedCredits + remainingCredits)
  // targetCGPA * (completed + remaining) = current * completed + required * remaining
  // required * remaining = target * (completed + remaining) - current * completed
  // required = (target * (completed + remaining) - current * completed) / remaining
  double? calculateRequiredFutureGPA({
    required double currentCGPA,
    required double targetCGPA,
    required int completedCredits,
    required int remainingCredits,
  }) {
    if (remainingCredits <= 0) return null;
    final totalCredits = completedCredits + remainingCredits;
    final requiredGPA = ((targetCGPA * totalCredits) - (currentCGPA * completedCredits)) / remainingCredits;
    return requiredGPA;
  }
}
