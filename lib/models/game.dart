import 'package:bierwiegen/models/game_round.dart';

import 'game_meta_data.dart';
import 'player.dart';

class Game {
  final List<Player> players;
  final List<GameRound> gameRounds;
  final GameMetaData meta;

  Game({required this.players, required this.gameRounds, required this.meta});

  // NOTE: wenn es einstellungen für ein Spiel gibt müssen diese hier gespeichert werden
  // final GameOptions options;

  // NOTE: we should be able to display the winner of the game -> should be
  // automatically calculated from the player and the

  List<int> get scores {
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
    return scoreList;
  }

  Game copyWith({
    List<Player>? players,
    List<GameRound>? gameRounds,
    GameMetaData? meta,
  }) {
    return Game(
      players: players ?? this.players,
      gameRounds: gameRounds ?? this.gameRounds,
      meta: meta ?? this.meta,
    );
  }
}
