import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

enum GameMode { standard, points }

/// How each round's target weight is chosen.
enum TargetMode { manual, auto }

@freezed
abstract class GameConfig with _$GameConfig {
  const factory GameConfig({
    @Default(GameMode.standard) GameMode mode,
    @Default(TargetMode.auto) TargetMode targetMode,
  }) = _GameConfig;

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);
}
