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
