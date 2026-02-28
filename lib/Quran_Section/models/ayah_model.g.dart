// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahModelAdapter extends TypeAdapter<AyahModel> {
  @override
  final int typeId = 1;

  @override
  AyahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahModel(
      number: fields[0] as int,
      numberInSurah: fields[1] as int,
      text: fields[2] as String,
      page: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AyahModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.numberInSurah)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.page);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
