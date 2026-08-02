import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/text_styles.dart';
import '../../../scale/scale_provider.dart';
import '../cell_registry.dart';

class WeightInputField extends ConsumerWidget {
  const WeightInputField({
    super.key,
    required this.cellKey,
    required this.value,
    required this.onValueChanged,
    required this.onSubmitted,
  });

  final String cellKey;
  final double value;
  final ValueChanged<double> onValueChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(cellRegistryProvider);
    final controller = registry.controller(cellKey);
    final focusNode = registry.focusNode(cellKey);

    ref.listen(scaleProvider, (previous, next) {
      // The scale only writes into the focused, still-empty field.
      if (!focusNode.hasFocus || value != 0) {
        return;
      }

      final stable = next.stableWeight;
      if (stable != null && stable != previous?.stableWeight) {
        controller.text = stable.toString();
        onValueChanged(stable.toDouble());
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dein Bier hat $stable Gramm!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (next.liveWeight != previous?.liveWeight &&
          (next.liveWeight ?? 0) != 0) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biermessung erfolgt ..'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    return TextField(
      controller: controller,
      focusNode: focusNode,
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
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) {
          onValueChanged(parsed);
        }
      },
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
