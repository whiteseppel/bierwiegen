import 'package:bierwiegen/providers/providers.dart';
import 'package:bierwiegen/widgets/initial_input_field.dart';
import 'package:bierwiegen/widgets/weight_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/action_button_row.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
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
                    child: Container(),
                  ),
                  ...List.generate(
                    ref.read(playerProvider).length,
                    (i) {
                      return Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(spacing / 2),
                          child: Text(ref.read(playerProvider)[i].name),
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
                      child: const Text('Einwiegen'),
                    ),
                  ),
                  ...List.generate(
                    ref.read(playerProvider).length,
                    (i) {
                      return Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(spacing / 2),
                          child: InitialInputField(i),
                        ),
                      );
                    },
                  )
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: ref.watch(gameRoundProvider).length,
                itemBuilder: (context, i) {
                  final round = ref.watch(gameRoundProvider)[i];
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
                            child: WeightInputField(measurement),
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
      floatingActionButton: const ActionButtonRow(),
    );
  }
}
