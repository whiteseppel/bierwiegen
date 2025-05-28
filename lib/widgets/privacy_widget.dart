import 'package:bierwiegen/screens/privacy_and_imprint.dart';
import 'package:flutter/material.dart';

class PrivacyWidget extends StatelessWidget {
  const PrivacyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Datenschutz & Impressum', textAlign: TextAlign.center),
        IconButton(
          icon: Icon(Icons.info_outlined, size: 32),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacyAndImprintScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
