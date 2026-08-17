import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_config.dart';
import 'game_meta_data.dart';
import 'game_round.dart';
import 'player.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// Range (grams) an automatic round draws below its base weight. The only
/// step-size knobs for the auto target; see docs/auto_target_algorithm.md.
const double kAutoDrawMin = 25;
const double kAutoDrawMax = 70;

@freezed
abstract class Game with _$Game {
  const Game._();

  const factory Game({
    required List<Player> players,
    required List<GameRound> rounds,
    required GameConfig config,
    required GameMetaData meta,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  bool get isFinished => meta.isFinished;

  bool get allPlayersWeighedIn => players.every((p) => p.hasWeighedIn);

  /// True once a new round can be added: every initial weight is in and either
  /// no round has started yet or the current one is fully weighed.
  bool get canStartNewRound =>
      allPlayersWeighedIn && (rounds.isEmpty || rounds.last.isFinished);

  bool get hasFinishedRound => rounds.any((r) => r.isFinished);

  bool get hasAnyMeasurement =>
      rounds.any((r) => r.measurements.any((m) => m != 0));

  /// Lowest current weight across all players: their last measurement, else
  /// initial weight. Null before anyone has weighed in.
  double? get lowestCurrentWeight {
    final weights = [
      for (int i = 0; i < players.length; i++)
        lastMeasurement(i) ?? players[i].initialWeight,
    ].where((w) => w != 0);
    if (weights.isEmpty) {
      return null;
    }
    return weights.reduce((a, b) => a < b ? a : b);
  }

  /// Weight the next automatic target is drawn down from: whichever is higher,
  /// the last round's target or the lightest current glass. Anchoring to the
  /// lightest glass whenever nobody reached the last target caps the next forced
  /// drink at the draw range, so successive undershoots can't compound into one
  /// oversized round. Round 1 adds [kAutoDrawMin] so the opening step is gentle
  /// (0–[kAutoDrawMax]−[kAutoDrawMin] g). Null before anyone has weighed in.
  /// See docs/auto_target_algorithm.md.
  double? get autoTargetBase {
    final lowest = lowestCurrentWeight;
    if (lowest == null) {
      return null;
    }
    final lastTarget = rounds.isEmpty ? null : rounds.last.target;
    return lastTarget == null ? lowest + kAutoDrawMin : max(lastTarget, lowest);
  }

  /// Player's most recently entered measurement across all rounds; null when
  /// they have not been weighed in any round yet.
  double? lastMeasurement(int playerIndex) {
    for (int i = rounds.length - 1; i >= 0; i--) {
      final measurement = rounds[i].measurements[playerIndex];
      if (measurement != 0) {
        return measurement;
      }
    }
    return null;
  }

  /// Weight the player's glass had before [roundIndex]: the last entered
  /// measurement of an earlier round, else the initial weight; null when
  /// nothing was entered yet.
  double? previousWeight(int roundIndex, int playerIndex) {
    for (int i = roundIndex - 1; i >= 0; i--) {
      final measurement = rounds[i].measurements[playerIndex];
      if (measurement != 0) {
        return measurement;
      }
    }

    final initial = players[playerIndex].initialWeight;
    return initial != 0 ? initial : null;
  }
}
