// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../screens/main_screen/patient_screens/log_infusion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InfusionLogAdapter extends TypeAdapter<InfusionLog> {
  @override
  final int typeId = 1;

  @override
  InfusionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InfusionLog(
      medication: fields[0] as String,
      doseIU: fields[1] as int,
      date: fields[2] as String,
      time: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InfusionLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.medication)
      ..writeByte(1)
      ..write(obj.doseIU)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfusionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
