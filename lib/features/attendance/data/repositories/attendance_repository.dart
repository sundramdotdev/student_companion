import '../../../../core/storage/hive_service.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/attendance_log.dart';

class AttendanceRepository {
  final NotificationService _notificationService;

  AttendanceRepository({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  List<Subject> getSubjects() {
    return HiveService.subjectsBox.values.toList();
  }

  Future<void> saveSubject(Subject subject) async {
    await HiveService.subjectsBox.put(subject.id, subject);
    await syncNotifications();
  }

  Future<void> deleteSubject(String id) async {
    await HiveService.subjectsBox.delete(id);
    // Delete associated logs
    final logsToDelete = HiveService.attendanceLogsBox.values
        .where((log) => log.subjectId == id)
        .map((log) => log.id)
        .toList();
    for (final logId in logsToDelete) {
      await HiveService.attendanceLogsBox.delete(logId);
    }
    await syncNotifications();
  }

  List<AttendanceLog> getAttendanceLogs() {
    return HiveService.attendanceLogsBox.values.toList();
  }

  List<AttendanceLog> getAttendanceLogsForSubject(String subjectId) {
    return HiveService.attendanceLogsBox.values
        .where((log) => log.subjectId == subjectId)
        .toList();
  }

  Future<void> saveAttendanceLog(AttendanceLog log) async {
    await HiveService.attendanceLogsBox.put(log.id, log);
    await checkLowAttendanceAlert(log.subjectId);
  }

  Future<void> deleteAttendanceLog(String logId) async {
    final log = HiveService.attendanceLogsBox.get(logId);
    if (log != null) {
      final subjectId = log.subjectId;
      await HiveService.attendanceLogsBox.delete(logId);
      await checkLowAttendanceAlert(subjectId);
    }
  }

  Future<void> syncNotifications() async {
    final subjects = getSubjects();
    await _notificationService.scheduleTimetableNotifications(subjects);
  }

  Future<void> checkLowAttendanceAlert(String subjectId) async {
    final subject = HiveService.subjectsBox.get(subjectId);
    if (subject == null) return;

    final logs = getAttendanceLogsForSubject(subjectId);
    if (logs.isEmpty) return;

    final presentCount = logs.where((l) => l.status == AttendanceStatus.present).length;
    final totalCount = logs.where((l) => l.status != AttendanceStatus.cancelled).length;

    if (totalCount == 0) return;

    final percentage = (presentCount / totalCount) * 100;
    if (percentage < subject.minAttendancePercent) {
      await _notificationService.showImmediateAlert(
        id: subjectId.hashCode,
        title: 'Low Attendance Alert',
        body: 'Your ${subject.name} attendance dropped below ${subject.minAttendancePercent.toStringAsFixed(0)}% (Current: ${percentage.toStringAsFixed(1)}%).',
      );
    }
  }

  // Helper calculation functions for the Bunk module and Attendance Dashboard
  Map<String, dynamic> calculateAttendanceStats(Subject subject) {
    final logs = getAttendanceLogsForSubject(subject.id);
    final present = logs.where((l) => l.status == AttendanceStatus.present).length;
    final absent = logs.where((l) => l.status == AttendanceStatus.absent).length;
    final total = logs.where((l) => l.status != AttendanceStatus.cancelled).length;

    final percent = total == 0 ? 100.0 : (present / total) * 100.0;

    return {
      'present': present,
      'absent': absent,
      'total': total,
      'percentage': percent,
    };
  }
}
