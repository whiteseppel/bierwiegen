import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_round.freezed.dart';
part 'game_round.g.dart';

@freezed
abstract class GameRound with _$GameRound {
  const GameRound._();

  /// [measurements] has one entry per player; 0 means not yet entered.
  const factory GameRound(double target, List<double> measurements) =
      _GameRound;

  factory GameRound.fromJson(Map<String, dynamic> json) =>
      _$GameRoundFromJson(json);

  bool get isFinished => measurements.every((m) => m != 0);

  double? get closestDistance {
    if (!isFinished) {
      return null;
    }

    return measurements
        .map((m) => (m - target).abs())
        .reduce((a, b) => a < b ? a : b);
  }

  bool isClosest(int playerIndex) {
    return closestDistance != null &&
        (measurements[playerIndex] - target).abs() == closestDistance;
  }

  bool isExact(int playerIndex) => measurements[playerIndex] == target;

  /// Closest distance among the measurements entered so far; unlike
  /// [closestDistance] it does not require the round to be finished.
  double? get closestDistanceSoFar {
    final entered = measurements.where((m) => m != 0);
    if (entered.isEmpty) {
      return null;
    }

    return entered
        .map((m) => (m - target).abs())
        .reduce((a, b) => a < b ? a : b);
  }

  bool isClosestSoFar(int playerIndex) {
    return measurements[playerIndex] != 0 &&
        (measurements[playerIndex] - target).abs() == closestDistanceSoFar;
  }

  /// Next player without a measurement, searching after [after] and wrapping
  /// around; null when the round is finished.
  int? nextEmptyIndex({required int after}) {
    for (int i = 1; i <= measurements.length; i++) {
      final index = (after + i) % measurements.length;
      if (measurements[index] == 0) {
        return index;
      }
    }
    return null;
  }
}
