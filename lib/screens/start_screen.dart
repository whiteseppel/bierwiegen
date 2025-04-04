import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/providers/providers.dart';
import 'package:bierwiegen/screens/game_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';

import '../models/player.dart';

class StartScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final List<TextEditingController> _playerControllers = [
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bierwiegen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Spieler eingeben"),
            ..._playerControllers.map(
              (element) => TextField(
                textInputAction: TextInputAction.next,
                controller: element,
                onChanged: (input) {
                  if (!_playerControllers.any((c) => c.value.text.isEmpty)) {
                    setState(() {
                      _playerControllers.add(TextEditingController());
                    });
                  }
                },
              ),
            ),
            MaterialButton(
              color: Colors.amber,
              child: const Text("Spiel starten"),
              onPressed: () {
                ref.read(playerProvider.notifier).clearPlayers();
                List<String> players = [];
                for (final controller in _playerControllers) {
                  if (controller.value.text.isNotEmpty) {
                    players.add(controller.value.text);
                    ref.read(playerProvider.notifier).addPlayer(
                          Player(
                            controller.value.text,
                            Measurement(TextEditingController(), 0),
                          ),
                        );
                  }
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
