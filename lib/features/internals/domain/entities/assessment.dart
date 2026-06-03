import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'assessment.freezed.dart';
part 'assessment.g.dart';

@freezed
@HiveType(typeId: 7)
class Assessment with _$Assessment {
  const factory Assessment({
    @HiveField(0) required String id,
    @HiveField(1) required String subjectId,
    @HiveField(2) required String name,
    @HiveField(3) required String type, // Assignment, Exam, Practical, etc.
    @HiveField(4) required double maxMarks,
    @HiveField(5) required double obtainedMarks,
    @HiveField(6) required double weightage, // e.g. 15 for 15%
    @HiveField(7) DateTime? dueDate,
  }) = _Assessment;

  factory Assessment.fromJson(Map<String, dynamic> json) => _$AssessmentFromJson(json);
}
