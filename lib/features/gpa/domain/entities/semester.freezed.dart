// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'semester.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SGPAEntry _$SGPAEntryFromJson(Map<String, dynamic> json) {
  return _SGPAEntry.fromJson(json);
}

/// @nodoc
mixin _$SGPAEntry {
  @HiveField(0)
  String get subjectName => throw _privateConstructorUsedError;
  @HiveField(1)
  int get credits => throw _privateConstructorUsedError;
  @HiveField(2)
  String get grade => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SGPAEntryCopyWith<SGPAEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SGPAEntryCopyWith<$Res> {
  factory $SGPAEntryCopyWith(SGPAEntry value, $Res Function(SGPAEntry) then) =
      _$SGPAEntryCopyWithImpl<$Res, SGPAEntry>;
  @useResult
  $Res call(
      {@HiveField(0) String subjectName,
      @HiveField(1) int credits,
      @HiveField(2) String grade});
}

/// @nodoc
class _$SGPAEntryCopyWithImpl<$Res, $Val extends SGPAEntry>
    implements $SGPAEntryCopyWith<$Res> {
  _$SGPAEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? credits = null,
    Object? grade = null,
  }) {
    return _then(_value.copyWith(
      subjectName: null == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String,
      credits: null == credits
          ? _value.credits
          : credits // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SGPAEntryImplCopyWith<$Res>
    implements $SGPAEntryCopyWith<$Res> {
  factory _$$SGPAEntryImplCopyWith(
          _$SGPAEntryImpl value, $Res Function(_$SGPAEntryImpl) then) =
      __$$SGPAEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String subjectName,
      @HiveField(1) int credits,
      @HiveField(2) String grade});
}

/// @nodoc
class __$$SGPAEntryImplCopyWithImpl<$Res>
    extends _$SGPAEntryCopyWithImpl<$Res, _$SGPAEntryImpl>
    implements _$$SGPAEntryImplCopyWith<$Res> {
  __$$SGPAEntryImplCopyWithImpl(
      _$SGPAEntryImpl _value, $Res Function(_$SGPAEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? credits = null,
    Object? grade = null,
  }) {
    return _then(_$SGPAEntryImpl(
      subjectName: null == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String,
      credits: null == credits
          ? _value.credits
          : credits // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SGPAEntryImpl implements _SGPAEntry {
  const _$SGPAEntryImpl(
      {@HiveField(0) required this.subjectName,
      @HiveField(1) required this.credits,
      @HiveField(2) required this.grade});

  factory _$SGPAEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SGPAEntryImplFromJson(json);

  @override
  @HiveField(0)
  final String subjectName;
  @override
  @HiveField(1)
  final int credits;
  @override
  @HiveField(2)
  final String grade;

  @override
  String toString() {
    return 'SGPAEntry(subjectName: $subjectName, credits: $credits, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SGPAEntryImpl &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.credits, credits) || other.credits == credits) &&
            (identical(other.grade, grade) || other.grade == grade));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subjectName, credits, grade);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SGPAEntryImplCopyWith<_$SGPAEntryImpl> get copyWith =>
      __$$SGPAEntryImplCopyWithImpl<_$SGPAEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SGPAEntryImplToJson(
      this,
    );
  }
}

abstract class _SGPAEntry implements SGPAEntry {
  const factory _SGPAEntry(
      {@HiveField(0) required final String subjectName,
      @HiveField(1) required final int credits,
      @HiveField(2) required final String grade}) = _$SGPAEntryImpl;

  factory _SGPAEntry.fromJson(Map<String, dynamic> json) =
      _$SGPAEntryImpl.fromJson;

  @override
  @HiveField(0)
  String get subjectName;
  @override
  @HiveField(1)
  int get credits;
  @override
  @HiveField(2)
  String get grade;
  @override
  @JsonKey(ignore: true)
  _$$SGPAEntryImplCopyWith<_$SGPAEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Semester _$SemesterFromJson(Map<String, dynamic> json) {
  return _Semester.fromJson(json);
}

/// @nodoc
mixin _$Semester {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError; // e.g. "Semester 1"
  @HiveField(2)
  List<SGPAEntry> get subjects => throw _privateConstructorUsedError;
  @HiveField(3)
  double? get customGpa => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SemesterCopyWith<Semester> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SemesterCopyWith<$Res> {
  factory $SemesterCopyWith(Semester value, $Res Function(Semester) then) =
      _$SemesterCopyWithImpl<$Res, Semester>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) List<SGPAEntry> subjects,
      @HiveField(3) double? customGpa});
}

/// @nodoc
class _$SemesterCopyWithImpl<$Res, $Val extends Semester>
    implements $SemesterCopyWith<$Res> {
  _$SemesterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subjects = null,
    Object? customGpa = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<SGPAEntry>,
      customGpa: freezed == customGpa
          ? _value.customGpa
          : customGpa // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SemesterImplCopyWith<$Res>
    implements $SemesterCopyWith<$Res> {
  factory _$$SemesterImplCopyWith(
          _$SemesterImpl value, $Res Function(_$SemesterImpl) then) =
      __$$SemesterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) List<SGPAEntry> subjects,
      @HiveField(3) double? customGpa});
}

/// @nodoc
class __$$SemesterImplCopyWithImpl<$Res>
    extends _$SemesterCopyWithImpl<$Res, _$SemesterImpl>
    implements _$$SemesterImplCopyWith<$Res> {
  __$$SemesterImplCopyWithImpl(
      _$SemesterImpl _value, $Res Function(_$SemesterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subjects = null,
    Object? customGpa = freezed,
  }) {
    return _then(_$SemesterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<SGPAEntry>,
      customGpa: freezed == customGpa
          ? _value.customGpa
          : customGpa // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SemesterImpl implements _Semester {
  const _$SemesterImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required final List<SGPAEntry> subjects,
      @HiveField(3) this.customGpa})
      : _subjects = subjects;

  factory _$SemesterImpl.fromJson(Map<String, dynamic> json) =>
      _$$SemesterImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
// e.g. "Semester 1"
  final List<SGPAEntry> _subjects;
// e.g. "Semester 1"
  @override
  @HiveField(2)
  List<SGPAEntry> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @HiveField(3)
  final double? customGpa;

  @override
  String toString() {
    return 'Semester(id: $id, name: $name, subjects: $subjects, customGpa: $customGpa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SemesterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.customGpa, customGpa) ||
                other.customGpa == customGpa));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name,
      const DeepCollectionEquality().hash(_subjects), customGpa);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SemesterImplCopyWith<_$SemesterImpl> get copyWith =>
      __$$SemesterImplCopyWithImpl<_$SemesterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SemesterImplToJson(
      this,
    );
  }
}

abstract class _Semester implements Semester {
  const factory _Semester(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final List<SGPAEntry> subjects,
      @HiveField(3) final double? customGpa}) = _$SemesterImpl;

  factory _Semester.fromJson(Map<String, dynamic> json) =
      _$SemesterImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override // e.g. "Semester 1"
  @HiveField(2)
  List<SGPAEntry> get subjects;
  @override
  @HiveField(3)
  double? get customGpa;
  @override
  @JsonKey(ignore: true)
  _$$SemesterImplCopyWith<_$SemesterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
