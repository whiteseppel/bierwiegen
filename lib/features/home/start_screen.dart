import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../ui/button_styles.dart';
import '../../ui/tokens.dart';
import '../game/presentation/game_screen.dart';
import '../game/state/game_providers.dart';
import '../info/game_info_widget.dart';
import '../settings/options_screen.dart';

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
                    style: ButtonStyles.primary,
                    onPressed:
                        _playerControllers.any((c) => c.text.isNotEmpty)
                            ? startGame
                            : null,
                    child: const Text("Spiel starten"),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyles.primary,
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
                const SizedBox(height: 40),
                const GameInfoWidget(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
  }

  void startGame() {
    final names = [
      for (final controller in _playerControllers)
        if (controller.text.isNotEmpty) controller.text,
    ];

    if (names.isEmpty) {
      return;
    }

    ref.read(gameProvider.notifier).startGame(names);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }
}
