import 'package:flutter_riverpod/flutter_riverpod.dart';
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
