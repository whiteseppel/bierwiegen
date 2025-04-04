import 'package:bierwiegen/models/measurement.dart';
import 'package:flutter/widgets.dart';
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
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>(
    (ref) => PlayerNotifier(ref));

class GameRoundNotifier extends StateNotifier<List<GameRound>> {
  GameRoundNotifier(this.ref) : super([]);

  final Ref ref;

  void addRound(double weight) {
    final r = GameRound(weight, []);
    for (var _ in ref.read(playerProvider)) {
      r.measurements.add(Measurement(TextEditingController(), 0));
    }

    state = [...state, r];
  }
}

final gameRoundProvider =
    StateNotifierProvider<GameRoundNotifier, List<GameRound>>(
        (ref) => GameRoundNotifier(ref));
