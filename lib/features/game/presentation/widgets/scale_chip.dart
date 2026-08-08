import 'package:flutter/material.dart';

import '../../../../ui/tokens.dart';
import '../../../scale/scale_state.dart';

class ScaleChipData {
  final Color bg;
  final Color fg;
  final Color dot;
  final String label;
  final bool connected;

  const ScaleChipData({
    required this.bg,
    required this.fg,
    required this.dot,
    required this.label,
    required this.connected,
  });

  factory ScaleChipData.of(ScaleState scale, {required bool paused}) {
    if (scale.connectionState == ScaleConnectionState.connected) {
      return paused
          ? const ScaleChipData(
            bg: CustomColors.goldTint,
            fg: CustomColors.goldTextDark,
            dot: CustomColors.primaryColor,
            label: 'Pausiert',
            connected: true,
          )
          : const ScaleChipData(
            bg: CustomColors.greenTint,
            fg: CustomColors.greenDark,
            dot: CustomColors.secondaryColor,
            label: 'Waage',
            connected: true,
          );
    }

    return switch (scale.connectionState) {
      ScaleConnectionState.scanning ||
      ScaleConnectionState.connecting ||
      ScaleConnectionState.reconnecting => const ScaleChipData(
        bg: CustomColors.neutralChipBg,
        fg: CustomColors.textFaint,
        dot: CustomColors.primaryColor,
        label: 'Verbinde …',
        connected: false,
      ),
      _ => const ScaleChipData(
        bg: CustomColors.neutralChipBg,
        fg: CustomColors.textFaint,
        dot: CustomColors.neutralDot,
        label: 'Getrennt',
        connected: false,
      ),
    };
  }
}

class ScaleChip extends StatelessWidget {
  const ScaleChip({
    super.key,
    required this.data,
    this.label,
    this.onTap,
    this.height = 32,
  });

  final ScaleChipData data;

  /// Overrides [ScaleChipData.label] when set.
  final String? label;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: data.bg,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: data.dot,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: Spacings.small),
            Text(
              label ?? data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: data.fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
