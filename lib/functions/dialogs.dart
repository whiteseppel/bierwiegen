import 'package:bierwiegen/providers/game_meta_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Dialogs {
  static Future<double?> showWeightInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();

    return await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        Future.microtask(() => focusNode.requestFocus());

        void handleSubmission() {
          final value = double.tryParse(controller.text);
          if (value != null) {
            Future.microtask(() {
              print('');
            });
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

        return AlertDialog(
          title: const Text('Zielgewicht eingeben'),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Zielgewicht ...',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              LengthLimitingTextInputFormatter(5),
            ],
            onSubmitted: (_) {
              handleSubmission();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                handleSubmission();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> finishGameDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spiel beenden'),
          content: Text('Möchtest du das Spiel wirklich beenden?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                ref.read(gameMetaDataProvider.notifier).finishGame();
                Navigator.of(context).pop();
              },
              child: const Text('Beenden'),
            ),
          ],
        );
      },
    );
  }
}
