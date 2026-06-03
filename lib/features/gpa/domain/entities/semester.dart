import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'semester.freezed.dart';
part 'semester.g.dart';

@freezed
@HiveType(typeId: 5)
class SGPAEntry with _$SGPAEntry {
  const factory SGPAEntry({
    @HiveField(0) required String subjectName,
    @HiveField(1) required int credits,
    @HiveField(2) required String grade, // letter grade
  }) = _SGPAEntry;

  factory SGPAEntry.fromJson(Map<String, dynamic> json) => _$SGPAEntryFromJson(json);
}

@freezed
@HiveType(typeId: 6)
class Semester with _$Semester {
  const factory Semester({
    @HiveField(0) required String id,
    @HiveField(1) required String name, // e.g. "Semester 1"
    @HiveField(2) required List<SGPAEntry> subjects,
    @HiveField(3) double? customGpa, // entered GPA directly
  }) = _Semester;

  factory Semester.fromJson(Map<String, dynamic> json) => _$SemesterFromJson(json);
}
