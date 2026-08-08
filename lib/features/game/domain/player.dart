import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const Player._();

  const factory Player(String name, {@Default(0) double initialWeight}) =
      _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  bool get hasWeighedIn => initialWeight != 0;
}
