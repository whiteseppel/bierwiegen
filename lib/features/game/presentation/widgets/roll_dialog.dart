import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../ui/tokens.dart';
import '../../domain/game.dart';
import '../format.dart';

/// Draws the next target: [kAutoDrawMin]–[kAutoDrawMax] g below [current],
/// never below zero.
double drawAutoTarget(double current) {
  final span = (kAutoDrawMax - kAutoDrawMin).toInt();
  final draw = kAutoDrawMin + Random().nextInt(span + 1);
  return (current - draw).clamp(0.0, double.infinity);
}

/// Animated draw of an automatic round target. Returns the drawn target on
/// "Runde starten", or null when dismissed.
Future<double?> showRollDialog(
  BuildContext context, {
  required double current,
  required int roundNumber,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _RollDialog(current: current, roundNumber: roundNumber),
  );
}

class _RollDialog extends StatefulWidget {
  const _RollDialog({required this.current, required this.roundNumber});

  final double current;
  final int roundNumber;

  @override
  State<_RollDialog> createState() => _RollDialogState();
}

class _RollDialogState extends State<_RollDialog>
    with SingleTickerProviderStateMixin {
  late final double _target = drawAutoTarget(widget.current);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final rolling = _controller.status != AnimationStatus.completed;
          final value =
              rolling
                  ? (current - (current - _target) * _animation.value).round()
                  : _target.round();
          final safeCurrent = current <= 0 ? 1.0 : current;
          final fillFraction = (value / safeCurrent).clamp(0.0, 1.0);
          final targetFraction = (_target / safeCurrent).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RUNDE ${widget.roundNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: CustomColors.textFaint,
                  ),
                ),
                const SizedBox(height: Spacings.small),
                Text(
                  rolling
                      ? 'Das nächste Ziel wird ausgelost'
                      : 'Euer nächstes Zielgewicht',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomColors.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Glass(
                          fillFraction: fillFraction,
                          targetFraction: targetFraction,
                        ),
                      ),
                      const SizedBox(width: Spacings.medium),
                      Expanded(
                        child: _TargetReadout(
                          value: value,
                          current: current,
                          rolling: rolling,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 18,
                  child: Text(
                    rolling
                        ? '30 – 80 g weniger als ${formatWeight(current)} g'
                        : '−${formatWeight(current - _target)} g gegenüber '
                            '${formatWeight(current)} g',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomColors.textFaint,
                    ),
                  ),
                ),
                const SizedBox(height: Spacings.medium),
                _StartRoundButton(
                  enabled: !rolling,
                  onTap: () => Navigator.of(context).pop(_target),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.fillFraction, required this.targetFraction});

  final double fillFraction;
  final double targetFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: CustomColors.tileBg,
            border: Border.all(color: const Color(0x1A000000)),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
              bottom: Radius.circular(14),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
              bottom: Radius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: height * fillFraction,
                  child: Column(
                    children: [
                      Container(height: 10, color: const Color(0xFFFFF3DC)),
                      const Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFC55C), Color(0xFFF0A020)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * targetFraction,
                  height: 2,
                  child: const ColoredBox(color: Color(0xE6789283)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TargetReadout extends StatelessWidget {
  const _TargetReadout({
    required this.value,
    required this.current,
    required this.rolling,
  });

  final int value;
  final double current;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ZIEL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: CustomColors.textFaint,
          ),
        ),
        const SizedBox(height: Spacings.small),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                fontSize: 42,
                letterSpacing: -1.5,
                height: 1,
                color:
                    rolling ? CustomColors.textFaint : CustomColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'g',
              style: TextStyle(fontSize: 17, color: CustomColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: Spacings.small),
        Text(
          'von ${formatWeight(current)} g',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: CustomColors.textFaint,
          ),
        ),
      ],
    );
  }
}

class _StartRoundButton extends StatelessWidget {
  const _StartRoundButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? CustomColors.primaryColor : CustomColors.trackBg,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            enabled ? 'Runde starten' : 'Wird ausgelost …',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color:
                  enabled
                      ? CustomColors.onPrimaryDark
                      : CustomColors.disabledText,
            ),
          ),
        ),
      ),
    );
  }
}
