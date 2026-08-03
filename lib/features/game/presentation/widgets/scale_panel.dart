import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../../scale/scale_provider.dart';
import '../../../scale/scale_state.dart';
import '../../domain/game.dart';
import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../cell_registry.dart';
import '../format.dart';
import '../submit_flow.dart';
import 'scale_chip.dart';

/// Bottom panel shown while a table cell is focused: live scale weight,
/// stability progress and the keyboard/scale input toggles.
class ScalePanel extends ConsumerStatefulWidget {
  const ScalePanel({super.key});

  @override
  ConsumerState<ScalePanel> createState() => _ScalePanelState();
}

class _ScalePanelState extends ConsumerState<ScalePanel> {
  String? _committedHint;

  @override
  Widget build(BuildContext context) {
    final cell = ref.watch(focusedCellProvider);
    final game = ref.watch(gameProvider);
    if (cell == null || game == null || game.isFinished) {
      return const SizedBox.shrink();
    }

    ref.listen(focusedCellProvider, (previous, next) {
      if (previous != next && _committedHint != null) {
        setState(() => _committedHint = null);
      }
    });
    ref.listen(scaleProvider, _onScaleChanged);

    final scale = ref.watch(scaleProvider);
    final paused = ref.watch(scalePausedProvider);
    final keyboardOpen = ref.watch(keyboardOpenProvider);
    final chip = ScaleChipData.of(scale, paused: paused);
    final liveOn = chip.connected && !paused;

    final target = cell.round < 0 ? null : game.rounds[cell.round].target;
    final previous = game.previousWeight(cell.round, cell.player);

    return TapRegion(
      groupId: weightInputTapGroup,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x2E000000),
              offset: Offset(0, -8),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x26000000),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    game.players[cell.player].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                ),
                ScaleChip(
                  data: chip,
                  height: 30,
                  label:
                      chip.connected
                          ? (paused ? 'Waage aus' : 'Waage an')
                          : null,
                  onTap: () => _onScaleChipTap(chip, paused),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _toggleKeyboard(keyboardOpen),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          keyboardOpen
                              ? CustomColors.goldTint
                              : CustomColors.neutralChipBg,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      keyboardOpen ? 'Tastatur aus' : 'Tastatur',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color:
                            keyboardOpen
                                ? CustomColors.goldTextDark
                                : CustomColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  liveOn && (scale.liveWeight ?? 0) != 0
                      ? '${scale.liveWeight}'
                      : '—',
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                    letterSpacing: -1,
                    height: 1,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'g',
                  style: TextStyle(fontSize: 18, color: CustomColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    background: CustomColors.tileBg,
                    labelColor: CustomColors.textMuted,
                    valueColor: CustomColors.textPrimary,
                    label: 'AKTUELL',
                    value:
                        previous == null ? '–' : '${formatWeight(previous)} g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    background: CustomColors.greenTint,
                    labelColor: CustomColors.greenMuted,
                    valueColor: CustomColors.greenDark,
                    label: 'NOCH TRINKEN',
                    value: _goalLabel(scale, liveOn, target, previous),
                  ),
                ),
              ],
            ),
            if (liveOn) ...[
              const SizedBox(height: 14),
              _StabilityBar(scale: scale),
            ],
            const SizedBox(height: 8),
            Center(
              child: Text(
                _hint(scale, chip, paused),
                style: const TextStyle(
                  fontSize: 12,
                  color: CustomColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _goalLabel(
    ScaleState scale,
    bool liveOn,
    double? target,
    double? previous,
  ) {
    if (target == null) {
      return 'Startgewicht';
    }

    final basis =
        liveOn && (scale.liveWeight ?? 0) != 0
            ? scale.liveWeight!.toDouble()
            : previous;
    if (basis == null) {
      return '–';
    }

    final diff = basis - target;
    return diff >= 0
        ? '${formatWeight(diff)} g'
        : '${formatWeight(-diff)} g zu wenig';
  }

  String _hint(ScaleState scale, ScaleChipData chip, bool paused) {
    final committed = _committedHint;
    if (committed != null) {
      return committed;
    }
    if (!chip.connected) {
      return 'Keine Waage verbunden – Eingabe per Tastatur';
    }
    if (paused) {
      return 'Waage pausiert – Eingabe per Tastatur';
    }
    return (scale.liveWeight ?? 0) == 0
        ? 'Glas auf die Waage stellen'
        : 'Ruhig halten …';
  }

  void _toggleKeyboard(bool open) {
    ref.read(keyboardOpenProvider.notifier).state = !open;
    SystemChannels.textInput.invokeMethod(
      open ? 'TextInput.hide' : 'TextInput.show',
    );
  }

  void _onScaleChipTap(ScaleChipData chip, bool paused) {
    if (chip.connected) {
      ref.read(scalePausedProvider.notifier).state = !paused;
      // Pausing hands input over to the keyboard, resuming back to the scale.
      _toggleKeyboard(paused);
    } else {
      ref.read(scaleProvider.notifier).tryConnect();
    }
  }

  void _onScaleChanged(ScaleState? previous, ScaleState next) {
    final cell = ref.read(focusedCellProvider);
    final game = ref.read(gameProvider);
    if (cell == null ||
        game == null ||
        game.isFinished ||
        ref.read(scalePausedProvider)) {
      return;
    }

    final stable = next.stableWeight;
    if (stable == null || stable == previous?.stableWeight || stable <= 0) {
      return;
    }

    if (_cellValue(game, cell) != 0) {
      return;
    }

    ref.read(cellRegistryProvider).controller(_registryKey(cell)).text =
        stable.toString();
    final notifier = ref.read(gameProvider.notifier);
    if (cell.round < 0) {
      notifier.setInitialWeight(cell.player, stable.toDouble());
    } else {
      notifier.setMeasurement(cell.round, cell.player, stable.toDouble());
    }
    setState(() => _committedHint = 'Dein Bier hat $stable Gramm!');

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && ref.read(focusedCellProvider) == cell) {
        handleCellSubmitted(
          context,
          ref,
          isInitialWeight: cell.round < 0,
          playerIndex: cell.player,
        );
      }
    });
  }

  double _cellValue(Game game, CellRef cell) =>
      cell.round < 0
          ? game.players[cell.player].initialWeight
          : game.rounds[cell.round].measurements[cell.player];

  String _registryKey(CellRef cell) =>
      cell.round < 0
          ? CellRegistry.initialWeightKey(cell.player)
          : CellRegistry.measurementKey(cell.round, cell.player);
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.background,
    required this.labelColor,
    required this.valueColor,
    required this.label,
    required this.value,
  });

  final Color background;
  final Color labelColor;
  final Color valueColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StabilityBar extends StatelessWidget {
  const _StabilityBar({required this.scale});

  final ScaleState scale;

  @override
  Widget build(BuildContext context) {
    final live = scale.liveWeight ?? 0;

    Widget fill;
    if (scale.stableWeight != null) {
      fill = const FractionallySizedBox(widthFactor: 1, child: _fillBox);
    } else if (live != 0) {
      // Mirrors the notifier's stability timer: full bar after 2s of
      // unchanged weight, restarted whenever the live weight changes.
      fill = TweenAnimationBuilder<double>(
        key: ValueKey(live),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        builder:
            (context, factor, child) =>
                FractionallySizedBox(widthFactor: factor, child: child),
        child: _fillBox,
      );
    } else {
      fill = const SizedBox.shrink();
    }

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: CustomColors.trackBg,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: fill,
    );
  }

  static const Widget _fillBox = DecoratedBox(
    decoration: BoxDecoration(
      color: CustomColors.secondaryColor,
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),
    child: SizedBox(height: 6, width: double.infinity),
  );
}
