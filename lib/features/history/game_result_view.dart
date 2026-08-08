import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/tokens.dart';
import '../game/domain/game.dart';
import '../game/state/game_ui_providers.dart';
import 'date_format_de.dart';
import 'game_result_view_model.dart';

/// Where a [GameResultView] is shown from. The content is identical; only the
/// surrounding chrome differs.
enum GameResultVariant {
  /// Reached from the game history: app bar with the game's date, no actions.
  summary,

  /// Shown right after a game ends: no app bar, action buttons at the bottom
  /// (the game screen adds the confetti on top).
  finish,
}

/// Final standings for a single game, rendered from a [GameResultViewModel].
/// Used both for the post-game screen and the history detail — see
/// [GameResultVariant].
class GameResultView extends ConsumerWidget {
  const GameResultView({super.key, required this.game, required this.variant});

  final Game game;
  final GameResultVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = GameResultViewModel(game);
    switch (variant) {
      case GameResultVariant.summary:
        final finished = model.finishedAt;
        final title =
            '${finished.day}. ${monthShort(finished.month)} '
            '${finished.year}';
        return Scaffold(
          backgroundColor: CustomColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(title: title),
                Expanded(child: _content(model, bottomPadding: 24)),
              ],
            ),
          ),
        );
      case GameResultVariant.finish:
        return Material(
          color: CustomColors.background,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(child: _content(model, bottomPadding: 8)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: _FinishActions(),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _content(GameResultViewModel model, {required double bottomPadding}) {
    final ranking = model.ranking;
    final winnerScore = model.winnerScore;
    final finished = model.finishedAt;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EndstandCard(model: model, winnerScore: winnerScore),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Datum',
                  value:
                      '${weekdayName(finished.weekday)}, '
                      '${finished.day}. ${monthShort(finished.month)}',
                  sub: '${clock(finished)} Uhr',
                  subMono: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'Modus',
                  value: model.modeLabel,
                  sub: model.targetLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < ranking.length; i++) ...[
            if (i > 0) const SizedBox(height: Spacings.small),
            _RankingRow(entry: ranking[i]),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${model.playerCount} Spieler · '
                  '${model.roundsPlayed} Runden',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomColors.textFaint,
                  ),
                ),
                Text(
                  durationLabel(model.duration),
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: CustomColors.textFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _PrimaryButton(
          label: 'Neues Spiel starten',
          onTap: () {
            ref.read(resultOpenProvider.notifier).state = false;
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
        _OutlineButton(
          label: 'Tabelle ansehen',
          onTap: () => ref.read(resultOpenProvider.notifier).state = false,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: CustomColors.primaryColor,
          borderRadius: BorderRadius.circular(standardBorderRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73FEAD2E),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CustomColors.onPrimaryDark,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: CustomColors.secondaryColor),
          borderRadius: BorderRadius.circular(standardBorderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: CustomColors.greenDark,
          ),
        ),
      ),
    );
  }
}

class _EndstandCard extends StatelessWidget {
  const _EndstandCard({required this.model, required this.winnerScore});

  final GameResultViewModel model;
  final int winnerScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(color: CustomColors.hairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ENDSTAND',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: CustomColors.textFaint,
            ),
          ),
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.fromLTRB(0, 14, 0, 16),
            decoration: BoxDecoration(
              color: CustomColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            model.winners.length > 1 ? 'Die Gewinner sind' : 'Der Gewinner ist',
            style: const TextStyle(fontSize: 14, color: CustomColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            model.winnerNames,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: CustomColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${model.roundsPlayed} gespielte Runden · '
            '${model.scoreLabel(winnerScore)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: CustomColors.textFaint),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.sub,
    this.subMono = false,
  });

  final String label;
  final String value;
  final String sub;
  final bool subMono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(color: const Color(0x0F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.6,
              color: CustomColors.textFaint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: CustomColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 13,
              fontFamily: subMono ? 'monospace' : null,
              color: CustomColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry});

  final RankedResult entry;

  @override
  Widget build(BuildContext context) {
    final top = entry.rank == 1;
    final exact = entry.result.exactHits;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: Spacings.medium),
      decoration: BoxDecoration(
        color: top ? CustomColors.goldRowBg : Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(
          color: top ? CustomColors.goldFocusRing : CustomColors.hairline,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${entry.rank}.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color:
                    top ? CustomColors.rankBadgeTop : CustomColors.disabledText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              entry.result.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CustomColors.textPrimary,
              ),
            ),
          ),
          if (exact > 0) ...[
            Text(
              '$exact× exakt',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: CustomColors.textFaint,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            '${entry.result.score}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: CustomColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: Spacings.small),
      color: CustomColors.background,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                size: 22,
                color: CustomColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                color: CustomColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
