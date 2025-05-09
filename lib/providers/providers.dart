import 'package:bierwiegen/models/measurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_round.dart';
import '../models/player.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  PlayerNotifier(this.ref) : super([]);

  final Ref ref;

  void clearPlayers() {
    state = [];
  }

  void addPlayer(Player player) {
    state = [...state, player];
  }

  void resetInitialWeight() {
    final players = state;
    for (final p in players) {
      p.initialWeight.value = 0;
      p.initialWeight.controller.clear();
    }
    state = players;
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>(
  (ref) => PlayerNotifier(ref),
);

class GameRoundNotifier extends StateNotifier<List<GameRound>> {
  GameRoundNotifier(this.ref) : super([]);

  final Ref ref;

  void clearRounds() {
    state = [];
  }

  void addRound(double weight) {
    final r = GameRound(weight, []);
    for (var _ in ref.read(playerProvider)) {
      r.measurements.add(Measurement.empty());
    }

    state = [...state, r];
  }

  void forceRefresh() {
    state = [...state];
  }
}

final gameRoundProvider =
    StateNotifierProvider<GameRoundNotifier, List<GameRound>>(
      (ref) => GameRoundNotifier(ref),
    );
