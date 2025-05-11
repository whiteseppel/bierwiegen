import 'package:bierwiegen/models/scale_state.dart';
import 'package:bierwiegen/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Einstellungen'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
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
                  switch (ref.watch(scaleStateProvider).connectionState) {
                    ScaleConnectionState.disconnected => Icon(Icons.close),
                    ScaleConnectionState.connecting =>
                      CircularProgressIndicator(),
                    ScaleConnectionState.connected => Icon(Icons.done),
                  },
                ],
              ),
              const SizedBox(height: 20),
              if (ref.watch(scaleStateProvider).connectionState ==
                  ScaleConnectionState.connected)
                Text(
                  'Gewicht: ${ref.watch(scaleStateProvider).weight.toString()}',
                ),

              // TODO:
              // - we need a text field where the user is notified why the connection failed
              //    - is bluetooth enabled
              //    - are permissions granted for searching
              //    - is the scale around and can i connect
              //    - does the input of the weight work?
            ],
          ),
        ),
      ),
    );
  }
}
