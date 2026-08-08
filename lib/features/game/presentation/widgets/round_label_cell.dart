import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../domain/game.dart';
import '../../state/game_providers.dart';
import '../dialogs.dart';
import '../format.dart';
import 'round_actions_sheet.dart';
import 'round_delete.dart';
import 'weight_cell.dart';

const double roundLabelWidth = 58;

/// Sticky left cell of a table row; [roundIndex] is -1 for the
/// initial-weights row. Tapping a round opens its actions (edit target,
/// delete the last round).
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
    final interactive = !isInitial && !game.isFinished;

    return GestureDetector(
      onTap: interactive ? () => _openActions(context, ref) : null,
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

  Future<void> _openActions(BuildContext context, WidgetRef ref) async {
    final game = ref.read(gameProvider);
    if (game == null || game.isFinished || roundIndex < 0) {
      return;
    }
    final deletable = roundIndex == game.rounds.length - 1;

    final action = await showRoundActionsSheet(
      context,
      roundIndex: roundIndex,
      canDelete: deletable,
    );
    if (action == null || !context.mounted) {
      return;
    }

    switch (action) {
      case RoundAction.editTarget:
        await _editTarget(context, ref, game);
      case RoundAction.delete:
        await confirmAndRemoveLastRound(context, ref);
    }
  }

  Future<void> _editTarget(
    BuildContext context,
    WidgetRef ref,
    Game game,
  ) async {
    final fromWeight = roundIndex > 0
        ? game.rounds[roundIndex - 1].target
        : game.rounds[roundIndex].target;
    final newTarget = await Dialogs.targetWeightDialog(
      context,
      eyebrow: 'Runde ${roundIndex + 1}',
      caption: 'Zielgewicht anpassen',
      confirmLabel: 'Speichern',
      fromWeight: fromWeight,
      initialValue: game.rounds[roundIndex].target,
    );
    if (newTarget != null) {
      ref.read(gameProvider.notifier).updateTarget(roundIndex, newTarget);
    }
  }
}
