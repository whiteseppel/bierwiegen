import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../domain/game_config.dart';
import '../../state/game_providers.dart';
import 'weight_cell.dart';

const double playerHeaderHeight = 56;

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

    final score = playerIndex < scores.length ? scores[playerIndex] : 0;
    final scoreLabel = game.config.mode == GameMode.points
        ? '$score Pkt'
        : '★ $score';

    return Container(
      width: weightCellWidth,
      height: playerHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: CustomColors.hairline)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            game.players[playerIndex].name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CustomColors.textPrimary,
            ),
          ),
          if (score > 0) ...[
            const SizedBox(height: 2),
            Text(
              scoreLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: CustomColors.secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
