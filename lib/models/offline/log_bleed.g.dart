// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../screens/main_screen/patient_screens/log_bleed.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BleedLogAdapter extends TypeAdapter<BleedLog> {
  @override
  final int typeId = 0;

  @override
  BleedLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BleedLog(
      date: fields[0] as String,
      time: fields[1] as String,
      bodyRegion: fields[2] as String,
      severity: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BleedLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.bodyRegion)
      ..writeByte(3)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleedLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
