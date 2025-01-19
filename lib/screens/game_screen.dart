import 'package:flutter/material.dart';

class Player {
  final String name;
  Measurement initialWeight;

  Player(this.name, this.initialWeight);
}

class Measurement {
  TextEditingController controller;
  double value;

  Measurement(this.controller, this.value);
}

class GameRound {
  Measurement target;
  List<Measurement> measurements;

  GameRound(this.target, this.measurements);
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Player> _players = [];
  List<GameRound> rounds = [];

  @override
  void initState() {
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
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> playerWidgets = [];

    List<Widget> initialWeight = [];
    initialWeight.add(Text("Einwiegen"));

    for (final player in _players) {
      playerWidgets.add(
        Container(
          child: Text(player.name),
        ),
      );
      initialWeight.add(
        TextField(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (result) {
            print(result);
            final r = double.tryParse(result);
            if (r != null) {
              player.initialWeight.value = r;
            }

            // wenn die aktuelle runde eingetragen ist
            if (!_players.any((player) => player.initialWeight.value == 0)) {
              print("adding round");
              var newRound = GameRound(
                Measurement(TextEditingController(), 0),
                [],
              );

              for (final player in _players) {
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
              // add round
            }
          },
          controller: player.initialWeight.controller,
        ),
      );
    }

    List<Widget> roundsWidgets = [];

    for (final round in rounds) {
      roundsWidgets.add(
        TextField(
          controller: round.target.controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
      );
      for (final measurement in round.measurements) {
        roundsWidgets.add(
          TextField(
            controller: measurement.controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bierwiegen"),
      ),
      body: Center(
        child: GridView.count(
          childAspectRatio: 4.0,
          primary: true,
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          crossAxisCount: widget.playerNames.length + 1,
          children: [
            Container(),
            ...playerWidgets,
            ...initialWeight,
            ...roundsWidgets,
          ],
        ),
      ),
    );
  }
}
