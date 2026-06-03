import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/internals_repository.dart';
import '../../domain/entities/assessment.dart';

final internalsRepositoryProvider = Provider<InternalsRepository>((ref) {
  return InternalsRepository();
});

class AssessmentsNotifier extends StateNotifier<List<Assessment>> {
  final InternalsRepository _repository;

  AssessmentsNotifier(this._repository) : super([]) {
    loadAssessments();
  }

  void loadAssessments() {
    state = _repository.getAssessments();
  }

  Future<void> addAssessment(Assessment assessment) async {
    await _repository.saveAssessment(assessment);
    loadAssessments();
  }

  Future<void> deleteAssessment(String id) async {
    await _repository.deleteAssessment(id);
    loadAssessments();
  }

  Future<void> updateAssessment(Assessment assessment) async {
    await _repository.saveAssessment(assessment);
    loadAssessments();
  }
}

final assessmentsProvider = StateNotifierProvider<AssessmentsNotifier, List<Assessment>>((ref) {
  final repository = ref.watch(internalsRepositoryProvider);
  return AssessmentsNotifier(repository);
});

// A provider that calculates the stats for a subject's assessments
final subjectInternalsStatsProvider = Provider.family<Map<String, dynamic>, String>((ref, subjectId) {
  ref.watch(assessmentsProvider); // watch to trigger rebuilds
  final repository = ref.read(internalsRepositoryProvider);
  return repository.calculateSubjectInternalStats(subjectId);
});
