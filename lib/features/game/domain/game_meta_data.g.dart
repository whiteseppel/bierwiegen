// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_meta_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameMetaData _$GameMetaDataFromJson(Map<String, dynamic> json) =>
    _GameMetaData(
      createdAt: DateTime.parse(json['createdAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
    );

Map<String, dynamic> _$GameMetaDataToJson(_GameMetaData instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
    };
