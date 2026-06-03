import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'schedule.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
@HiveType(typeId: 1)
class Subject with _$Subject {
  const factory Subject({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) String? facultyName,
    @HiveField(3) required double minAttendancePercent,
    @HiveField(4) required int creditHours,
    @HiveField(5) required List<Schedule> schedules,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);
}
