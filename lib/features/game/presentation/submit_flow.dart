import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/game_providers.dart';
import 'cell_registry.dart';
import 'dialogs.dart';

/// Advances the game after a cell was submitted: moves the focus to the next
/// empty cell and starts a new round (via target dialog) when the current one
/// is complete.
Future<void> handleCellSubmitted(
  BuildContext context,
  WidgetRef ref, {
  required bool isInitialWeight,
  required int playerIndex,
}) async {
  final game = ref.read(gameProvider);
  final registry = ref.read(cellRegistryProvider);
  if (game == null) {
    return;
  }

  if (game.rounds.isEmpty) {
    if (!game.allPlayersWeighedIn) {
      if (isInitialWeight) {
        _focusNextPlayerWithoutInitialWeight(ref, playerIndex);
      }
      return;
    }

    await startNewRound(context, ref);
    return;
  }

  if (game.rounds.last.isFinished) {
    await startNewRound(context, ref);
    return;
  }

  final lastRoundIndex = game.rounds.length - 1;
  final next = game.rounds.last.nextEmptyIndex(after: playerIndex);
  if (next != null) {
    registry.requestFocus(CellRegistry.measurementKey(lastRoundIndex, next));
  }
}

Future<void> startNewRound(BuildContext context, WidgetRef ref) async {
  final game = ref.read(gameProvider);
  if (game == null || game.isFinished) {
    return;
  }

  final lastTarget = game.rounds.isEmpty ? null : game.rounds.last.target;
  final suggested = lastTarget == null
      ? 400.0
      : (lastTarget - 100).clamp(0.0, double.infinity);

  final target = await Dialogs.weightInputDialog(
    context,
    title: 'Neue Runde',
    body: 'Zielgewicht in Gramm festlegen.',
    confirmLabel: 'Hinzufügen',
    initialValue: suggested,
  );
  if (target == null) {
    return;
  }

  ref.read(gameProvider.notifier).addRound(target);

  // The new round's fields only exist after the next frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final game = ref.read(gameProvider);
    if (game == null || game.rounds.isEmpty) {
      return;
    }
    ref
        .read(cellRegistryProvider)
        .requestFocus(CellRegistry.measurementKey(game.rounds.length - 1, 0));
  });
}

void _focusNextPlayerWithoutInitialWeight(WidgetRef ref, int afterIndex) {
  final game = ref.read(gameProvider);
  if (game == null) {
    return;
  }

  final players = game.players;
  for (int i = 1; i <= players.length; i++) {
    final index = (afterIndex + i) % players.length;
    if (!players[index].hasWeighedIn) {
      ref
          .read(cellRegistryProvider)
          .requestFocus(CellRegistry.initialWeightKey(index));
      return;
    }
  }
}
