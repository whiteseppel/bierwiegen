import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_providers.dart';
import '../dialogs.dart';

class TargetCell extends ConsumerWidget {
  const TargetCell({super.key, required this.roundIndex});

  final int roundIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final target = game.rounds[roundIndex].target;

    return GestureDetector(
      onLongPress: () async {
        final newTarget = await Dialogs.showWeightInputDialog(context);
        if (newTarget != null) {
          ref.read(gameProvider.notifier).updateTarget(roundIndex, newTarget);
        }
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(_formatWeight(target)),
      ),
    );
  }

  String _formatWeight(double weight) {
    final text = weight.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
}
