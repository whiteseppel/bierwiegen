import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sizes/sizes.dart';
import '../sizes/strings.dart';

class PrivacyAndImprintScreen extends ConsumerStatefulWidget {
  const PrivacyAndImprintScreen({super.key});

  @override
  _PrivacyAndImprintScreenState createState() =>
      _PrivacyAndImprintScreenState();
}

class _PrivacyAndImprintScreenState
    extends ConsumerState<PrivacyAndImprintScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datenschutz & Impressum'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Datenschutz', style: TextStyles.subheading),
                Text(AppStrings.privacy),

                Text('Impressum', style: TextStyles.subheading),
                Text(AppStrings.imprint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
