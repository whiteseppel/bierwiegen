import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:bierwiegen/features/history/game_history_provider.dart';
import 'package:bierwiegen/features/history/game_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

Game _game(DateTime createdAt) => Game(
  players: const [Player('Anna', initialWeight: 800)],
  rounds: const [
    GameRound(500, [480.0]),
  ],
  config: const GameConfig(),
  meta: GameMetaData(createdAt: createdAt),
);

Future<GameRepository> _freshRepo() async =>
    GameRepository(await newDatabaseFactoryMemory().openDatabase('test.db'));

void main() {
  test('record adds to state and persists', () async {
    final repo = await _freshRepo();
    final notifier = GameHistoryNotifier(repo, const []);
    final game = _game(DateTime(2026, 8, 8));

    await notifier.record(game);

    expect(notifier.state, [game]);
    expect(await repo.loadAll(), [game]);
  });

  test('remove drops from state and deletes from storage', () async {
    final repo = await _freshRepo();
    final keep = _game(DateTime(2026, 8, 8));
    final drop = _game(DateTime(2026, 8, 1));
    final notifier = GameHistoryNotifier(repo, [keep, drop]);
    await repo.save(keep);
    await repo.save(drop);

    await notifier.remove(drop);

    expect(notifier.state, [keep]);
    expect(await repo.loadAll(), [keep]);
  });
}
