// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  rounds: (json['rounds'] as List<dynamic>)
      .map((e) => GameRound.fromJson(e as Map<String, dynamic>))
      .toList(),
  config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
  meta: GameMetaData.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'players': instance.players.map((e) => e.toJson()).toList(),
  'rounds': instance.rounds.map((e) => e.toJson()).toList(),
  'config': instance.config.toJson(),
  'meta': instance.meta.toJson(),
};
