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
        child: Container(
          padding: EdgeInsets.all(10),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _StickyHeaderDelegate(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: Row(
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
                  ),
                  // NOTE: this caused an error when setting it to 50 or more
                  height: 40,
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
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
                                  if (rounds.isEmpty ||
                                      rounds.last.isFinished) {
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
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.playerNames.length + 1,
                  childAspectRatio: 1,
                  mainAxisExtent: 50,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      child: allWidgets[index],
                    );
                  },
                  childCount: allWidgets.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
