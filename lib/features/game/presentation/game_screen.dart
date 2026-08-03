import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/tokens.dart';
import '../../scale/scale_provider.dart';
import '../../scale/scale_state.dart';
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

    final panelOpen =
        ref.watch(focusedCellProvider) != null && !game.isFinished;
    final showBottomBar =
        !panelOpen && (game.isFinished || game.hasFinishedRound);

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
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildHeaderRow(game.players.length),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRounds(game.players.length,
                                    game.rounds.length),
                                if (!game.isFinished) ...[
                                  const SizedBox(height: 8),
                                  _buildNewRoundButton(),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const ScalePanel(),
                if (showBottomBar) _buildBottomBar(game.isFinished),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
            onTap: connecting
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
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(14)),
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
              if (index != rowIndices.first) const SizedBox(height: 8),
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
                  if (index != rowIndices.first) const SizedBox(height: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        for (int p = 0; p < playerCount; p++)
                          WeightCell(roundIndex: index, playerIndex: p),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewRoundButton() {
    return GestureDetector(
      onTap: () => startNewRound(context, ref),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x2E000000)),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          '+ Neue Runde',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: CustomColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool finished) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: CustomColors.hairline, offset: Offset(0, -1)),
        ],
      ),
      child: finished ? _buildWinnerSection() : _buildEndGameButton(),
    );
  }

  Widget _buildEndGameButton() {
    return GestureDetector(
      onTap: () => Dialogs.finishGameDialog(context, ref),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: CustomColors.secondaryColor),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Spiel beenden',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: CustomColors.greenDark,
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerSection() {
    final winners = ref.watch(winningPlayersProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          winners.length > 1 ? 'Die Gewinner sind' : 'Der Gewinner ist',
          style: const TextStyle(
            fontSize: 13,
            color: CustomColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _winnerNames(winners),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: CustomColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CustomColors.primaryColor,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x73FEAD2E),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Neues Spiel starten',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CustomColors.onPrimaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _winnerNames(List<Player> winners) {
    if (winners.isEmpty) {
      return '—';
    }
    if (winners.length == 1) {
      return winners.first.name;
    }

    final allButLast =
        winners.sublist(0, winners.length - 1).map((p) => p.name).join(', ');
    return '$allButLast und ${winners.last.name}';
  }
}
