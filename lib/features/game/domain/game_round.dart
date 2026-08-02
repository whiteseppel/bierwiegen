class GameRound {
  final double target;

  /// One entry per player; 0 means not yet entered.
  final List<double> measurements;

  const GameRound(this.target, this.measurements);

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
