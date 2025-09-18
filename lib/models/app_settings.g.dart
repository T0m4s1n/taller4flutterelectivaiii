// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      themeName: fields[1] as String,
      fontSize: fields[2] as double,
      language: fields[3] as String,
      notificationsEnabled: fields[4] as bool,
      lastLoggedInUserId: fields[5] as String?,
      rememberLogin: fields[6] as bool,
      backgroundPattern: fields[7] as String?,
      chatBubbleRadius: fields[8] as double,
      soundEnabled: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.themeName)
      ..writeByte(2)
      ..write(obj.fontSize)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.lastLoggedInUserId)
      ..writeByte(6)
      ..write(obj.rememberLogin)
      ..writeByte(7)
      ..write(obj.backgroundPattern)
      ..writeByte(8)
      ..write(obj.chatBubbleRadius)
      ..writeByte(9)
      ..write(obj.soundEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
