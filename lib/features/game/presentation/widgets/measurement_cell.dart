import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_providers.dart';
import '../cell_registry.dart';
import '../submit_flow.dart';
import 'weight_input_field.dart';

class MeasurementCell extends ConsumerWidget {
  const MeasurementCell({
    super.key,
    required this.roundIndex,
    required this.playerIndex,
  });

  final int roundIndex;
  final int playerIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final round = game.rounds[roundIndex];

    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          if (round.isClosest(playerIndex))
            Icon(
              Icons.star,
              // NOTE: when we use a scale we have to calculate the exact number by grams
              color: round.isExact(playerIndex) ? Colors.amber : Colors.green,
            ),
          WeightInputField(
            cellKey: CellRegistry.measurementKey(roundIndex, playerIndex),
            value: round.measurements[playerIndex],
            onValueChanged: (value) => ref
                .read(gameProvider.notifier)
                .setMeasurement(roundIndex, playerIndex, value),
            onSubmitted: () => handleCellSubmitted(
              context,
              ref,
              isInitialWeight: false,
              playerIndex: playerIndex,
            ),
          ),
        ],
      ),
    );
  }
}
