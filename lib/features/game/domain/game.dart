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

  /// True once a new round can be added: every initial weight is in and either
  /// no round has started yet or the current one is fully weighed.
  bool get canStartNewRound =>
      allPlayersWeighedIn && (rounds.isEmpty || rounds.last.isFinished);

  bool get hasFinishedRound => rounds.any((r) => r.isFinished);

  bool get hasAnyMeasurement =>
      rounds.any((r) => r.measurements.any((m) => m != 0));

  /// A glass under this weight (grams) ends the game.
  static const double finishThreshold = 50;

  /// Player's most recently entered measurement across all rounds; null when
  /// they have not been weighed in any round yet.
  double? lastMeasurement(int playerIndex) {
    for (int i = rounds.length - 1; i >= 0; i--) {
      final measurement = rounds[i].measurements[playerIndex];
      if (measurement != 0) {
        return measurement;
      }
    }
    return null;
  }

  /// Players whose glass has dropped below [finishThreshold]; their presence
  /// ends the game.
  List<Player> get finishers => [
        for (int i = 0; i < players.length; i++)
          if ((lastMeasurement(i) ?? double.infinity) < finishThreshold)
            players[i],
      ];

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
