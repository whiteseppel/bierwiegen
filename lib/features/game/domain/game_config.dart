enum GameMode { standard, points }

/// How each round's target weight is chosen.
enum TargetMode { manual, auto }

class GameConfig {
  final GameMode mode;
  final TargetMode targetMode;

  const GameConfig({
    this.mode = GameMode.standard,
    this.targetMode = TargetMode.manual,
  });

  GameConfig copyWith({GameMode? mode, TargetMode? targetMode}) => GameConfig(
        mode: mode ?? this.mode,
        targetMode: targetMode ?? this.targetMode,
      );
}
