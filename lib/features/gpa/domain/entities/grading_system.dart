import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'grading_system.freezed.dart';
part 'grading_system.g.dart';

@freezed
@HiveType(typeId: 4)
class GradingSystem with _$GradingSystem {
  const factory GradingSystem({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required Map<String, double> grades, // e.g. {"A+": 10.0, "A": 9.0}
    @HiveField(3) required double maxPoints, // e.g. 10.0 or 4.0
  }) = _GradingSystem;

  factory GradingSystem.fromJson(Map<String, dynamic> json) => _$GradingSystemFromJson(json);
}
