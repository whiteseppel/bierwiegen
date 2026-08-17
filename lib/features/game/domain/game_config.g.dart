// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => _GameConfig(
  mode:
      $enumDecodeNullable(_$GameModeEnumMap, json['mode']) ?? GameMode.standard,
  targetMode:
      $enumDecodeNullable(_$TargetModeEnumMap, json['targetMode']) ??
      TargetMode.auto,
);

Map<String, dynamic> _$GameConfigToJson(_GameConfig instance) =>
    <String, dynamic>{
      'mode': _$GameModeEnumMap[instance.mode]!,
      'targetMode': _$TargetModeEnumMap[instance.targetMode]!,
    };

const _$GameModeEnumMap = {
  GameMode.standard: 'standard',
  GameMode.points: 'points',
};

const _$TargetModeEnumMap = {
  TargetMode.manual: 'manual',
  TargetMode.auto: 'auto',
};
