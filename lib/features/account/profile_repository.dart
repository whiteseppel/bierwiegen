import 'package:sembast/sembast.dart';

/// Persists the player's account data (display name and avatar color).
class ProfileRepository {
  ProfileRepository(this._db);

  final Database _db;
  final _store = StoreRef<String, Object?>.main();

  static const _nameKey = 'profileName';
  static const _colorKey = 'profileColor';

  Future<String> loadName() async =>
      await _store.record(_nameKey).get(_db) as String? ?? '';

  Future<void> saveName(String name) =>
      _store.record(_nameKey).put(_db, name);

  Future<String> loadColor() async =>
      await _store.record(_colorKey).get(_db) as String? ?? '';

  Future<void> saveColor(String id) =>
      _store.record(_colorKey).put(_db, id);
}
