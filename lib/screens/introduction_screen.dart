import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sizes/sizes.dart';
import '../sizes/strings.dart';

class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends ConsumerState<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bierwiegen'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Was ist Bierwiegen?', style: TextStyles.subheading),
                Text(AppStrings.bierwiegenDescription),

                Text(
                  'Was brauche ich für Bierwiegen?',
                  style: TextStyles.subheading,
                ),
                Text(AppStrings.bierwiegenPrerequisites),
                Text(
                  'Wie spiele ich Bierwiegen?',
                  style: TextStyles.subheading,
                ),
                Text(AppStrings.bierwiegenGameRules),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
