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

/// Snapshot of a finished game, kept for the "Letzte Spiele" list.
class GameSummary {
  const GameSummary({
    required this.createdAt,
    required this.finishedAt,
    required this.mode,
    required this.targetMode,
    required this.roundsPlayed,
    required this.results,
  });

  final DateTime createdAt;
  final DateTime finishedAt;
  final GameMode mode;
  final TargetMode targetMode;
  final int roundsPlayed;
  final List<PlayerResult> results;

  factory GameSummary.fromGame(Game game, {DateTime? finishedAt}) {
    final scores = calculateScores(game);
    return GameSummary(
      createdAt: game.meta.createdAt,
      finishedAt: game.meta.finishedAt ?? finishedAt ?? game.meta.createdAt,
      mode: game.config.mode,
      targetMode: game.config.targetMode,
      roundsPlayed:
          game.rounds.where((r) => r.measurements.any((m) => m != 0)).length,
      results: [
        for (int i = 0; i < game.players.length; i++)
          PlayerResult(
            name: game.players[i].name,
            score: scores[i],
            exactHits: game.rounds.where((r) => r.isExact(i)).length,
          ),
      ],
    );
  }

  int get playerCount => results.length;

  Duration get duration => finishedAt.difference(createdAt);

  /// Results ordered by score, tied players sharing the better rank.
  List<RankedResult> get ranking {
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

  List<PlayerResult> get winners =>
      [for (final r in ranking) if (r.rank == 1) r.result];

  String get winnerNames {
    final names = winners.map((p) => p.name).toList();
    if (names.isEmpty) {
      return '—';
    }
    if (names.length == 1) {
      return names.first;
    }
    return '${names.sublist(0, names.length - 1).join(', ')} '
        'und ${names.last}';
  }

  /// e.g. "14 Pkt" or "3 Siege" for the top score, matching [mode].
  String scoreLabel(int score) {
    if (mode == GameMode.points) {
      return '$score Pkt';
    }
    return '$score ${score == 1 ? 'Sieg' : 'Siege'}';
  }
}
