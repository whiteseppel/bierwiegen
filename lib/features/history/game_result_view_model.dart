import '../game/domain/game.dart';
import '../game/domain/game_config.dart';
import '../game/domain/scoring.dart';

class PlayerResult {
  const PlayerResult({
    required this.name,
    required this.score,
    required this.exactHits,
  });

  final String name;
  final int score;
  final int exactHits;
}

class RankedResult {
  const RankedResult({required this.rank, required this.result});

  final int rank;
  final PlayerResult result;
}

/// Display data for a finished game's final standings, derived from a [Game].
/// Purely presentational — labels live here, not on the domain model — so the
/// same result screen can be shown after a game and from the history.
class GameResultViewModel {
  GameResultViewModel(this.game);

  final Game game;

  DateTime get createdAt => game.meta.createdAt;

  DateTime get finishedAt => game.meta.finishedAt ?? game.meta.createdAt;

  Duration get duration => finishedAt.difference(createdAt);

  int get playerCount => game.players.length;

  int get roundsPlayed =>
      game.rounds.where((r) => r.measurements.any((m) => m != 0)).length;

  late final List<PlayerResult> results = _computeResults();

  /// Results ordered by score, tied players sharing the better rank.
  late final List<RankedResult> ranking = _rank(results);

  late final List<PlayerResult> winners = [
    for (final r in ranking)
      if (r.rank == 1) r.result,
  ];

  int get winnerScore => winners.isEmpty ? 0 : winners.first.score;

  String get winnerNames {
    final names = winners.map((p) => p.name).toList();
    if (names.isEmpty) {
      return '—';
    }
    if (names.length == 1) {
      return names.first;
    }
    return '${names.sublist(0, names.length - 1).join(', ')} und ${names.last}';
  }

  /// e.g. "14 Pkt" or "3 Siege" for [score], matching the game mode.
  String scoreLabel(int score) {
    if (game.config.mode == GameMode.points) {
      return '$score Pkt';
    }
    return '$score ${score == 1 ? 'Sieg' : 'Siege'}';
  }

  String get modeLabel =>
      game.config.mode == GameMode.points ? 'Punkte' : 'Standard';

  String get targetLabel =>
      game.config.targetMode == TargetMode.auto
          ? 'Automatische Ziele'
          : 'Manuelle Ziele';

  List<PlayerResult> _computeResults() {
    final scores = calculateScores(game);
    return [
      for (int i = 0; i < game.players.length; i++)
        PlayerResult(
          name: game.players[i].name,
          score: scores[i],
          exactHits: game.rounds.where((r) => r.isExact(i)).length,
        ),
    ];
  }

  static List<RankedResult> _rank(List<PlayerResult> results) {
    final order = [...results]..sort((a, b) => b.score.compareTo(a.score));

    final ranked = <RankedResult>[];
    int shown = 0;
    int? lastScore;
    int lastRank = 0;
    for (final result in order) {
      shown++;
      final rank = result.score == lastScore ? lastRank : shown;
      lastScore = result.score;
      lastRank = rank;
      ranked.add(RankedResult(rank: rank, result: result));
    }
    return ranked;
  }
}
