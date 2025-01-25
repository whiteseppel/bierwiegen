import 'package:bierwiegen/screens/game_screen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<TextEditingController> _playerControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bierwiegen"),
      ),
      body: Container(
        child: Column(
          children: [
            Text("Spieler eingeben"),
            ..._playerControllers.map(
              (element) => TextField(
                controller: element,
                onChanged: (input){
                  if (_playerControllers.last.value.text.isNotEmpty){
                    setState(() {
                      _playerControllers.add(TextEditingController());
                    });
                  }
                },
              ),
            ),
            MaterialButton(
              color: Colors.amber,
              child: Text("Spiel starten"),
              onPressed: () {
                List<String> players = [];
                for (final controller in _playerControllers) {
                  if (controller.value.text.isNotEmpty) {
                    players.add(controller.value.text);
                  }
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(playerNames: players),
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
