import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_providers.dart';

class PlayerHeaderCell extends ConsumerWidget {
  const PlayerHeaderCell({super.key, required this.playerIndex});

  final int playerIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final scores = ref.watch(scoresProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final wins = playerIndex < scores.length ? scores[playerIndex] : 0;

    return Column(
      children: [
        Text(
          game.players[playerIndex].name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (wins > 0)
          Text(
            wins.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}
