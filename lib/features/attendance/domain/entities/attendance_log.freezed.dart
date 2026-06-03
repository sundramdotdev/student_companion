// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AttendanceLog _$AttendanceLogFromJson(Map<String, dynamic> json) {
  return _AttendanceLog.fromJson(json);
}

/// @nodoc
mixin _$AttendanceLog {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get subjectId => throw _privateConstructorUsedError;
  @HiveField(2)
  DateTime get dateTime => throw _privateConstructorUsedError;
  @HiveField(3)
  AttendanceStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AttendanceLogCopyWith<AttendanceLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceLogCopyWith<$Res> {
  factory $AttendanceLogCopyWith(
          AttendanceLog value, $Res Function(AttendanceLog) then) =
      _$AttendanceLogCopyWithImpl<$Res, AttendanceLog>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String subjectId,
      @HiveField(2) DateTime dateTime,
      @HiveField(3) AttendanceStatus status});
}

/// @nodoc
class _$AttendanceLogCopyWithImpl<$Res, $Val extends AttendanceLog>
    implements $AttendanceLogCopyWith<$Res> {
  _$AttendanceLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? dateTime = null,
    Object? status = null,
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
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AttendanceStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceLogImplCopyWith<$Res>
    implements $AttendanceLogCopyWith<$Res> {
  factory _$$AttendanceLogImplCopyWith(
          _$AttendanceLogImpl value, $Res Function(_$AttendanceLogImpl) then) =
      __$$AttendanceLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String subjectId,
      @HiveField(2) DateTime dateTime,
      @HiveField(3) AttendanceStatus status});
}

/// @nodoc
class __$$AttendanceLogImplCopyWithImpl<$Res>
    extends _$AttendanceLogCopyWithImpl<$Res, _$AttendanceLogImpl>
    implements _$$AttendanceLogImplCopyWith<$Res> {
  __$$AttendanceLogImplCopyWithImpl(
      _$AttendanceLogImpl _value, $Res Function(_$AttendanceLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? dateTime = null,
    Object? status = null,
  }) {
    return _then(_$AttendanceLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AttendanceStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceLogImpl implements _AttendanceLog {
  const _$AttendanceLogImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.subjectId,
      @HiveField(2) required this.dateTime,
      @HiveField(3) required this.status});

  factory _$AttendanceLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceLogImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String subjectId;
  @override
  @HiveField(2)
  final DateTime dateTime;
  @override
  @HiveField(3)
  final AttendanceStatus status;

  @override
  String toString() {
    return 'AttendanceLog(id: $id, subjectId: $subjectId, dateTime: $dateTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, subjectId, dateTime, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceLogImplCopyWith<_$AttendanceLogImpl> get copyWith =>
      __$$AttendanceLogImplCopyWithImpl<_$AttendanceLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceLogImplToJson(
      this,
    );
  }
}

abstract class _AttendanceLog implements AttendanceLog {
  const factory _AttendanceLog(
          {@HiveField(0) required final String id,
          @HiveField(1) required final String subjectId,
          @HiveField(2) required final DateTime dateTime,
          @HiveField(3) required final AttendanceStatus status}) =
      _$AttendanceLogImpl;

  factory _AttendanceLog.fromJson(Map<String, dynamic> json) =
      _$AttendanceLogImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get subjectId;
  @override
  @HiveField(2)
  DateTime get dateTime;
  @override
  @HiveField(3)
  AttendanceStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$AttendanceLogImplCopyWith<_$AttendanceLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
