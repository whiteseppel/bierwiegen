import 'measurement.dart';

class GameRound {
  double target;
  List<Measurement> measurements;

  bool get isFinished {
    return measurements.every((m) => m.value != 0.0);
  }

  focusNextEmptyInputField() {
    // if no node from this round has focus focus the first one
    // need to check if this makes any sence
    // if (!measurements.any((m) => m.node.hasFocus)) {
    //   measurements[0].node.requestFocus();
    //   return;
    // }

    int focusedIndex = measurements.indexWhere((m) => m.node.hasFocus);

    if (focusedIndex == -1) {
      return;
    }

    for (int i = focusedIndex + 1; i < measurements.length; i++) {
      if (measurements[i].value == 0) {
        measurements[i].node.requestFocus();
        return;
      }
    }

    // when the last item is used the loop does not work - we need to check it
    // here.
    if (measurements[0].value == 0) {
      measurements[0].node.requestFocus();
    }
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
