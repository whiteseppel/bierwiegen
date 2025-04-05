import 'measurement.dart';

class GameRound {
  double target;
  List<Measurement> measurements;

  bool get isFinished {
    return measurements.every((m) => m.value != 0.0);
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
