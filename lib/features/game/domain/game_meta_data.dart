import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_meta_data.freezed.dart';
part 'game_meta_data.g.dart';

@freezed
abstract class GameMetaData with _$GameMetaData {
  const GameMetaData._();

  const factory GameMetaData({
    required DateTime createdAt,
    DateTime? finishedAt,
  }) = _GameMetaData;

  factory GameMetaData.fromJson(Map<String, dynamic> json) =>
      _$GameMetaDataFromJson(json);

  bool get isFinished => finishedAt != null;
}
