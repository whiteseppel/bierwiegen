import 'package:bierwiegen/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_round.dart';
import '../models/measurement.dart';
import '../models/player.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  List<Player> players = [];
  List<GameRound> rounds = [];
  List<Widget> allWidgets = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
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
    double spacing = 1.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(spacing / 2),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  ...List.generate(
                    players.length,
                    (i) {
                      return Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(spacing / 2),
                          child: Text(players[i].name),
                        ),
                      );
                    },
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(spacing / 2),
                      child: Text('Einwiegen'),
                    ),
                  ),
                  ...List.generate(
                    players.length,
                    (i) {
                      return Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(spacing / 2),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (result) async {
                              print('Result Einwiegen: $result');
                              final r = double.tryParse(result);
                              if (r != null) {
                                print(
                                    'setting weight for player ${players[i].name}');
                                players[i].initialWeight.value = r;
                              }

                              if (!players.any((player) =>
                                  player.initialWeight.value == 0)) {
                                if (rounds.isEmpty || rounds.last.isFinished) {
                                  final weight =
                                      await showDoubleInputDialog(context);

                                  if (weight == null) {
                                    return;
                                  }

                                  addRound(weight);
                                }
                              }
                            },
                            controller: players[i].initialWeight.controller,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: rounds.length,
                itemBuilder: (context, i) {
                  final round = rounds[i];
                  return Row(
                    children: [
                      Text('Ziel: ${round.target.toString()}'),
                      ...List.generate(round.measurements.length, (j) {
                        final measurement = round.measurements[j];
                        return Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            color:
                                round.winningIndex == j ? Colors.green : null,
                            child: TextField(
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
                                print(
                                    'new round is finished: ${round.isFinished}');

                                if (round.isFinished) {
                                  print('adding new round');
                                  // after evaluation add new round to the game
                                  final weight =
                                      await showDoubleInputDialog(context);

                                  if (weight == null) {
                                    return;
                                  }

                                  addRound(weight);
                                }
                              },
                            ),
                          ),
                        );
                      })
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            // TODO: restarting game
            FloatingActionButton(
              onPressed: () {
                // Action for first button
              },
              child: Icon(Icons.refresh),
              heroTag: "edit",
            ),
            SizedBox(width: 10),
            // TODO: adding round
            FloatingActionButton(
              onPressed: () {
                // Action for second button
              },
              child: Icon(Icons.sports_esports),
              heroTag: "share",
            ),
            SizedBox(width: 10),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Icon(_isExpanded ? Icons.close : Icons.more_vert),
            heroTag: "toggle",
          ),
        ],
      ),
    );
  }
}
