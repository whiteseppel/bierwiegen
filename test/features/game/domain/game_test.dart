import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game(List<GameRound> rounds) {
  return Game(
    players: const [Player('Anna'), Player('Ben'), Player('Cleo')],
    rounds: rounds,
    config: const GameConfig(),
    meta: GameMetaData(createdAt: DateTime(2026)),
  );
}

void main() {
  test('no finishers while every glass stays at or above 50 g', () {
    final game = _game([
      const GameRound(200, [180, 90, 60]),
    ]);

    expect(game.finishers, isEmpty);
  });

  test('a glass below 50 g makes that player a finisher', () {
    final game = _game([
      const GameRound(200, [180, 90, 60]),
      const GameRound(120, [110, 40, 55]),
    ]);

    expect(game.finishers.map((p) => p.name), ['Ben']);
  });

  test('finisher status uses the most recent measurement', () {
    final game = _game([
      const GameRound(120, [110, 40, 55]),
      const GameRound(100, [90, 0, 0]),
    ]);

    // Ben dropped below 50 g in round 1 and has no later measurement.
    expect(game.finishers.map((p) => p.name), ['Ben']);
  });

  test('lastMeasurement is null before a player is weighed', () {
    final game = _game([
      const GameRound(200, [180, 0, 0]),
    ]);

    expect(game.lastMeasurement(0), 180);
    expect(game.lastMeasurement(1), isNull);
  });
}
