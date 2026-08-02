import 'game.dart';

/// One round win per player whose measurement is closest to the target;
/// ties award a win to every tied player.
List<int> calculateScores(Game game) {
  final scores = List<int>.filled(game.players.length, 0);

  for (final round in game.rounds) {
    if (!round.isFinished) {
      continue;
    }

    for (int i = 0; i < game.players.length; i++) {
      if (round.isClosest(i)) {
        scores[i]++;
      }
    }
  }

  return scores;
}
