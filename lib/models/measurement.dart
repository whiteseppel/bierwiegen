import 'package:flutter/material.dart';

class Measurement {
  TextEditingController controller;
  FocusNode node;
  double value;

  Measurement(this.controller, this.value, this.node);

  double distanceToTarget(double target) {
    return (target - value).abs();
  }

  factory Measurement.empty() {
    return Measurement(TextEditingController(), 0, FocusNode());
  }
}
