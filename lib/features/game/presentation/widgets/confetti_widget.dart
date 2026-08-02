import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class WinnerConfetti extends StatefulWidget {
  const WinnerConfetti({super.key});

  // Use a GlobalKey to access the controller
  static final GlobalKey<_WinnerConfettiState> globalKey =
      GlobalKey<_WinnerConfettiState>();

  @override
  State<WinnerConfetti> createState() => _WinnerConfettiState();
}

class _WinnerConfettiState extends State<WinnerConfetti> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playConfetti() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
        ],
        numberOfParticles: 30,
        gravity: 0.4,
      ),
    );
  }
}
