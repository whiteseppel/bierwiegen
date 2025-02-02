import 'package:flutter/material.dart';

import '../models/game_round.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Player> players = [];
  List<GameRound> rounds = [];
  List<Widget> allWidgets = [];

  @override
  void initState() {
    super.initState();
    allWidgets.add(IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back)));
    for (final name in widget.playerNames) {
      players.add(
        Player(
          name,
          Measurement(
            TextEditingController(),
            0,
          ),
        ),
      );
      // add one container - we need it for the grid view to be correct
      allWidgets.add(
        Container(
          child: Text(name),
        ),
      );
    }
    addInitialRound();
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

  addInitialRound() {
    print('adding initial round');
    allWidgets.add(Text("Einwiegen"));
    for (final player in players) {
      allWidgets.add(
        TextField(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (result) async {
            print('Result Einwiegen: $result');
            final r = double.tryParse(result);
            if (r != null) {
              print('seeting weight for player $player');
              player.initialWeight.value = r;
            }

            if (!players.any((player) => player.initialWeight.value == 0)) {
              if (rounds.isEmpty || rounds.last.isFinished) {
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

  addRound(double weight) {
    allWidgets.add(Text(
      'Zielgewicht: $weight',
    ));
    var newRound = GameRound(
      weight,
      [],
    );

    for (final _ in players) {
      newRound.measurements.add(
        Measurement(
          TextEditingController(),
          0,
        ),
      );
    }
    for (final measurement in newRound.measurements) {
      allWidgets.add(
        TextField(
          controller: measurement.controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (result) async {
            // add the value to the measurement
            final r = double.tryParse(result);

            if (r == null) {
              print('value could not be converted');
              // wenn wir die nummer nicht parsen können müssen wir den wert löschen
              return;
            }
            print('setting value for round: $r');

            measurement.value = r;
            print('new round is finished: ${newRound.isFinished}');

            if (newRound.isFinished) {
              print('adding new round');
              // after evaluation add new round to the game
              final weight = await showDoubleInputDialog(context);

              if (weight == null) {
                return;
              }

              addRound(weight);
            }
          },
        ),
      );
    }

    setState(() {
      rounds.add(newRound);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.playerNames.length + 1,
            childAspectRatio: 1,
            mainAxisExtent: 50,
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
