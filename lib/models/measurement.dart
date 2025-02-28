import 'package:flutter/material.dart';

class Measurement {
  TextEditingController controller;
  double value;

  Measurement(this.controller, this.value);

  double distanceToTarget(double target) {
    return (target - value).abs();
  }
}
