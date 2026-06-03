// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssessmentAdapter extends TypeAdapter<Assessment> {
  @override
  final int typeId = 7;

  @override
  Assessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assessment(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as String,
      maxMarks: fields[4] as double,
      obtainedMarks: fields[5] as double,
      weightage: fields[6] as double,
      dueDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Assessment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.maxMarks)
      ..writeByte(5)
      ..write(obj.obtainedMarks)
      ..writeByte(6)
      ..write(obj.weightage)
      ..writeByte(7)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssessmentImpl _$$AssessmentImplFromJson(Map<String, dynamic> json) =>
    _$AssessmentImpl(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      maxMarks: (json['maxMarks'] as num).toDouble(),
      obtainedMarks: (json['obtainedMarks'] as num).toDouble(),
      weightage: (json['weightage'] as num).toDouble(),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
    );

Map<String, dynamic> _$$AssessmentImplToJson(_$AssessmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'name': instance.name,
      'type': instance.type,
      'maxMarks': instance.maxMarks,
      'obtainedMarks': instance.obtainedMarks,
      'weightage': instance.weightage,
      'dueDate': instance.dueDate?.toIso8601String(),
    };
