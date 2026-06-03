// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Assessment _$AssessmentFromJson(Map<String, dynamic> json) {
  return _Assessment.fromJson(json);
}

/// @nodoc
mixin _$Assessment {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get subjectId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get name => throw _privateConstructorUsedError;
  @HiveField(3)
  String get type =>
      throw _privateConstructorUsedError; // Assignment, Exam, Practical, etc.
  @HiveField(4)
  double get maxMarks => throw _privateConstructorUsedError;
  @HiveField(5)
  double get obtainedMarks => throw _privateConstructorUsedError;
  @HiveField(6)
  double get weightage => throw _privateConstructorUsedError; // e.g. 15 for 15%
  @HiveField(7)
  DateTime? get dueDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentCopyWith<Assessment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentCopyWith<$Res> {
  factory $AssessmentCopyWith(
          Assessment value, $Res Function(Assessment) then) =
      _$AssessmentCopyWithImpl<$Res, Assessment>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String subjectId,
      @HiveField(2) String name,
      @HiveField(3) String type,
      @HiveField(4) double maxMarks,
      @HiveField(5) double obtainedMarks,
      @HiveField(6) double weightage,
      @HiveField(7) DateTime? dueDate});
}

/// @nodoc
class _$AssessmentCopyWithImpl<$Res, $Val extends Assessment>
    implements $AssessmentCopyWith<$Res> {
  _$AssessmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? name = null,
    Object? type = null,
    Object? maxMarks = null,
    Object? obtainedMarks = null,
    Object? weightage = null,
    Object? dueDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      maxMarks: null == maxMarks
          ? _value.maxMarks
          : maxMarks // ignore: cast_nullable_to_non_nullable
              as double,
      obtainedMarks: null == obtainedMarks
          ? _value.obtainedMarks
          : obtainedMarks // ignore: cast_nullable_to_non_nullable
              as double,
      weightage: null == weightage
          ? _value.weightage
          : weightage // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentImplCopyWith<$Res>
    implements $AssessmentCopyWith<$Res> {
  factory _$$AssessmentImplCopyWith(
          _$AssessmentImpl value, $Res Function(_$AssessmentImpl) then) =
      __$$AssessmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String subjectId,
      @HiveField(2) String name,
      @HiveField(3) String type,
      @HiveField(4) double maxMarks,
      @HiveField(5) double obtainedMarks,
      @HiveField(6) double weightage,
      @HiveField(7) DateTime? dueDate});
}

/// @nodoc
class __$$AssessmentImplCopyWithImpl<$Res>
    extends _$AssessmentCopyWithImpl<$Res, _$AssessmentImpl>
    implements _$$AssessmentImplCopyWith<$Res> {
  __$$AssessmentImplCopyWithImpl(
      _$AssessmentImpl _value, $Res Function(_$AssessmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? name = null,
    Object? type = null,
    Object? maxMarks = null,
    Object? obtainedMarks = null,
    Object? weightage = null,
    Object? dueDate = freezed,
  }) {
    return _then(_$AssessmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      maxMarks: null == maxMarks
          ? _value.maxMarks
          : maxMarks // ignore: cast_nullable_to_non_nullable
              as double,
      obtainedMarks: null == obtainedMarks
          ? _value.obtainedMarks
          : obtainedMarks // ignore: cast_nullable_to_non_nullable
              as double,
      weightage: null == weightage
          ? _value.weightage
          : weightage // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentImpl implements _Assessment {
  const _$AssessmentImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.subjectId,
      @HiveField(2) required this.name,
      @HiveField(3) required this.type,
      @HiveField(4) required this.maxMarks,
      @HiveField(5) required this.obtainedMarks,
      @HiveField(6) required this.weightage,
      @HiveField(7) this.dueDate});

  factory _$AssessmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String subjectId;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final String type;
// Assignment, Exam, Practical, etc.
  @override
  @HiveField(4)
  final double maxMarks;
  @override
  @HiveField(5)
  final double obtainedMarks;
  @override
  @HiveField(6)
  final double weightage;
// e.g. 15 for 15%
  @override
  @HiveField(7)
  final DateTime? dueDate;

  @override
  String toString() {
    return 'Assessment(id: $id, subjectId: $subjectId, name: $name, type: $type, maxMarks: $maxMarks, obtainedMarks: $obtainedMarks, weightage: $weightage, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.maxMarks, maxMarks) ||
                other.maxMarks == maxMarks) &&
            (identical(other.obtainedMarks, obtainedMarks) ||
                other.obtainedMarks == obtainedMarks) &&
            (identical(other.weightage, weightage) ||
                other.weightage == weightage) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, subjectId, name, type,
      maxMarks, obtainedMarks, weightage, dueDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentImplCopyWith<_$AssessmentImpl> get copyWith =>
      __$$AssessmentImplCopyWithImpl<_$AssessmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentImplToJson(
      this,
    );
  }
}

abstract class _Assessment implements Assessment {
  const factory _Assessment(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String subjectId,
      @HiveField(2) required final String name,
      @HiveField(3) required final String type,
      @HiveField(4) required final double maxMarks,
      @HiveField(5) required final double obtainedMarks,
      @HiveField(6) required final double weightage,
      @HiveField(7) final DateTime? dueDate}) = _$AssessmentImpl;

  factory _Assessment.fromJson(Map<String, dynamic> json) =
      _$AssessmentImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get subjectId;
  @override
  @HiveField(2)
  String get name;
  @override
  @HiveField(3)
  String get type;
  @override // Assignment, Exam, Practical, etc.
  @HiveField(4)
  double get maxMarks;
  @override
  @HiveField(5)
  double get obtainedMarks;
  @override
  @HiveField(6)
  double get weightage;
  @override // e.g. 15 for 15%
  @HiveField(7)
  DateTime? get dueDate;
  @override
  @JsonKey(ignore: true)
  _$$AssessmentImplCopyWith<_$AssessmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
