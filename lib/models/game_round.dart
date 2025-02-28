import 'measurement.dart';

class GameRound {
  double target;
  List<Measurement> measurements;

  bool get isFinished {
    return measurements.every((m) => m.value != 0.0);
  }

  GameRound(this.target, this.measurements);
}
