import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../../scale/scale_provider.dart';
import '../../../scale/scale_state.dart';
import '../../../settings/options_screen.dart';
import '../../domain/game_config.dart';
import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../dialogs.dart';
import 'scale_chip.dart';

Future<void> showOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _OptionsSheet(),
  );
}

class _OptionsSheet extends ConsumerWidget {
  const _OptionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final scale = ref.watch(scaleProvider);
    final paused = ref.watch(scalePausedProvider);
    final chip = ScaleChipData.of(scale, paused: paused);
    final mode = game?.config.mode ?? GameMode.standard;

    final connecting = switch (scale.connectionState) {
      ScaleConnectionState.scanning ||
      ScaleConnectionState.connecting ||
      ScaleConnectionState.reconnecting => true,
      _ => false,
    };

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x26000000),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 6, 24, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OPTIONEN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: CustomColors.textMuted,
                ),
              ),
            ),
          ),
          _OptionItem(
            dot: chip.dot,
            label: 'Waage verbinden',
            value: chip.label,
            onTap: chip.connected || connecting
                ? null
                : () => ref.read(scaleProvider.notifier).tryConnect(),
          ),
          _OptionItem(
            dot: CustomColors.primaryColor,
            label: 'Spielmodus',
            value: mode == GameMode.points ? 'Punkte' : 'Standard',
            onTap: game == null
                ? null
                : () => ref.read(gameProvider.notifier).setMode(
                      mode == GameMode.points
                          ? GameMode.standard
                          : GameMode.points,
                    ),
          ),
          _OptionItem(
            dot: CustomColors.neutralDot,
            label: 'Spiel zurücksetzen',
            value: '',
            onTap: () async {
              final confirmed = await Dialogs.confirmDialog(
                context,
                title: 'Spiel zurücksetzen?',
                body: 'Alle Runden gehen verloren.',
                confirmLabel: 'Zurücksetzen',
              );
              if (!confirmed || !context.mounted) {
                return;
              }
              Navigator.of(context).popUntil((route) => route.isFirst);
              ref.read(gameProvider.notifier).resetForNewGame();
            },
          ),
          _OptionItem(
            dot: CustomColors.secondaryColor,
            label: 'Info & Datenschutz',
            value: '',
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute(builder: (context) => const OptionsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({
    required this.dot,
    required this.label,
    required this.value,
    this.onTap,
  });

  final Color dot;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: CustomColors.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: CustomColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
