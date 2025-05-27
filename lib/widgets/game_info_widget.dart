import 'package:flutter/material.dart';

import '../screens/introduction_screen.dart';

class GameInfoWidget extends StatelessWidget {
  const GameInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Was ist Bierwiegen? Wie spiele ich Bierwiegen?',
          textAlign: TextAlign.center,
        ),
        IconButton(
          icon: Icon(Icons.info_outlined, size: 32),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const IntroductionScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
