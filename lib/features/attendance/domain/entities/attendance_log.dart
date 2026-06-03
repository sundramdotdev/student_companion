import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'attendance_log.freezed.dart';
part 'attendance_log.g.dart';

@HiveType(typeId: 2)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  cancelled,
}

@freezed
@HiveType(typeId: 3)
class AttendanceLog with _$AttendanceLog {
  const factory AttendanceLog({
    @HiveField(0) required String id,
    @HiveField(1) required String subjectId,
    @HiveField(2) required DateTime dateTime,
    @HiveField(3) required AttendanceStatus status,
  }) = _AttendanceLog;

  factory AttendanceLog.fromJson(Map<String, dynamic> json) => _$AttendanceLogFromJson(json);
}
