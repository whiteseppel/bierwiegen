import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_summary.dart';

/// Finished games from the current session, newest first. Kept in memory only;
/// the app persists no data.
class GameHistoryNotifier extends StateNotifier<List<GameSummary>> {
  GameHistoryNotifier() : super(const []);

  void record(GameSummary summary) {
    state = [summary, ...state];
  }
}

final gameHistoryProvider =
    StateNotifierProvider<GameHistoryNotifier, List<GameSummary>>(
  (ref) => GameHistoryNotifier(),
);
