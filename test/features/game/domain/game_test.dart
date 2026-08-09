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

Game _weighedIn(List<GameRound> rounds) {
  return Game(
    players: const [
      Player('Anna', initialWeight: 500),
      Player('Ben', initialWeight: 500),
      Player('Cleo', initialWeight: 500),
    ],
    rounds: rounds,
    config: const GameConfig(),
    meta: GameMetaData(createdAt: DateTime(2026)),
  );
}

void main() {
  test('cannot start a round before every initial weight is entered', () {
    expect(_game(const []).canStartNewRound, isFalse);
  });

  test('can start the first round once everyone is weighed in', () {
    expect(_weighedIn(const []).canStartNewRound, isTrue);
  });

  test('cannot start a round while the current one is unfinished', () {
    final game = _weighedIn(const [
      GameRound(200, [180, 0, 0]),
    ]);

    expect(game.canStartNewRound, isFalse);
  });

  test('can start a round once the current one is fully weighed', () {
    final game = _weighedIn(const [
      GameRound(200, [180, 170, 160]),
    ]);

    expect(game.canStartNewRound, isTrue);
  });

  test('lowestCurrentWeight falls back to initial weights before any round', () {
    expect(_weighedIn(const []).lowestCurrentWeight, 500);
  });

  test('lowestCurrentWeight uses the lightest last measurement', () {
    final game = _game([
      const GameRound(200, [180, 90, 60]),
    ]);

    expect(game.lowestCurrentWeight, 60);
  });

  test('lowestCurrentWeight ignores players not yet weighed this round', () {
    final game = _game([
      const GameRound(120, [110, 40, 55]),
      const GameRound(100, [90, 0, 0]),
    ]);

    // Anna drops to 90 in round 2; Ben (40) and Cleo (55) keep round-1 weights.
    expect(game.lowestCurrentWeight, 40);
  });

  test('autoTargetBase anchors round 1 to lightest weight plus the offset', () {
    // 500 (lightest initial) + kAutoDrawMin (30): a gentler opening round.
    expect(_weighedIn(const []).autoTargetBase, 530);
  });

  test('autoTargetBase chains off the last target when someone reached it', () {
    final game = _weighedIn(const [
      GameRound(400, [380, 390, 370]),
    ]);

    // Cleo is at 370 < 400, so the target keeps stepping down from 400.
    expect(game.autoTargetBase, 400);
  });

  test('autoTargetBase re-anchors to the lightest glass on an all-undershoot', () {
    final game = _weighedIn(const [
      GameRound(400, [450, 460, 470]),
    ]);

    // Nobody reached 400; draw down from the lightest glass (450) instead so the
    // next forced drink stays within the draw range.
    expect(game.autoTargetBase, 450);
  });

  test('lastMeasurement is null before a player is weighed', () {
    final game = _game([
      const GameRound(200, [180, 0, 0]),
    ]);

    expect(game.lastMeasurement(0), 180);
    expect(game.lastMeasurement(1), isNull);
  });
}
