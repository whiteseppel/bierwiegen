import 'package:flutter/material.dart';

Future<double?> showWeightInputDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();

  return await showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Zielgewicht eingeben'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Zielgewicht ...',
            border: OutlineInputBorder(),
          ),
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
              final text = controller.text;
              final value = double.tryParse(text);

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
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
