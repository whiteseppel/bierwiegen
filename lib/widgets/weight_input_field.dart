import 'dart:async';

import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/providers/player_provider.dart';
import 'package:bierwiegen/providers/scale_state_provider.dart';
import 'package:bierwiegen/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../functions/dialogs.dart';

import '../providers/game_round_provider.dart';

class WeightInputField extends ConsumerStatefulWidget {
  const WeightInputField(this.m, {super.key});

  final Measurement m;

  @override
  _WeightInputFieldState createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends ConsumerState<WeightInputField> {
  Timer? validationTimer;

  void onChanged(String result) {
    print('onchanged triggered');
    // if (result.isEmpty){
    //   result = "0";
    // }

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
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scaleStateProvider, (previous, next) {
      if (!widget.m.node.hasFocus) {
        return;
      }

      if (widget.m.value != 0) {
        return;
      }

      validationTimer?.cancel();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (next.weight == 0 || next.weight == null) {
        return;
      }

      // NOTE: we need to rework this whole process
      validationTimer = Timer(Duration(seconds: 2), () {
        final String result = next.weight.toString();
        widget.m.controller.value = TextEditingValue(text: result);
        onChanged(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dein Bier hat $result Gramm!'),
            duration: const Duration(seconds: 2),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biermessung erfolgt ..'),
          duration: Duration(seconds: 2),
        ),
      );
    });

    return TextField(
      controller: widget.m.controller,
      focusNode: widget.m.node,
      keyboardType: TextInputType.number,
      // NOTE: when the round is finished the input action should be "done" or "submit" - otherwise "next"
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "...",
      ),
      style: TextStyles.regularFont,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      onSubmitted: (result) async {
        if (ref.read(gameRoundProvider).isEmpty &&
            !ref
                .read(playerProvider)
                .any((player) => player.initialWeight.value == 0)) {
          final weight = await Dialogs.showWeightInputDialog(context);

          if (weight == null) {
            print('weight must be added to add a new game round');
            return;
          }

          ref.read(gameRoundProvider.notifier).addRound(weight);

          Future.microtask(() {
            ref.read(gameRoundProvider).last.focusNextEmptyInputField();
          });

          return;
        }

        if (ref.read(gameRoundProvider).last.isFinished) {
          ref.read(gameRoundProvider.notifier).forceRefresh();
          print('adding new round');
          final weight = await Dialogs.showWeightInputDialog(context);

          if (weight == null) {
            print('weight must be added to add a new game round');
            return;
          }

          ref.read(gameRoundProvider.notifier).addRound(weight);
        }

        ref.read(gameRoundProvider).last.focusNextEmptyInputField();
      },
    );
  }
}
