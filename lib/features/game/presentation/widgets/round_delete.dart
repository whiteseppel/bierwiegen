import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../dialogs.dart';

/// Removes the last round, confirming first when it already holds weights so an
/// accidental tap can't wipe entered data.
Future<void> confirmAndRemoveLastRound(
  BuildContext context,
  WidgetRef ref,
) async {
  final game = ref.read(gameProvider);
  if (game == null || game.rounds.isEmpty) {
    return;
  }

  final hasData = game.rounds.last.measurements.any((m) => m != 0);
  if (hasData) {
    final confirmed = await Dialogs.confirmDialog(
      context,
      title: 'Runde löschen?',
      body: 'Die letzte Runde und alle eingetragenen Gewichte werden entfernt.',
      confirmLabel: 'Löschen',
    );
    if (!confirmed) {
      return;
    }
  }

  FocusManager.instance.primaryFocus?.unfocus();
  ref.read(focusedCellProvider.notifier).state = null;
  ref.read(gameProvider.notifier).removeLastRound();
}
