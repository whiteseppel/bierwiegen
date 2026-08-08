import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:bierwiegen/features/history/game_result_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game({
  required List<Player> players,
  required List<GameRound> rounds,
  GameMode mode = GameMode.standard,
  TargetMode targetMode = TargetMode.manual,
  DateTime? createdAt,
  DateTime? finishedAt,
}) {
  return Game(
    players: players,
    rounds: rounds,
    config: GameConfig(mode: mode, targetMode: targetMode),
    meta: GameMetaData(
      createdAt: createdAt ?? DateTime(2026, 8, 5, 21, 0),
      finishedAt: finishedAt ?? DateTime(2026, 8, 5, 21, 48),
    ),
  );
}

void main() {
  test('derives rounds played, duration, exact hits and labels from the game',
      () {
    final model = GameResultViewModel(_game(
      players: const [Player('Anna'), Player('Ben'), Player('Cleo')],
      rounds: const [
        GameRound(500, [500, 490, 480]), // Anna exact + closest
        GameRound(400, [410, 401, 380]), // Ben closest
      ],
      mode: GameMode.points,
      targetMode: TargetMode.auto,
    ));

    expect(model.roundsPlayed, 2);
    expect(model.duration, const Duration(minutes: 48));
    expect(model.modeLabel, 'Punkte');
    expect(model.targetLabel, 'Automatische Ziele');
    expect(model.results.firstWhere((r) => r.name == 'Anna').exactHits, 1);
    expect(model.scoreLabel(14), '14 Pkt');
  });

  test('ranking shares the better rank for ties and lists winners', () {
    final model = GameResultViewModel(_game(
      players: const [Player('Anna'), Player('Ben'), Player('Cleo')],
      rounds: const [
        // Anna and Ben both land 10 g off; Cleo 20 g off. Standard mode: the
        // two closest tie for the round win, so both reach score 1.
        GameRound(500, [490, 510, 480]),
      ],
    ));

    expect(model.ranking.map((r) => r.rank), [1, 1, 3]);
    expect(model.winnerNames, 'Anna und Ben');
    expect(model.scoreLabel(1), '1 Sieg');
  });
}
