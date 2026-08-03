import 'game_config.dart';
import 'game_meta_data.dart';
import 'game_round.dart';
import 'player.dart';

class Game {
  final List<Player> players;
  final List<GameRound> rounds;
  final GameConfig config;
  final GameMetaData meta;

  const Game({
    required this.players,
    required this.rounds,
    required this.config,
    required this.meta,
  });

  bool get isFinished => meta.isFinished;

  bool get allPlayersWeighedIn => players.every((p) => p.hasWeighedIn);

  bool get hasFinishedRound => rounds.any((r) => r.isFinished);

  /// Weight the player's glass had before [roundIndex]: the last entered
  /// measurement of an earlier round, else the initial weight; null when
  /// nothing was entered yet.
  double? previousWeight(int roundIndex, int playerIndex) {
    for (int i = roundIndex - 1; i >= 0; i--) {
      final measurement = rounds[i].measurements[playerIndex];
      if (measurement != 0) {
        return measurement;
      }
    }

    final initial = players[playerIndex].initialWeight;
    return initial != 0 ? initial : null;
  }

  Game copyWith({
    List<Player>? players,
    List<GameRound>? rounds,
    GameConfig? config,
    GameMetaData? meta,
  }) {
    return Game(
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      config: config ?? this.config,
      meta: meta ?? this.meta,
    );
  }
}
