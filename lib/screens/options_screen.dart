import 'package:bierwiegen/models/scale_state.dart';
import 'package:bierwiegen/providers/game_round_provider.dart';
import 'package:bierwiegen/providers/player_provider.dart';
import 'package:bierwiegen/widgets/game_info_widget.dart';
import 'package:bierwiegen/widgets/privacy_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/scale_state_provider.dart';
import '../sizes/sizes.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Optionen'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              // if player has no active game dont show this button
              if (ref.read(playerProvider).isNotEmpty &&
                  ref.read(gameRoundProvider).isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyles.regular,
                    onPressed: () {
                      ref.read(gameRoundProvider.notifier).clearRounds();
                      ref.read(playerProvider.notifier).resetInitialWeight();
                      Navigator.of(context).pop();
                    },
                    child: Text("Neues Spiel starten"),
                  ),
                ),
                SizedBox(height: 32),
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth-Digitalwage',
                    textAlign: TextAlign.start,
                    style: TextStyles.subheading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Man kann ausgewählte Bluetooth Küchenwagen mit der App verbinden. Die Werte der Spieler werden danach automatisch von der Wage in die Wertung übernommen.',
                    style: TextStyles.regular,
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: FilledButton(
                      style: ButtonStyles.regular,
                      onPressed:
                          ref.watch(scaleStateProvider).connectionState ==
                                  ScaleConnectionState.disconnected
                              ? ref.read(scaleStateProvider.notifier).tryConnect
                              : null,
                      child: Text(switch (ref
                          .watch(scaleStateProvider)
                          .connectionState) {
                        ScaleConnectionState.disconnected => 'Verbinden',
                        ScaleConnectionState.connecting => 'Verbinde ...',
                        ScaleConnectionState.connected => 'Verbunden',
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (ref.watch(scaleStateProvider).connectionState ==
                      ScaleConnectionState.connected)
                    Text(
                      'Gewicht: ${ref.watch(scaleStateProvider).weight.toString()}',
                    ),
                ],
              ),
              SizedBox(height: 32),

              // TODO:
              // - we need a text field where the user is notified why the connection failed
              //    - is bluetooth enabled
              //    - are permissions granted for searching
              //    - is the scale around and can i connect
              //    - does the input of the weight work?
              GameInfoWidget(),
              SizedBox(height: 32),
              PrivacyWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
