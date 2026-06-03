// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SGPAEntryAdapter extends TypeAdapter<SGPAEntry> {
  @override
  final int typeId = 5;

  @override
  SGPAEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SGPAEntry(
      subjectName: fields[0] as String,
      credits: fields[1] as int,
      grade: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SGPAEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.subjectName)
      ..writeByte(1)
      ..write(obj.credits)
      ..writeByte(2)
      ..write(obj.grade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SGPAEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SemesterAdapter extends TypeAdapter<Semester> {
  @override
  final int typeId = 6;

  @override
  Semester read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Semester(
      id: fields[0] as String,
      name: fields[1] as String,
      subjects: (fields[2] as List).cast<SGPAEntry>(),
      customGpa: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Semester obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subjects)
      ..writeByte(3)
      ..write(obj.customGpa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SGPAEntryImpl _$$SGPAEntryImplFromJson(Map<String, dynamic> json) =>
    _$SGPAEntryImpl(
      subjectName: json['subjectName'] as String,
      credits: (json['credits'] as num).toInt(),
      grade: json['grade'] as String,
    );

Map<String, dynamic> _$$SGPAEntryImplToJson(_$SGPAEntryImpl instance) =>
    <String, dynamic>{
      'subjectName': instance.subjectName,
      'credits': instance.credits,
      'grade': instance.grade,
    };

_$SemesterImpl _$$SemesterImplFromJson(Map<String, dynamic> json) =>
    _$SemesterImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => SGPAEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      customGpa: (json['customGpa'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SemesterImplToJson(_$SemesterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subjects': instance.subjects,
      'customGpa': instance.customGpa,
    };
