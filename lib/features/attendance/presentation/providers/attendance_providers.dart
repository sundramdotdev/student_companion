import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/attendance_log.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  final AttendanceRepository _repository;

  SubjectsNotifier(this._repository) : super([]) {
    loadSubjects();
  }

  void loadSubjects() {
    state = _repository.getSubjects();
  }

  Future<void> addSubject(Subject subject) async {
    await _repository.saveSubject(subject);
    loadSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await _repository.saveSubject(subject);
    loadSubjects();
  }

  Future<void> deleteSubject(String id) async {
    await _repository.deleteSubject(id);
    loadSubjects();
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return SubjectsNotifier(repository);
});

class AttendanceLogsNotifier extends StateNotifier<List<AttendanceLog>> {
  final AttendanceRepository _repository;

  AttendanceLogsNotifier(this._repository) : super([]) {
    loadLogs();
  }

  void loadLogs() {
    state = _repository.getAttendanceLogs();
  }

  Future<void> logAttendance(AttendanceLog log) async {
    await _repository.saveAttendanceLog(log);
    loadLogs();
  }

  Future<void> deleteLog(String logId) async {
    await _repository.deleteAttendanceLog(logId);
    loadLogs();
  }

  Future<void> updateLog(AttendanceLog log) async {
    await _repository.saveAttendanceLog(log);
    loadLogs();
  }
}

final attendanceLogsProvider = StateNotifierProvider<AttendanceLogsNotifier, List<AttendanceLog>>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceLogsNotifier(repository);
});

// A provider that calculates the stats helper
final subjectStatsProvider = Provider.family<Map<String, dynamic>, Subject>((ref, subject) {
  // Listen to changes in logs provider
  ref.watch(attendanceLogsProvider);
  final repository = ref.read(attendanceRepositoryProvider);
  return repository.calculateAttendanceStats(subject);
});
