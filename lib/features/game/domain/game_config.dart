enum GameMode { standard, points }

class GameConfig {
  final GameMode mode;

  const GameConfig({this.mode = GameMode.standard});
}
