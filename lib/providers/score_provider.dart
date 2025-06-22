import 'package:bierwiegen/providers/game_round_provider.dart';
import 'package:bierwiegen/providers/player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_round.dart';
import '../models/player.dart';

class ScoreNotifier extends StateNotifier<List<int>> {
  ScoreNotifier(this.ref) : super([]) {
    ref.listen<List<Player>>(playerProvider, (previous, next) {
      _updateScores(next, ref.read(gameRoundProvider));
    });

    ref.listen<List<GameRound>>(gameRoundProvider, (previous, next) {
      _updateScores(ref.read(playerProvider), next);
    });
  }

  final Ref ref;

  void _updateScores(List<Player> players, List<GameRound> gameRounds) {
    final List<int> scoreList = players.map((e) => 0).toList();
    for (final gameRound in gameRounds) {
      if (!gameRound.isFinished) {
        continue;
      }

      for (int i = 0; i < players.length; i++) {
        if ((gameRound.measurements[i].value - gameRound.target).abs() ==
            gameRound.closestAbsValue) {
          // NOTE: when i implement settings for game it can be added here
          scoreList[i]++;
        }
      }
    }

    state = scoreList;
  }

  String get winners {
    if (winningPlayers.isEmpty) {
      return '';
    }

    if (winningPlayers.length == 1) {
      return winningPlayers.first.name;
    }

    if (winningPlayers.length == 2) {
      return '${winningPlayers[0].name} und ${winningPlayers[1].name}';
    }

    final allButLast = winningPlayers
        .sublist(0, winningPlayers.length - 1)
        .map((p) => p.name)
        .join(', ');
    return '$allButLast, und ${winningPlayers.last.name}';
  }

  List<Player> get winningPlayers {
    if (state.isEmpty) {
      return [];
    }

    final maxValue = state.reduce((a, b) => a > b ? a : b);
    final List<Player> indices = [];

    for (int i = 0; i < state.length; i++) {
      if (state[i] == maxValue) {
        indices.add(ref.read(playerProvider)[i]);
      }
    }

    return indices;
  }
}

final scoreProvider = StateNotifierProvider<ScoreNotifier, List<int>>(
  (ref) => ScoreNotifier(ref),
);
