import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/tokens.dart';
import '../../history/game_result_view.dart';
import '../../scale/scale_provider.dart';
import '../../scale/scale_state.dart';
import '../domain/game.dart';
import '../domain/game_config.dart';
import '../domain/player.dart';
import '../state/game_providers.dart';
import '../state/game_ui_providers.dart';
import 'dialogs.dart';
import 'submit_flow.dart';
import 'widgets/confetti_widget.dart';
import 'widgets/options_sheet.dart';
import 'widgets/player_header_cell.dart';
import 'widgets/round_label_cell.dart';
import 'widgets/scale_chip.dart';
import 'widgets/scale_panel.dart';
import 'widgets/weight_cell.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _headerScroll = ScrollController();
  final _bodyScroll = ScrollController();
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _headerScroll.addListener(() => _syncScroll(_headerScroll, _bodyScroll));
    _bodyScroll.addListener(() => _syncScroll(_bodyScroll, _headerScroll));
  }

  void _syncScroll(ScrollController from, ScrollController to) {
    if (_syncingScroll || !to.hasClients || to.offset == from.offset) {
      return;
    }
    _syncingScroll = true;
    to.jumpTo(from.offset);
    _syncingScroll = false;
  }

  @override
  void dispose() {
    _headerScroll.dispose();
    _bodyScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: CustomColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacings.small),
                    child: Column(
                      children: [
                        _buildHeaderRow(game.players.length),
                        const SizedBox(height: Spacings.small),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRounds(
                                  game.players.length,
                                  game.rounds.length,
                                ),
                                const SizedBox(height: 10),
                                if (game.isFinished)
                                  _buildEndstandButton()
                                else
                                  _buildPlayFooter(game),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const ScalePanel(),
              ],
            ),
          ),
        ),
        if (ref.watch(resultOpenProvider))
          Positioned.fill(
            child: GameResultView(
              game: game,
              variant: GameResultVariant.finish,
            ),
          ),
        WinnerConfetti(key: WinnerConfetti.globalKey),
      ],
    );
  }

  Widget _buildTopBar() {
    final scale = ref.watch(scaleProvider);
    final paused = ref.watch(scalePausedProvider);
    final chip = ScaleChipData.of(scale, paused: paused);
    final connecting = switch (scale.connectionState) {
      ScaleConnectionState.scanning ||
      ScaleConnectionState.connecting ||
      ScaleConnectionState.reconnecting => true,
      _ => false,
    };

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: Spacings.small),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: CustomColors.hairline, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'Bierwiegen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: CustomColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          ScaleChip(
            data: chip,
            onTap:
                connecting
                    ? null
                    : () {
                      if (chip.connected) {
                        ref.read(scalePausedProvider.notifier).state = !paused;
                      } else {
                        ref.read(scaleProvider.notifier).tryConnect();
                      }
                    },
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => showOptionsSheet(context),
              icon: const Icon(
                Icons.more_vert,
                size: 22,
                color: CustomColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(int playerCount) {
    return SizedBox(
      height: playerHeaderHeight,
      child: Row(
        children: [
          Container(
            width: roundLabelWidth,
            decoration: const BoxDecoration(
              color: CustomColors.secondaryColor,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(13)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(3, 0),
                  blurRadius: 6,
                  spreadRadius: -4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Ziel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _headerScroll,
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < playerCount; i++)
                      PlayerHeaderCell(playerIndex: i),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRounds(int playerCount, int roundCount) {
    // Row -1 holds the initial weights; the label column stays fixed while
    // the cells scroll horizontally in sync with the header.
    final rowIndices = [-1, for (int i = 0; i < roundCount; i++) i];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            for (final index in rowIndices) ...[
              if (index != rowIndices.first)
                const SizedBox(height: Spacings.small),
              RoundLabelCell(roundIndex: index),
            ],
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _bodyScroll,
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final index in rowIndices) ...[
                  if (index != rowIndices.first)
                    const SizedBox(height: Spacings.small),
                  _buildBodyRow(index, playerCount),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyRow(int index, int playerCount) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
      ),
      child: Row(
        children: [
          for (int p = 0; p < playerCount; p++)
            WeightCell(roundIndex: index, playerIndex: p),
        ],
      ),
    );
  }

  Widget _buildNewRoundButton(String label) {
    return GestureDetector(
      onTap: () => startNewRound(context, ref),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x2E000000)),
          borderRadius: BorderRadius.circular(standardBorderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayFooter(Game game) {
    final ready = game.canStartNewRound;
    final finishers = game.finishers;
    final auto = game.config.targetMode == TargetMode.auto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ready)
          if (finishers.isEmpty)
            _buildNewRoundButton(
              auto ? '+ Neue Runde auslosen' : '+ Neue Runde',
            )
          else
            _buildFinishButton(),
        if (ready) const SizedBox(height: 10),
        Text(
          _finishHint(game, ready, finishers),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: CustomColors.textFaint),
        ),
      ],
    );
  }

  String _finishHint(Game game, bool ready, List<Player> finishers) {
    if (!ready) {
      return game.allPlayersWeighedIn
          ? 'Aktuelle Runde fertig wiegen.'
          : 'Erst die Startgewichte aller Spieler eintragen.';
    }
    if (finishers.isNotEmpty) {
      final names = finishers.map((p) => p.name).join(' und ');
      final verb = finishers.length == 1 ? 'ist' : 'sind';
      return '$names $verb unter '
          '${Game.finishThreshold.toInt()} g – das Spiel ist zu Ende.';
    }
    return 'Spiel endet, sobald jemand unter '
        '${Game.finishThreshold.toInt()} g kommt.';
  }

  Widget _buildFinishButton() {
    return GestureDetector(
      onTap: () => Dialogs.finishGameDialog(context, ref),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: CustomColors.primaryColor,
          borderRadius: BorderRadius.circular(standardBorderRadius),
          boxShadow: _amberShadow,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Spiel beenden',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: CustomColors.onPrimaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEndstandButton() {
    return GestureDetector(
      onTap: _openResult,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: CustomColors.primaryColor,
          borderRadius: BorderRadius.circular(standardBorderRadius),
          boxShadow: _amberShadow,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Ergebnis ansehen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: CustomColors.onPrimaryDark,
          ),
        ),
      ),
    );
  }

  void _openResult() {
    ref.read(resultOpenProvider.notifier).state = true;
    WinnerConfetti.globalKey.currentState?.playConfetti();
  }

  static const List<BoxShadow> _amberShadow = [
    BoxShadow(color: Color(0x73FEAD2E), offset: Offset(0, 2), blurRadius: 6),
  ];
}
