// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameRound _$GameRoundFromJson(Map<String, dynamic> json) => _GameRound(
  (json['target'] as num).toDouble(),
  (json['measurements'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$GameRoundToJson(_GameRound instance) =>
    <String, dynamic>{
      'target': instance.target,
      'measurements': instance.measurements,
    };
