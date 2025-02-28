import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_round.dart';
import '../models/player.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  PlayerNotifier() : super([]);

  void addPlayer(Player player) {
    state = [...state, player];
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>(
    (ref) => PlayerNotifier());

class GameRoundNotifier extends StateNotifier<List<GameRound>> {
  GameRoundNotifier() : super([]);

  void addRound(GameRound round) {
    state = [...state, round];
  }
}

final gameRoundProvider =
    StateNotifierProvider<GameRoundNotifier, List<GameRound>>(
        (ref) => GameRoundNotifier());
