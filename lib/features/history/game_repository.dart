import 'package:sembast/sembast.dart';

import '../game/domain/game.dart';

/// Persists finished games as JSON documents, one record per game keyed by the
/// game's creation timestamp (unique per game for a single user).
class GameRepository {
  GameRepository(this._db);

  final Database _db;
  final _store = stringMapStoreFactory.store('games');

  static String _key(Game game) =>
      game.meta.createdAt.millisecondsSinceEpoch.toString();

  Future<void> save(Game game) =>
      _store.record(_key(game)).put(_db, game.toJson());

  Future<void> delete(Game game) => _store.record(_key(game)).delete(_db);

  /// All persisted games, newest first.
  Future<List<Game>> loadAll() async {
    final records = await _store.find(_db);
    final games = records.map((r) => Game.fromJson(r.value)).toList();
    games.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    return games;
  }
}
