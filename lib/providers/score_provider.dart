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
}

final scoreProvider = StateNotifierProvider<ScoreNotifier, List<int>>(
  (ref) => ScoreNotifier(ref),
);
