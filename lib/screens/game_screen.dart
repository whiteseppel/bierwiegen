import 'package:flutter/material.dart';

import '../models/game_round.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Player> _players = [];
  List<GameRound> rounds = [];
  List<Widget> allWidgets = [];

  @override
  void initState() {
    super.initState();
    for (final name in widget.playerNames) {
      _players.add(
        Player(
          name,
          Measurement(
            TextEditingController(),
            0,
          ),
        ),
      );
      // add one container - we need it for the grid view to be correct
      allWidgets.add(Container());
      allWidgets.add(
        Container(
          child: Text(name),
        ),
      );
      addInitialRound();
    }
  }

  Future<double?> showDoubleInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zielgewicht eingeben'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Zielgewicht ...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text;
                final value = double.tryParse(text);

                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte gib eine gültige Nummer ein'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  addInitialRound(){
    allWidgets.add(Text("Einwiegen"));
    for (final player in _players) {
      allWidgets.add(
        TextField(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (result) async {
            print(result);
            final r = double.tryParse(result);
            if (r != null) {
              player.initialWeight.value = r;
            }

            if (!_players.any((player) => player.initialWeight.value == 0)) {
              if (rounds.last.isFinished){
                final weight = await showDoubleInputDialog(context);

                if (weight == null) {
                  return;
                }

                addRound(weight);
              }
            }
          },
          controller: player.initialWeight.controller,
        ),
      );
    }
  }

  addRound(double weight){
    var newRound = GameRound(
      weight,
      [],
    );

    for (final _ in _players) {
      newRound.measurements.add(
        Measurement(
          TextEditingController(),
          0,
        ),
      );
    }

    setState(() {
      rounds.add(newRound);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> roundsWidgets = [];

    for (final round in rounds) {
      roundsWidgets.add(Text(round.target.toString()));
      for (final measurement in round.measurements) {
        roundsWidgets.add(
          TextField(
            controller: measurement.controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (result){
              // add the value to the measurement
              final r = double.tryParse(result);

              if(r == null){
                // wenn wir die nummer nicht parsen können müssen wir den wert löschen
                return;
              }

              measurement.value = r;
              if (round.isFinished){
                // evaluate round

                // after evaluation add new round to the game

              }
            },
          ),
        );
      }
    }

    allWidgets.addAll(roundsWidgets);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bierwiegen"),
      ),
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.playerNames.length + 1,
            childAspectRatio: 1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: allWidgets.length,
          primary: true,
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            return Container(
              color: Colors.blue,
              child: allWidgets[index],
            );
          },
        ),
      ),
    );
  }
}
