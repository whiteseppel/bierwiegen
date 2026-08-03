import 'game.dart';
import 'game_config.dart';

/// Standard: one round win per player whose measurement is closest to the
/// target; ties award a win to every tied player.
/// Points: an exact hit scores 5; otherwise the three closest players score
/// 3/2/1, where tied players share the better rank.
List<int> calculateScores(Game game) {
  final scores = List<int>.filled(game.players.length, 0);

  for (final round in game.rounds) {
    if (!round.isFinished) {
      continue;
    }

    if (game.config.mode == GameMode.points) {
      final distances = [
        for (final m in round.measurements) (m - round.target).abs(),
      ];
      for (int i = 0; i < game.players.length; i++) {
        if (round.isExact(i)) {
          scores[i] += 5;
          continue;
        }

        final rank = distances.where((d) => d < distances[i]).length;
        scores[i] += switch (rank) {
          0 => 3,
          1 => 2,
          2 => 1,
          _ => 0,
        };
      }
    } else {
      for (int i = 0; i < game.players.length; i++) {
        if (round.isClosest(i)) {
          scores[i]++;
        }
      }
    }
  }

  return scores;
}
