import 'package:bierwiegen/models/game_round.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'game_round_provider.dart';
import 'player_provider.dart';

// NOTE: currently not used - keep here for later
class CurrentGameNotifier extends StateNotifier<Game?> {
  CurrentGameNotifier(this.ref) : super(null) {
    ref.listen<List<Player>>(playerProvider, (previous, next) {
      _updateScores(next, ref.read(gameRoundProvider));
    });

    ref.listen<List<GameRound>>(gameRoundProvider, (previous, next) {
      _updateScores(ref.read(playerProvider), next);
    });
  }
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
  }

  final Ref ref;

  updateGame(Game game) {
    state = game;
  }

  void forceRefresh() {
    state = state;
  }
}

final currentGameProvider = StateNotifierProvider<CurrentGameNotifier, Game?>(
  (ref) => CurrentGameNotifier(ref),
);
