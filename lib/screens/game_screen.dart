import 'package:bierwiegen/screens/options_screen.dart';
import 'package:bierwiegen/widgets/weight_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_round_provider.dart';
import '../providers/player_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = ref.read(playerProvider).length + 1;
    final spacing = 8.0;

    final itemWidth =
        (screenWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
    final itemHeight = 60.0;

    final childAspectRatio = itemWidth / itemHeight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // NOTE: players
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                childAspectRatio: childAspectRatio,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OptionsScreen(),
                        ),
                      );
                    },
                  ),

                  ...List.generate(ref.read(playerProvider).length, (i) {
                    int winsByPlayer = 0;
                    for (final r in ref.read(gameRoundProvider)) {
                      if (r.winningIndex == i) {
                        winsByPlayer++;
                      }
                    }
                    return Column(
                      children: [
                        Text(
                          ref.read(playerProvider)[i].name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (winsByPlayer > 0) ...[
                          Text(
                            winsByPlayer.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    );
                  }),
                ],
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // NOTE: initial weight
                        GridView.count(
                          crossAxisCount: ref.read(playerProvider).length + 1,
                          shrinkWrap: true,
                          childAspectRatio: childAspectRatio,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(spacing / 2),
                              child: const Text(
                                "Ziel",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ...ref
                                .read(playerProvider)
                                .map(
                                  (player) => Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(spacing / 2),
                                    child: WeightInputField(
                                      player.initialWeight,
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        // NOTE: All game rounds
                        ...List.generate(ref.watch(gameRoundProvider).length, (
                          i,
                        ) {
                          final round = ref.watch(gameRoundProvider)[i];

                          // NOTE: single game round
                          String target = round.target.toString();
                          target = target.substring(0, target.length - 2);
                          return GridView.count(
                            crossAxisCount: ref.read(playerProvider).length + 1,
                            shrinkWrap: true,
                            childAspectRatio: childAspectRatio,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  enabled: false,
                                  controller:
                                      TextEditingController()..text = target,
                                ),
                              ),
                              ...List.generate(round.measurements.length, (j) {
                                final measurement = round.measurements[j];
                                return Container(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      if (round.winningIndex == j)
                                        Icon(
                                          Icons.star,
                                          // NOTE: when we use a scale we have to calculate the exact number by grams
                                          color:
                                              round.target == measurement.value
                                                  ? Colors.amber
                                                  : Colors.green,
                                        ),
                                      WeightInputField(measurement),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
