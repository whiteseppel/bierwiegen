import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game.dart';
import '../domain/game_config.dart';
import '../domain/game_meta_data.dart';
import '../domain/game_round.dart';
import '../domain/player.dart';
import '../domain/scoring.dart';

class GameNotifier extends StateNotifier<Game?> {
  GameNotifier() : super(null);

  void startGame(List<String> playerNames) {
    state = Game(
      players: [for (final name in playerNames) Player(name)],
      rounds: [],
      config: const GameConfig(),
      meta: GameMetaData(createdAt: DateTime.now()),
    );
  }

  void setInitialWeight(int playerIndex, double value) {
    final game = state;
    if (game == null) {
      return;
    }

    final players = [...game.players];
    players[playerIndex] = players[playerIndex].copyWith(initialWeight: value);
    state = game.copyWith(players: players);
  }

  void addRound(double target) {
    final game = state;
    if (game == null) {
      return;
    }

    state = game.copyWith(
      rounds: [
        ...game.rounds,
        GameRound(target, List.filled(game.players.length, 0)),
      ],
    );
  }

  void removeLastRound() {
    final game = state;
    if (game == null || game.rounds.isEmpty) {
      return;
    }

    state = game.copyWith(
      rounds: game.rounds.sublist(0, game.rounds.length - 1),
    );
  }

  void setMeasurement(int roundIndex, int playerIndex, double value) {
    final game = state;
    if (game == null) {
      return;
    }

    final rounds = [...game.rounds];
    final round = rounds[roundIndex];
    final measurements = [...round.measurements];
    measurements[playerIndex] = value;
    rounds[roundIndex] = GameRound(round.target, measurements);
    state = game.copyWith(rounds: rounds);
  }

  void updateTarget(int roundIndex, double target) {
    final game = state;
    if (game == null) {
      return;
    }

    final rounds = [...game.rounds];
    rounds[roundIndex] = GameRound(target, rounds[roundIndex].measurements);
    state = game.copyWith(rounds: rounds);
  }

  void setMode(GameMode mode) {
    final game = state;
    if (game == null) {
      return;
    }

    state = game.copyWith(config: game.config.copyWith(mode: mode));
  }

  void setTargetMode(TargetMode targetMode) {
    final game = state;
    if (game == null) {
      return;
    }

    state = game.copyWith(config: game.config.copyWith(targetMode: targetMode));
  }

  void finishGame() {
    final game = state;
    if (game == null) {
      return;
    }

    state = game.copyWith(meta: game.meta.copyWith(finishedAt: DateTime.now()));
  }

  void resetForNewGame() {
    state = null;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, Game?>(
  (ref) => GameNotifier(),
);

final scoresProvider = Provider<List<int>>((ref) {
  final game = ref.watch(gameProvider);
  return game == null ? const [] : calculateScores(game);
});

final winningPlayersProvider = Provider<List<Player>>((ref) {
  final game = ref.watch(gameProvider);
  final scores = ref.watch(scoresProvider);
  if (game == null || scores.isEmpty) {
    return const [];
  }

  final maxScore = scores.reduce((a, b) => a > b ? a : b);
  return [
    for (int i = 0; i < scores.length; i++)
      if (scores[i] == maxScore) game.players[i],
  ];
});
