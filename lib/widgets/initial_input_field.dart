import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../functions/weight_input_dialog.dart';

class InitialInputField extends ConsumerStatefulWidget {
  const InitialInputField(this.index, {super.key});
  final int index;

  @override
  _InitialInputFieldState createState() => _InitialInputFieldState();
}

class _InitialInputFieldState extends ConsumerState<InitialInputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onSubmitted: (result) async {
        print('Result Einwiegen: $result');
        final r = double.tryParse(result);
        if (r != null) {
          print(
              'setting weight for player ${ref.read(playerProvider)[widget.index].name}');
          ref.read(playerProvider)[widget.index].initialWeight.value = r;
        }

        if (!ref
            .read(playerProvider)
            .any((player) => player.initialWeight.value == 0)) {
          if (ref.read(gameRoundProvider).isEmpty ||
              ref.read(gameRoundProvider).last.isFinished) {
            final weight = await showWeightInputDialog(context);

            if (weight == null) {
              return;
            }

            ref.read(gameRoundProvider.notifier).addRound(weight);
          }
        }
      },
      controller:
          ref.read(playerProvider)[widget.index].initialWeight.controller,
    );
  }
}
