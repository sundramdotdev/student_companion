// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grading_system.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GradingSystem _$GradingSystemFromJson(Map<String, dynamic> json) {
  return _GradingSystem.fromJson(json);
}

/// @nodoc
mixin _$GradingSystem {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  Map<String, double> get grades =>
      throw _privateConstructorUsedError; // e.g. {"A+": 10.0, "A": 9.0}
  @HiveField(3)
  double get maxPoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GradingSystemCopyWith<GradingSystem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradingSystemCopyWith<$Res> {
  factory $GradingSystemCopyWith(
          GradingSystem value, $Res Function(GradingSystem) then) =
      _$GradingSystemCopyWithImpl<$Res, GradingSystem>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) Map<String, double> grades,
      @HiveField(3) double maxPoints});
}

/// @nodoc
class _$GradingSystemCopyWithImpl<$Res, $Val extends GradingSystem>
    implements $GradingSystemCopyWith<$Res> {
  _$GradingSystemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? grades = null,
    Object? maxPoints = null,
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
      grades: null == grades
          ? _value.grades
          : grades // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      maxPoints: null == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GradingSystemImplCopyWith<$Res>
    implements $GradingSystemCopyWith<$Res> {
  factory _$$GradingSystemImplCopyWith(
          _$GradingSystemImpl value, $Res Function(_$GradingSystemImpl) then) =
      __$$GradingSystemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) Map<String, double> grades,
      @HiveField(3) double maxPoints});
}

/// @nodoc
class __$$GradingSystemImplCopyWithImpl<$Res>
    extends _$GradingSystemCopyWithImpl<$Res, _$GradingSystemImpl>
    implements _$$GradingSystemImplCopyWith<$Res> {
  __$$GradingSystemImplCopyWithImpl(
      _$GradingSystemImpl _value, $Res Function(_$GradingSystemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? grades = null,
    Object? maxPoints = null,
  }) {
    return _then(_$GradingSystemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      grades: null == grades
          ? _value._grades
          : grades // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      maxPoints: null == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GradingSystemImpl implements _GradingSystem {
  const _$GradingSystemImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required final Map<String, double> grades,
      @HiveField(3) required this.maxPoints})
      : _grades = grades;

  factory _$GradingSystemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradingSystemImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  final Map<String, double> _grades;
  @override
  @HiveField(2)
  Map<String, double> get grades {
    if (_grades is EqualUnmodifiableMapView) return _grades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_grades);
  }

// e.g. {"A+": 10.0, "A": 9.0}
  @override
  @HiveField(3)
  final double maxPoints;

  @override
  String toString() {
    return 'GradingSystem(id: $id, name: $name, grades: $grades, maxPoints: $maxPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradingSystemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._grades, _grades) &&
            (identical(other.maxPoints, maxPoints) ||
                other.maxPoints == maxPoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name,
      const DeepCollectionEquality().hash(_grades), maxPoints);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GradingSystemImplCopyWith<_$GradingSystemImpl> get copyWith =>
      __$$GradingSystemImplCopyWithImpl<_$GradingSystemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradingSystemImplToJson(
      this,
    );
  }
}

abstract class _GradingSystem implements GradingSystem {
  const factory _GradingSystem(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final Map<String, double> grades,
      @HiveField(3) required final double maxPoints}) = _$GradingSystemImpl;

  factory _GradingSystem.fromJson(Map<String, dynamic> json) =
      _$GradingSystemImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  Map<String, double> get grades;
  @override // e.g. {"A+": 10.0, "A": 9.0}
  @HiveField(3)
  double get maxPoints;
  @override
  @JsonKey(ignore: true)
  _$$GradingSystemImplCopyWith<_$GradingSystemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
