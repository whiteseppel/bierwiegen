import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../state/game_providers.dart';
import '../dialogs.dart';
import '../format.dart';
import 'weight_cell.dart';

const double roundLabelWidth = 58;

/// Sticky left cell of a table row; [roundIndex] is -1 for the
/// initial-weights row. Long press edits the round's target.
class RoundLabelCell extends ConsumerWidget {
  const RoundLabelCell({super.key, required this.roundIndex});

  final int roundIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final isInitial = roundIndex < 0;
    final tag = isInitial ? 'START' : 'R${roundIndex + 1}';
    final label =
        isInitial ? '—' : formatWeight(game.rounds[roundIndex].target);

    return GestureDetector(
      onLongPress: isInitial || game.isFinished
          ? null
          : () async {
              final newTarget = await Dialogs.weightInputDialog(
                context,
                title: 'Ziel korrigieren',
                body: 'Zielgewicht dieser Runde anpassen.',
                confirmLabel: 'Speichern',
                initialValue: game.rounds[roundIndex].target,
              );
              if (newTarget != null) {
                ref
                    .read(gameProvider.notifier)
                    .updateTarget(roundIndex, newTarget);
              }
            },
      child: Container(
        width: roundLabelWidth,
        height: weightCellHeight,
        decoration: const BoxDecoration(
          color: CustomColors.greenTint,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(13)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(3, 0),
              blurRadius: 6,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tag,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
                color: Color(0xFF7C8F84),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: CustomColors.greenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
