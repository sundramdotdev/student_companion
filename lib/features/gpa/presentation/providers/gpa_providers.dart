import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gpa_repository.dart';
import '../../domain/entities/grading_system.dart';
import '../../domain/entities/semester.dart';

final gpaRepositoryProvider = Provider<GpaRepository>((ref) {
  return GpaRepository();
});

class SemestersNotifier extends StateNotifier<List<Semester>> {
  final GpaRepository _repository;

  SemestersNotifier(this._repository) : super([]) {
    loadSemesters();
  }

  void loadSemesters() {
    state = _repository.getSemesters();
  }

  Future<void> addSemester(Semester semester) async {
    await _repository.saveSemester(semester);
    loadSemesters();
  }

  Future<void> updateSemester(Semester semester) async {
    await _repository.saveSemester(semester);
    loadSemesters();
  }

  Future<void> deleteSemester(String id) async {
    await _repository.deleteSemester(id);
    loadSemesters();
  }
}

final semestersProvider = StateNotifierProvider<SemestersNotifier, List<Semester>>((ref) {
  final repository = ref.watch(gpaRepositoryProvider);
  return SemestersNotifier(repository);
});

class GradingSystemsNotifier extends StateNotifier<List<GradingSystem>> {
  final GpaRepository _repository;

  GradingSystemsNotifier(this._repository) : super([]) {
    loadSystems();
  }

  void loadSystems() {
    state = _repository.getGradingSystems();
  }

  Future<void> addSystem(GradingSystem system) async {
    await _repository.saveGradingSystem(system);
    loadSystems();
  }

  Future<void> deleteSystem(String id) async {
    await _repository.deleteGradingSystem(id);
    loadSystems();
  }
}

final gradingSystemsProvider = StateNotifierProvider<GradingSystemsNotifier, List<GradingSystem>>((ref) {
  final repository = ref.watch(gpaRepositoryProvider);
  return GradingSystemsNotifier(repository);
});

class SelectedGradingSystemIdNotifier extends StateNotifier<String> {
  final GpaRepository _repository;

  SelectedGradingSystemIdNotifier(this._repository) : super('10_point') {
    state = _repository.getSelectedGradingSystemId();
  }

  Future<void> selectSystem(String id) async {
    await _repository.setSelectedGradingSystemId(id);
    state = id;
  }
}

final selectedGradingSystemIdProvider = StateNotifierProvider<SelectedGradingSystemIdNotifier, String>((ref) {
  final repository = ref.watch(gpaRepositoryProvider);
  return SelectedGradingSystemIdNotifier(repository);
});

final selectedGradingSystemProvider = Provider<GradingSystem>((ref) {
  final id = ref.watch(selectedGradingSystemIdProvider);
  final list = ref.watch(gradingSystemsProvider);
  return list.firstWhere(
    (sys) => sys.id == id,
    orElse: () => const GradingSystem(id: '10_point', name: '10-Point Scale (Standard)', maxPoints: 10.0, grades: {}),
  );
});

// Overall CGPA provider
final cgpaProvider = Provider<double>((ref) {
  final semesters = ref.watch(semestersProvider);
  final gradingSystem = ref.watch(selectedGradingSystemProvider);
  final repository = ref.read(gpaRepositoryProvider);
  return repository.calculateCGPA(semesters, gradingSystem);
});
