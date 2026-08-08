import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:bierwiegen/features/history/game_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

Game _sampleGame({required DateTime createdAt}) => Game(
  players: const [Player('Anna', initialWeight: 812.5), Player('Bea')],
  rounds: const [
    GameRound(500, [480.0, 0.0]),
    GameRound(450.5, [430.0, 460.0]),
  ],
  config: const GameConfig(mode: GameMode.points, targetMode: TargetMode.auto),
  meta: GameMetaData(createdAt: createdAt),
);

Future<GameRepository> _freshRepo() async =>
    GameRepository(await newDatabaseFactoryMemory().openDatabase('test.db'));

void main() {
  test('save then loadAll round-trips a game through sembast', () async {
    final repo = await _freshRepo();
    final game = _sampleGame(createdAt: DateTime(2026, 8, 8, 20, 30));

    await repo.save(game);
    final loaded = await repo.loadAll();

    expect(loaded, [game]);
  });

  test('loadAll returns games newest first', () async {
    final repo = await _freshRepo();
    final older = _sampleGame(createdAt: DateTime(2026, 8, 1));
    final newer = _sampleGame(createdAt: DateTime(2026, 8, 8));

    await repo.save(older);
    await repo.save(newer);

    expect(await repo.loadAll(), [newer, older]);
  });

  test('delete removes a persisted game', () async {
    final repo = await _freshRepo();
    final game = _sampleGame(createdAt: DateTime(2026, 8, 8));

    await repo.save(game);
    await repo.delete(game);

    expect(await repo.loadAll(), isEmpty);
  });
}
