import 'package:flutter/material.dart';

import '../../ui/tokens.dart';
import 'account_ui.dart';

/// A plain scrollable text page for the App section's legal entries
/// (Impressum, Datenschutz).
class LegalDetailScreen extends StatelessWidget {
  const LegalDetailScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AccountTopBar(title: title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: CustomColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
