import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/tokens.dart';
import '../game/domain/game.dart';
import 'date_format_de.dart';
import 'game_history_provider.dart';
import 'game_result_view.dart';
import 'game_result_view_model.dart';

class RecentGamesScreen extends ConsumerWidget {
  const RecentGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gameHistoryProvider);

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(title: 'Letzte Spiele'),
            Expanded(
              child:
                  games.isEmpty
                      ? const _EmptyState()
                      : _GamesList(games: games),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  const _GamesList({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final newest = GameResultViewModel(games.first).finishedAt;
    final count = games.length;
    final intro =
        '$count ${count == 1 ? 'Spiel' : 'Spiele'} gespielt · '
        'zuletzt am ${newest.day}. ${monthShort(newest.month)}';

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      itemCount: games.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 14 : 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            intro,
            style: const TextStyle(fontSize: 13, color: CustomColors.textFaint),
          );
        }
        return _GameCard(game: games[index - 1]);
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final model = GameResultViewModel(game);
    final podium = model.ranking.take(3).toList();
    final rest = model.playerCount - podium.length;
    final winnerLine =
        (model.winners.length > 1 ? 'Unentschieden: ' : '') + model.winnerNames;
    final finished = model.finishedAt;
    final meta =
        '${clock(finished)} Uhr · ${model.playerCount} Spieler · '
        '${model.roundsPlayed} Runden · ${model.modeLabel}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => GameResultView(
                      game: game,
                      variant: GameResultVariant.summary,
                    ),
              ),
            ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x0F000000)),
          ),
          child: Row(
            children: [
              _DateBadge(date: finished),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winnerLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CustomColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: Spacings.small),
                    _Podium(podium: podium, rest: rest),
                  ],
                ),
              ),
              const SizedBox(width: Spacings.small),
              const Text(
                '›',
                style: TextStyle(
                  fontSize: 18,
                  color: CustomColors.disabledText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CustomColors.goldTint,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              height: 1.05,
              color: CustomColors.goldTextDark,
            ),
          ),
          Text(
            monthShort(date.month).toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              height: 1.05,
              color: CustomColors.goldTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.podium, required this.rest});

  final List<RankedResult> podium;
  final int rest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < podium.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacings.small),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    podium[i].result.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w400,
                      color:
                          i == 0
                              ? CustomColors.textPrimary
                              : CustomColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${podium[i].result.score}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color:
                        i == 0
                            ? CustomColors.rankBadgeTop
                            : CustomColors.disabledText,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (rest > 0) ...[
          const SizedBox(width: Spacings.small),
          Text(
            '+$rest',
            style: const TextStyle(
              fontSize: 12,
              color: CustomColors.disabledText,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 40, color: CustomColors.disabledText),
            SizedBox(height: 12),
            Text(
              'Noch keine Spiele gespielt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CustomColors.textPrimary,
              ),
            ),
            SizedBox(height: Spacings.small),
            Text(
              'Beendete Spiele erscheinen hier mit Ergebnis und Statistik.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: CustomColors.textMuted),
            ),
          ],
        ),
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
