import 'measurement.dart';

class GameRound {
  double target;
  List<Measurement> measurements;

  bool get isFinished {
    return measurements.every((m) => m.value != 0.0);
  }

  // minimal absolute distance
  double? get closestAbsValue {
    if (!isFinished) {
      return null;
    }

    double closest =
        measurements.reduce((value, element) {
          return (target - element.value).abs() < (target - value.value).abs()
              ? element
              : value;
        }).value;
    return (closest - target).abs();
  }

  int? get winningIndex {
    if (!isFinished) {
      return null;
    }

    double minAbsDist = 10000;
    int winningIndex = 0;
    for (int i = 0; i < measurements.length; i++) {
      //get abs to target
      double absDist = (target - measurements[i].value).abs();
      if (absDist < minAbsDist) {
        winningIndex = i;
        minAbsDist = absDist;
      }
    }

    return winningIndex;
  }

  GameRound(this.target, this.measurements);
}
