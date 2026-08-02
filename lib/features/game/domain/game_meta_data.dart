class GameMetaData {
  final DateTime createdAt;
  final DateTime? finishedAt;

  const GameMetaData({required this.createdAt, this.finishedAt});

  bool get isFinished => finishedAt != null;

  GameMetaData copyWith({DateTime? createdAt, DateTime? finishedAt}) {
    return GameMetaData(
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
