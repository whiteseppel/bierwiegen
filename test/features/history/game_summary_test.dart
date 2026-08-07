import 'package:bierwiegen/features/game/domain/game.dart';
import 'package:bierwiegen/features/game/domain/game_config.dart';
import 'package:bierwiegen/features/game/domain/game_meta_data.dart';
import 'package:bierwiegen/features/game/domain/game_round.dart';
import 'package:bierwiegen/features/game/domain/player.dart';
import 'package:bierwiegen/features/history/game_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromGame captures scores, rounds and exact hits', () {
    final game = Game(
      players: const [Player('Anna'), Player('Ben'), Player('Cleo')],
      rounds: const [
        GameRound(500, [500, 490, 480]), // Anna exact + closest
        GameRound(400, [410, 401, 380]), // Ben closest
      ],
      config: const GameConfig(targetMode: TargetMode.auto),
      meta: GameMetaData(
        createdAt: DateTime(2026, 8, 5, 21, 0),
        finishedAt: DateTime(2026, 8, 5, 21, 48),
      ),
    );

    final summary = GameSummary.fromGame(game);

    expect(summary.roundsPlayed, 2);
    expect(summary.targetMode, TargetMode.auto);
    expect(summary.duration, const Duration(minutes: 48));
    expect(summary.results.map((r) => r.name), ['Anna', 'Ben', 'Cleo']);
    expect(summary.results.firstWhere((r) => r.name == 'Anna').exactHits, 1);
  });

  test('ranking shares the better rank for ties and lists winners', () {
    final summary = GameSummary(
      createdAt: DateTime(2026),
      finishedAt: DateTime(2026),
      mode: GameMode.points,
      targetMode: TargetMode.manual,
      roundsPlayed: 3,
      results: [
        PlayerResult(name: 'Anna', score: 5, exactHits: 0),
        PlayerResult(name: 'Ben', score: 5, exactHits: 0),
        PlayerResult(name: 'Cleo', score: 2, exactHits: 0),
      ],
    );

    expect(summary.ranking.map((r) => r.rank), [1, 1, 3]);
    expect(summary.winnerNames, 'Anna und Ben');
    expect(summary.scoreLabel(5), '5 Pkt');
  });
}
