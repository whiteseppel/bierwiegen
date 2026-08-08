import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/tokens.dart';
import '../../history/game_history_provider.dart';
import '../state/game_providers.dart';
import '../state/game_ui_providers.dart';
import 'format.dart';
import 'widgets/confetti_widget.dart';

class Dialogs {
  /// Asks for a round's target weight, showing a beer glass that fills relative
  /// to [fromWeight] (the weight the round starts from) as the value is typed.
  static Future<double?> targetWeightDialog(
    BuildContext context, {
    required String eyebrow,
    required String caption,
    required String confirmLabel,
    required double fromWeight,
    double? initialValue,
  }) {
    return showDialog<double>(
      context: context,
      barrierColor: const Color(0x6B000000),
      builder:
          (context) => _TargetWeightDialog(
            eyebrow: eyebrow,
            caption: caption,
            confirmLabel: confirmLabel,
            fromWeight: fromWeight,
            initialValue: initialValue,
          ),
    );
  }

  static Future<bool> confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => _styledDialog(
            title: title,
            body: body,
            confirmLabel: confirmLabel,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
    return confirmed ?? false;
  }

  static Future<void> finishGameDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Spiel beenden?',
      body: 'Die Tabelle wird gesperrt und der Gewinner ermittelt.',
      confirmLabel: 'Beenden',
    );
    if (!confirmed) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(focusedCellProvider.notifier).state = null;
    ref.read(keyboardOpenProvider.notifier).state = false;
    ref.read(gameProvider.notifier).finishGame();

    final finished = ref.read(gameProvider);
    if (finished != null) {
      ref.read(gameHistoryProvider.notifier).record(finished);
    }

    ref.read(resultOpenProvider.notifier).state = true;
    WinnerConfetti.globalKey.currentState?.playConfetti();
  }

  static Widget _styledDialog({
    required String title,
    required String body,
    required String confirmLabel,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    Widget? input,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: CustomColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: CustomColors.textMuted,
            ),
          ),
          if (input != null) ...[
            const SizedBox(height: Spacings.medium),
            input,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: CustomColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(standardBorderRadius),
            ),
          ),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: CustomColors.primaryColor,
            foregroundColor: CustomColors.onPrimaryDark,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(standardBorderRadius),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _TargetWeightDialog extends StatefulWidget {
  const _TargetWeightDialog({
    required this.eyebrow,
    required this.caption,
    required this.confirmLabel,
    required this.fromWeight,
    this.initialValue,
  });

  final String eyebrow;
  final String caption;
  final String confirmLabel;
  final double fromWeight;
  final double? initialValue;

  @override
  State<_TargetWeightDialog> createState() => _TargetWeightDialogState();
}

class _TargetWeightDialogState extends State<_TargetWeightDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue == null
        ? ''
        : formatWeight(widget.initialValue!),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _value => double.tryParse(_controller.text);

  void _confirm() {
    final value = _value;
    if (value != null) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final from = widget.fromWeight;
    final fillFactor =
        from <= 0 ? 0.0 : ((value ?? 0) / from).clamp(0.0, 1.0);
    final hasValue = value != null;

    final String sub;
    if (value == null) {
      sub = 'Gib das Ziel für diese Runde ein.';
    } else if (value >= from) {
      sub = 'Das Ziel sollte unter ${formatWeight(from)} g liegen.';
    } else {
      sub =
          '−${formatWeight(from - value)} g gegenüber ${formatWeight(from)} g';
    }

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 296,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.eyebrow.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: CustomColors.textFaint,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.caption,
              textAlign: TextAlign.center,
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
                  Expanded(child: _BeerGlass(fillFactor: fillFactor)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
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
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _confirm(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(5),
                                ],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 42,
                                  letterSpacing: -1.5,
                                  height: 1.1,
                                  color: CustomColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.only(bottom: 2),
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: CustomColors.disabledText,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x8CFEAD2E),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CustomColors.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'g',
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'von ${formatWeight(from)} g',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: CustomColors.textFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 18,
              child: Text(
                sub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: CustomColors.textFaint,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: CustomColors.textMuted,
                    minimumSize: const Size(0, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(standardBorderRadius),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: hasValue ? _confirm : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: CustomColors.primaryColor,
                      foregroundColor: CustomColors.onPrimaryDark,
                      disabledBackgroundColor: CustomColors.trackBg,
                      disabledForegroundColor: CustomColors.disabledText,
                      minimumSize: const Size(0, 50),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          standardBorderRadius,
                        ),
                      ),
                    ),
                    child: Text(widget.confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A stylised glass filled from the bottom to [fillFactor] (0–1), with a foam
/// cap and a reference line marking the full [fromWeight] level.
class _BeerGlass extends StatelessWidget {
  const _BeerGlass({required this.fillFactor});

  final double fillFactor;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
      bottomLeft: Radius.circular(14),
      bottomRight: Radius.circular(14),
    );

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.tileBg,
          border: Border.all(color: const Color(0x1A000000)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: fillFactor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      const ColoredBox(
                        color: Color(0xFFFFF3DC),
                        child: SizedBox(height: 10, width: double.infinity),
                      ),
                      const Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFC55C), Color(0xFFF0A020)],
                            ),
                          ),
                          child: SizedBox(width: double.infinity),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: Color(0xE6789283),
                child: SizedBox(height: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
