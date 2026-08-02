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

    await _startNewRound(context, ref);
    return;
  }

  if (game.rounds.last.isFinished) {
    await _startNewRound(context, ref);
    return;
  }

  final lastRoundIndex = game.rounds.length - 1;
  final next = game.rounds.last.nextEmptyIndex(after: playerIndex);
  if (next != null) {
    registry.requestFocus(CellRegistry.measurementKey(lastRoundIndex, next));
  }
}

Future<void> _startNewRound(BuildContext context, WidgetRef ref) async {
  final target = await Dialogs.showWeightInputDialog(context);
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
