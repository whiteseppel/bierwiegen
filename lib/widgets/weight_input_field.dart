import 'package:bierwiegen/models/measurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../functions/weight_input_dialog.dart';

import '../providers/providers.dart';

class WeightInputField extends ConsumerStatefulWidget {
  const WeightInputField(this.m, {super.key});
  final Measurement m;

  @override
  _WeightInputFieldState createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends ConsumerState<WeightInputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.m.controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onSubmitted: (result) async {
        // add the value to the measurement
        final r = double.tryParse(result);

        if (r == null) {
          print('value could not be converted');
          // wenn wir die nummer nicht parsen können müssen wir den wert löschen
          return;
        }
        print('setting value for round: $r');

        widget.m.value = r;
        print(
            'new round is finished: ${ref.read(gameRoundProvider).last.isFinished}');

        // NOTE:
        // when we move this part to its own widget we can check if the last round is finisheod
        if (ref.read(gameRoundProvider).last.isFinished) {
          print('adding new round');
          // after evaluation add new round to the game
          final weight = await showWeightInputDialog(context);

          if (weight == null) {
            print('weight must be added to add a new game round');
            return;
          }

          ref.read(gameRoundProvider.notifier).addRound(weight);
        }
      },
    );
  }
}
