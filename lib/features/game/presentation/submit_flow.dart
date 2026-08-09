import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_config.dart';
import '../state/game_providers.dart';
import '../state/game_ui_providers.dart';
import 'cell_registry.dart';
import 'dialogs.dart';
import 'widgets/roll_dialog.dart';

/// Advances the game after a cell was submitted: moves the focus to the next
/// empty cell in the current round. Completing a round no longer opens a new
/// one — the player adds rounds explicitly via "+ Neue Runde".
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

    _clearFocus(ref);
    return;
  }

  if (game.rounds.last.isFinished) {
    _clearFocus(ref);
    return;
  }

  final lastRoundIndex = game.rounds.length - 1;
  final next = game.rounds.last.nextEmptyIndex(after: playerIndex);
  if (next != null) {
    registry.requestFocus(CellRegistry.measurementKey(lastRoundIndex, next));
  }
}

void _clearFocus(WidgetRef ref) {
  FocusManager.instance.primaryFocus?.unfocus();
  ref.read(focusedCellProvider.notifier).state = null;
  ref.read(keyboardOpenProvider.notifier).state = false;
}

Future<void> startNewRound(BuildContext context, WidgetRef ref) async {
  final game = ref.read(gameProvider);
  if (game == null || game.isFinished || !game.canStartNewRound) {
    return;
  }

  final lastTarget = game.rounds.isEmpty ? null : game.rounds.last.target;

  final double? target;
  if (game.config.targetMode == TargetMode.auto) {
    target = await showRollDialog(
      context,
      current: game.autoTargetBase ?? 500,
      roundNumber: game.rounds.length + 1,
    );
  } else {
    final suggested =
        lastTarget == null
            ? 400.0
            : (lastTarget - 100).clamp(0.0, double.infinity);
    target = await Dialogs.targetWeightDialog(
      context,
      eyebrow: 'Runde ${game.rounds.length + 1}',
      caption: 'Euer nächstes Zielgewicht',
      confirmLabel: 'Runde starten',
      fromWeight: lastTarget ?? 500,
      initialValue: suggested,
    );
  }
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
