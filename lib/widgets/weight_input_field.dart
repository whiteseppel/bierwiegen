import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../functions/weight_input_dialog.dart';
import 'package:collection/collection.dart';

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
      focusNode: widget.m.node,
      keyboardType: TextInputType.number,
      // NOTE: when the round is finished the input action should be "done" or "submit" - otherwise "next"
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "...",
      ),
      style: regularFont,
      textAlign: TextAlign.center,
      // NOTE: after submitting we can check if  we want to add a new round
      // onEditingComplete:,
      onChanged: (result) async {
        final r = double.tryParse(result);

        if (r == null) {
          print('value could not be converted');
          return;
        }

        print('setting value for round: $r');

        widget.m.value = r;
        print(
          'new round is finished: ${ref.read(gameRoundProvider).last.isFinished}',
        );
      },
      onSubmitted: (result) async {
        if (ref.read(gameRoundProvider).last.isFinished) {
          ref.read(gameRoundProvider.notifier).forceRefresh();
          print('adding new round');
          // after evaluation add new round to the game
          final weight = await showWeightInputDialog(context);

          if (weight == null) {
            print('weight must be added to add a new game round');
            return;
          }

          ref.read(gameRoundProvider.notifier).addRound(weight);
        }

        Measurement? m = ref
            .read(gameRoundProvider)
            .last
            .measurements
            .firstWhereOrNull((m) => m.value == 0);

        if (m != null) {
          m.node.requestFocus();
        }
      },
    );
  }
}
