class Player {
  final String name;
  final double initialWeight;

  const Player(this.name, {this.initialWeight = 0});

  bool get hasWeighedIn => initialWeight != 0;

  Player copyWith({double? initialWeight}) {
    return Player(name, initialWeight: initialWeight ?? this.initialWeight);
  }
}
