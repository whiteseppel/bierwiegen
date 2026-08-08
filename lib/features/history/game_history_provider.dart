import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/domain/game.dart';

/// Finished games from the current session, newest first. Kept in memory only;
/// the app persists no data.
class GameHistoryNotifier extends StateNotifier<List<Game>> {
  GameHistoryNotifier() : super(const []);

  void record(Game game) {
    state = [game, ...state];
  }
}

final gameHistoryProvider =
    StateNotifierProvider<GameHistoryNotifier, List<Game>>(
      (ref) => GameHistoryNotifier(),
    );
