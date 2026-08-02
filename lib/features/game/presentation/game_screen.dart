import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/button_styles.dart';
import '../../../ui/text_styles.dart';
import '../../settings/options_screen.dart';
import '../domain/player.dart';
import '../state/game_providers.dart';
import 'cell_registry.dart';
import 'dialogs.dart';
import 'submit_flow.dart';
import 'widgets/confetti_widget.dart';
import 'widgets/measurement_cell.dart';
import 'widgets/player_header_cell.dart';
import 'widgets/target_cell.dart';
import 'widgets/weight_input_field.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = game.players.length + 1;
    final spacing = 8.0;

    final itemWidth =
        (screenWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
    final itemHeight = 60.0;

    final childAspectRatio = itemWidth / itemHeight;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OptionsScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.more_horiz),
              ),
            ],
            title: Text('Bierwiegen'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
                top: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    childAspectRatio: childAspectRatio,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Center(child: Text('Ziel')),
                      ...List.generate(
                        game.players.length,
                        (i) => PlayerHeaderCell(playerIndex: i),
                      ),
                    ],
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              childAspectRatio: childAspectRatio,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                SizedBox.shrink(),
                                ...List.generate(game.players.length, (i) {
                                  return Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(spacing / 2),
                                    child: WeightInputField(
                                      cellKey: CellRegistry.initialWeightKey(i),
                                      value: game.players[i].initialWeight,
                                      onValueChanged: (value) => ref
                                          .read(gameProvider.notifier)
                                          .setInitialWeight(i, value),
                                      onSubmitted: () => handleCellSubmitted(
                                        context,
                                        ref,
                                        isInitialWeight: true,
                                        playerIndex: i,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            ...List.generate(game.rounds.length, (i) {
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                childAspectRatio: childAspectRatio,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  TargetCell(roundIndex: i),
                                  ...List.generate(
                                    game.players.length,
                                    (j) => MeasurementCell(
                                      roundIndex: i,
                                      playerIndex: j,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!game.isFinished && game.hasFinishedRound)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: ButtonStyles.secondary,
                        onPressed: () async {
                          await Dialogs.finishGameDialog(context, ref);
                        },
                        child: Text("Spiel beenden"),
                      ),
                    ),
                  if (game.isFinished) ...[
                    Text(
                      ref.watch(winningPlayersProvider).length == 1
                          ? 'Der Gewinner ist'
                          : 'Die Gewinner sind',
                    ),
                    Text(
                      _winnerNames(ref.watch(winningPlayersProvider)),
                      style: TextStyles.heading,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: ButtonStyles.primary,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Neues Spiel starten"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        WinnerConfetti(key: WinnerConfetti.globalKey),
      ],
    );
  }

  String _winnerNames(List<Player> winners) {
    if (winners.isEmpty) {
      return '';
    }

    if (winners.length == 1) {
      return winners.first.name;
    }

    if (winners.length == 2) {
      return '${winners[0].name} und ${winners[1].name}';
    }

    final allButLast = winners
        .sublist(0, winners.length - 1)
        .map((p) => p.name)
        .join(', ');
    return '$allButLast, und ${winners.last.name}';
  }
}
