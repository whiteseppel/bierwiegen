import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/domain/game.dart';
import '../persistence/persistence_providers.dart';
import 'game_repository.dart';

/// Finished games, newest first. Backed by [GameRepository]; the initial list is
/// loaded at startup and seeded via an override in `main`.
class GameHistoryNotifier extends StateNotifier<List<Game>> {
  GameHistoryNotifier(this._repo, List<Game> initial) : super(initial);

  final GameRepository _repo;

  void record(Game game) {
    state = [game, ...state];
    _repo.save(game);
  }
}

final gameHistoryProvider =
    StateNotifierProvider<GameHistoryNotifier, List<Game>>(
      (ref) => GameHistoryNotifier(ref.watch(gameRepositoryProvider), const []),
    );
