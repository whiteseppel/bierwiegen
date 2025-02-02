import 'package:flutter/material.dart';

class GameRound {
  double target;
  List<Measurement> measurements;

  bool get isFinished {
    return !measurements.any((m) => m.value != 0.0);
  }

  GameRound(this.target, this.measurements);
}

class Player {
  final String name;
  Measurement initialWeight;

  Player(this.name, this.initialWeight);
}

class Measurement {
  TextEditingController controller;
  double value;

  Measurement(this.controller, this.value);
}
