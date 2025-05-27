import 'package:bierwiegen/sizes/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';
import '../providers/game_round_provider.dart';
import '../providers/player_provider.dart';
import '../functions/weight_input_dialog.dart';

class InitialInputField extends ConsumerStatefulWidget {
  const InitialInputField(this.player, {super.key});
  final Player player;
  // final int index;

  @override
  _InitialInputFieldState createState() => _InitialInputFieldState();
}

class _InitialInputFieldState extends ConsumerState<InitialInputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "...",
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: Fonts.regularFont,
      textAlign: TextAlign.center,
      onSubmitted: (result) async {
        print('Result Einwiegen: $result');
        final r = double.tryParse(result);
        if (r != null) {
          print('setting weight for player ${widget.player.name}');
          widget.player.initialWeight.value = r;
          // ref.read(playerProvider)[widget.index].initialWeight.value = r;
        }

        if (!ref
            .read(playerProvider)
            .any((player) => player.initialWeight.value == 0)) {
          if (ref.read(gameRoundProvider).isEmpty) {
            final weight = await showWeightInputDialog(context);

            if (weight == null) {
              return;
            }

            ref.read(gameRoundProvider.notifier).addRound(weight);
          }
        }
      },
      controller: widget.player.initialWeight.controller,
      // ref.read(playerProvider)[widget.index].initialWeight.controller,
    );
  }
}
