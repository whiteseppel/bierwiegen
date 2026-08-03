import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/tokens.dart';
import '../state/game_providers.dart';
import '../state/game_ui_providers.dart';
import 'format.dart';
import 'widgets/confetti_widget.dart';

class Dialogs {
  static Future<double?> weightInputDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    double? initialValue,
  }) async {
    final controller = TextEditingController(
      text: initialValue == null ? '' : formatWeight(initialValue),
    );

    return await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        void handleSubmission() {
          final value = double.tryParse(controller.text);
          if (value != null) {
            Navigator.of(context).pop(value);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitte gib eine gültige Nummer ein'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        return _styledDialog(
          title: title,
          body: body,
          confirmLabel: confirmLabel,
          onConfirm: handleSubmission,
          onCancel: () => Navigator.of(context).pop(null),
          input: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: CustomColors.textPrimary,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAF9F6),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x33000000)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: CustomColors.primaryColor,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => handleSubmission(),
          ),
        );
      },
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
      builder: (context) => _styledDialog(
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
    ref.read(gameProvider.notifier).finishGame();
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
          if (input != null) ...[const SizedBox(height: 16), input],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: CustomColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: CustomColors.primaryColor,
            foregroundColor: CustomColors.onPrimaryDark,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
