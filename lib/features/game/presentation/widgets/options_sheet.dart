import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../../account/settings_screen.dart';
import '../../../scale/scale_provider.dart';
import '../../domain/game_config.dart';
import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../dialogs.dart';
import 'choice_tile.dart';
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
    final targetMode = game?.config.targetMode ?? TargetMode.manual;

    final settingsSummary =
        '${mode == GameMode.points ? 'Punkte' : 'Standard'}'
        ' · ${targetMode == TargetMode.auto ? 'Auto' : 'Manuell'}';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const _Grabber(),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 6, 24, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENÜ',
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
            label: 'Konto & Verbindung',
            value: chip.label,
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _OptionItem(
            dot: CustomColors.primaryColor,
            label: 'Spieleinstellungen',
            value: settingsSummary,
            onTap:
                game == null
                    ? null
                    : () {
                      Navigator.of(context).pop();
                      showGameSettingsSheet(context);
                    },
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

Future<void> showGameSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _GameSettingsSheet(),
  );
}

class _GameSettingsSheet extends ConsumerWidget {
  const _GameSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final mode = game?.config.mode ?? GameMode.standard;
    final targetMode = game?.config.targetMode ?? TargetMode.manual;
    final notifier = ref.read(gameProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: _Grabber()),
            const SizedBox(height: Spacings.medium),
            const Text(
              'Spieleinstellungen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Wertung'),
            const SizedBox(height: Spacings.small),
            ChoiceTile(
              label: 'Standard',
              description: 'Wer am nächsten dran ist, gewinnt die Runde.',
              selected: mode == GameMode.standard,
              onTap: () => notifier.setMode(GameMode.standard),
            ),
            const SizedBox(height: Spacings.small),
            ChoiceTile(
              label: 'Punkte',
              description:
                  '3 / 2 / 1 nach Platzierung, exakt getroffen zählt 5.',
              selected: mode == GameMode.points,
              onTap: () => notifier.setMode(GameMode.points),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Zielvorgabe'),
            const SizedBox(height: Spacings.small),
            ChoiceTile(
              label: 'Automatische Ziele',
              description:
                  'Das nächste Ziel wird ausgelost: 25 – 70 g unter dem '
                  'aktuellen.',
              selected: targetMode == TargetMode.auto,
              onTap: () => notifier.setTargetMode(TargetMode.auto),
            ),
            const SizedBox(height: Spacings.small),
            ChoiceTile(
              label: 'Manuelle Ziele',
              description: 'Ihr legt das Zielgewicht jeder Runde selbst fest.',
              selected: targetMode == TargetMode.manual,
              onTap: () => notifier.setTargetMode(TargetMode.manual),
            ),
            const SizedBox(height: 22),
            _ApplyButton(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.primaryColor,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      elevation: 2,
      shadowColor: CustomColors.goldFocusRing,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: const Text(
            'Übernehmen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CustomColors.onPrimaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0x26000000),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: CustomColors.textFaint,
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
        padding: const EdgeInsets.symmetric(horizontal: Spacings.large),
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
            const SizedBox(width: Spacings.medium),
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
