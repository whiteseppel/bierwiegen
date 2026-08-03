import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/button_styles.dart';
import '../../ui/text_styles.dart';
import '../info/game_info_widget.dart';
import '../info/privacy_widget.dart';
import '../scale/scale_provider.dart';
import '../scale/scale_state.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    final scale = ref.watch(scaleProvider);
    final canConnect = switch (scale.connectionState) {
      ScaleConnectionState.disconnected ||
      ScaleConnectionState.notFound ||
      ScaleConnectionState.error => true,
      ScaleConnectionState.scanning ||
      ScaleConnectionState.connecting ||
      ScaleConnectionState.reconnecting ||
      ScaleConnectionState.connected => false,
    };

    return Scaffold(
      appBar: AppBar(title: Text('Optionen'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyles.primary,
                      onPressed: canConnect
                          ? ref.read(scaleProvider.notifier).tryConnect
                          : null,
                      child: Text(switch (scale.connectionState) {
                        ScaleConnectionState.disconnected ||
                        ScaleConnectionState.notFound ||
                        ScaleConnectionState.error => 'Verbinden',
                        ScaleConnectionState.scanning => 'Suche Waage ...',
                        ScaleConnectionState.connecting => 'Verbinde ...',
                        ScaleConnectionState.reconnecting =>
                          'Verbindung verloren, verbinde neu ...',
                        ScaleConnectionState.connected => 'Verbunden',
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (scale.connectionState == ScaleConnectionState.notFound)
                    Text('Keine Waage gefunden'),
                  if (scale.connectionState == ScaleConnectionState.error)
                    Text(scale.errorMessage ?? 'Verbindung fehlgeschlagen'),
                  if (scale.connectionState == ScaleConnectionState.connected)
                    Text('Gewicht: ${scale.liveWeight ?? 0}'),
                ],
              ),
              SizedBox(height: 32),
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
