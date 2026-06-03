import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
@HiveType(typeId: 0)
class Schedule with _$Schedule {
  const factory Schedule({
    @HiveField(0) required String dayOfWeek, // 'Monday', 'Tuesday', etc.
    @HiveField(1) required int startHour,
    @HiveField(2) required int startMinute,
    @HiveField(3) required int endHour,
    @HiveField(4) required int endMinute,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);
}
