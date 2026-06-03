// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_system.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradingSystemAdapter extends TypeAdapter<GradingSystem> {
  @override
  final int typeId = 4;

  @override
  GradingSystem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradingSystem(
      id: fields[0] as String,
      name: fields[1] as String,
      grades: (fields[2] as Map).cast<String, double>(),
      maxPoints: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GradingSystem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.grades)
      ..writeByte(3)
      ..write(obj.maxPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradingSystemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GradingSystemImpl _$$GradingSystemImplFromJson(Map<String, dynamic> json) =>
    _$GradingSystemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      grades: (json['grades'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      maxPoints: (json['maxPoints'] as num).toDouble(),
    );

Map<String, dynamic> _$$GradingSystemImplToJson(_$GradingSystemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'grades': instance.grades,
      'maxPoints': instance.maxPoints,
    };
