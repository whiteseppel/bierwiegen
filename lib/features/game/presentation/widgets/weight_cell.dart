import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/tokens.dart';
import '../../../scale/scale_provider.dart';
import '../../../scale/scale_state.dart';
import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../cell_registry.dart';
import '../format.dart';
import '../submit_flow.dart';

const double weightCellWidth = 76;
const double weightCellHeight = 62;

/// One input cell of the score table; [roundIndex] is -1 for the
/// initial-weights row. Input happens via the scale or the in-app keypad,
/// the system keyboard stays closed.
class WeightCell extends ConsumerStatefulWidget {
  const WeightCell({
    super.key,
    required this.roundIndex,
    required this.playerIndex,
  });

  final int roundIndex;
  final int playerIndex;

  @override
  ConsumerState<WeightCell> createState() => _WeightCellState();
}

class _WeightCellState extends ConsumerState<WeightCell> {
  FocusNode? _node;

  CellRef get _cellRef =>
      (round: widget.roundIndex, player: widget.playerIndex);

  String get _registryKey => widget.roundIndex < 0
      ? CellRegistry.initialWeightKey(widget.playerIndex)
      : CellRegistry.measurementKey(widget.roundIndex, widget.playerIndex);

  void _onFocusChange() {
    if (!mounted) {
      return;
    }

    if (_node!.hasFocus) {
      ref.read(focusedCellProvider.notifier).state = _cellRef;
      final scaleLive = ref.read(scaleProvider).connectionState ==
              ScaleConnectionState.connected &&
          !ref.read(scalePausedProvider);
      ref.read(keypadOpenProvider.notifier).state = !scaleLive;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _node!.hasFocus) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
    } else {
      // Deferred so that a sibling cell gaining focus wins over this clear.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_node!.hasFocus &&
            ref.read(focusedCellProvider) == _cellRef) {
          ref.read(focusedCellProvider.notifier).state = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _node?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    final registry = ref.watch(cellRegistryProvider);
    final node = registry.focusNode(_registryKey);
    if (_node != node) {
      _node?.removeListener(_onFocusChange);
      _node = node;
      node.addListener(_onFocusChange);
    }
    final controller = registry.controller(_registryKey);

    final round = widget.roundIndex < 0 ? null : game.rounds[widget.roundIndex];
    final value = round == null
        ? game.players[widget.playerIndex].initialWeight
        : round.measurements[widget.playerIndex];

    final text = value == 0 ? '' : formatWeight(value);
    if (controller.text != text && !node.hasFocus) {
      controller.text = text;
    }

    final isFocused = ref.watch(focusedCellProvider) == _cellRef;
    final gold = round != null && round.isExact(widget.playerIndex);
    final green =
        round != null && !gold && round.isClosestSoFar(widget.playerIndex);

    final delta = (round == null || value == 0) ? null : value - round.target;
    final deltaLabel = delta == null
        ? null
        : delta == 0
            ? '±0'
            : '${delta > 0 ? '+' : '−'}${formatWeight(delta.abs())}';

    return Container(
      width: weightCellWidth,
      height: weightCellHeight,
      decoration: BoxDecoration(
        color: isFocused ? CustomColors.goldFocus : null,
        border: const Border(left: BorderSide(color: CustomColors.hairline)),
      ),
      child: Stack(
        children: [
          if (gold || green)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: gold
                      ? CustomColors.goldOverlay
                      : CustomColors.greenOverlay,
                ),
              ),
            ),
          Positioned.fill(
            bottom: 12,
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: node,
                enabled: !game.isFinished,
                groupId: weightInputTapGroup,
                keyboardType: TextInputType.none,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  letterSpacing: -0.3,
                  color: CustomColors.textPrimary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration.collapsed(
                  hintText: '–',
                  hintStyle: TextStyle(color: CustomColors.neutralDot),
                ),
                onChanged: (input) {
                  final parsed = double.tryParse(input);
                  _setValue(parsed ?? 0);
                },
                onSubmitted: (_) => handleCellSubmitted(
                  context,
                  ref,
                  isInitialWeight: widget.roundIndex < 0,
                  playerIndex: widget.playerIndex,
                ),
              ),
            ),
          ),
          if (deltaLabel != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 7,
              child: IgnorePointer(
                child: Text(
                  deltaLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: CustomColors.textFaint,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _setValue(double value) {
    final notifier = ref.read(gameProvider.notifier);
    if (widget.roundIndex < 0) {
      notifier.setInitialWeight(widget.playerIndex, value);
    } else {
      notifier.setMeasurement(widget.roundIndex, widget.playerIndex, value);
    }
  }
}
