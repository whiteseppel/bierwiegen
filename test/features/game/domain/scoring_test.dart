import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:bierwiegen/features/game/domain/scoring.dart';
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
  test('closest player wins the round', () {
    final game = _game([
      const GameRound(500, [498, 490, 510]),
    ]);

    expect(calculateScores(game), [1, 0, 0]);
  });

  test('tied players each win the round', () {
    final game = _game([
      const GameRound(500, [498, 502, 510]),
    ]);

    expect(calculateScores(game), [1, 1, 0]);
  });

  test('unfinished rounds are ignored', () {
    final game = _game([
      const GameRound(500, [498, 490, 510]),
      const GameRound(400, [398, 0, 0]),
    ]);

    expect(calculateScores(game), [1, 0, 0]);
  });

  test('wins accumulate over rounds', () {
    final game = _game([
      const GameRound(500, [498, 490, 510]),
      const GameRound(400, [401, 390, 380]),
      const GameRound(300, [310, 301, 320]),
    ]);

    expect(calculateScores(game), [2, 1, 0]);
  });
}
