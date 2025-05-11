import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/providers/player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_round.dart';

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
