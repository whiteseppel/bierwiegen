import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/screens/game_screen.dart';
import 'package:bierwiegen/screens/introduction_screen.dart';
import 'package:bierwiegen/sizes/sizes.dart';
import 'package:bierwiegen/widgets/game_info_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../models/player.dart';
import '../providers/game_round_provider.dart';
import '../providers/player_provider.dart';
import 'options_screen.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final List<TextEditingController> _playerControllers = [
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Bierwiegen",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Dein Party-Game",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 40,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Gib die Namen der Mitspieler ein und lege direkt los!",
                    textAlign: TextAlign.center,
                  ),
                ),
                ..._playerControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Spieler ...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            standardBorderRadius,
                          ),
                        ),
                        suffixIcon:
                            controller.text.isNotEmpty
                                ? IconButton(
                                  focusNode: FocusNode(skipTraversal: true),
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _playerControllers.removeAt(index);
                                    });
                                  },
                                )
                                : null,
                      ),
                      textInputAction: TextInputAction.next,
                      controller: controller,
                      onChanged: (input) {
                        setState(() {
                          if (!_playerControllers.any(
                            (c) => c.value.text.isEmpty,
                          )) {
                            _playerControllers.add(TextEditingController());
                          }
                        });
                      },
                    ),
                  );
                }),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyles.regular,
                    child: const Text("Spiel starten"),
                    onPressed: () {
                      ref.read(gameRoundProvider.notifier).clearRounds();
                      ref.read(playerProvider.notifier).clearPlayers();
                      List<String> players = [];
                      for (final controller in _playerControllers) {
                        if (controller.value.text.isNotEmpty) {
                          players.add(controller.value.text);
                          ref
                              .read(playerProvider.notifier)
                              .addPlayer(
                                Player(
                                  controller.value.text,
                                  Measurement.empty(),
                                ),
                              );
                        }
                      }

                      if (players.isEmpty) {
                        // TODO: also provide the player a noticable result
                        print('You cannot start without players');
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                const GameInfoWidget(),

                const SizedBox(height: 60),
                // NOTE: Button for the bluetooth connectivity
                //       comment in if bluetooth is further developed
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyles.regular,
                    child: const Text("Einstellungen"),

                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OptionsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
