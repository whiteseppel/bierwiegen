import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/tokens.dart';
import '../game/domain/game_config.dart';
import 'game_history_provider.dart';
import 'game_summary.dart';

const _months = [
  'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
];

const _weekdays = [
  'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', //
  'Freitag', 'Samstag', 'Sonntag',
];

String _two(int value) => value.toString().padLeft(2, '0');

String _time(DateTime dt) => '${_two(dt.hour)}:${_two(dt.minute)}';

String _durationLabel(Duration d) {
  final minutes = d.inMinutes;
  if (minutes < 60) {
    return '$minutes Min';
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours Std' : '$hours Std $rest Min';
}

String _modeLabel(GameMode mode) => mode == GameMode.points ? 'Punkte' : 'Standard';

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
              child: games.isEmpty
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

  final List<GameSummary> games;

  @override
  Widget build(BuildContext context) {
    final newest = games.first.finishedAt;
    final count = games.length;
    final intro = '$count ${count == 1 ? 'Spiel' : 'Spiele'} gespielt · '
        'zuletzt am ${newest.day}. ${_months[newest.month - 1]}';

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      itemCount: games.length + 1,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? 14 : 10),
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

  final GameSummary game;

  @override
  Widget build(BuildContext context) {
    final ranking = game.ranking;
    final podium = ranking.take(3).toList();
    final rest = game.playerCount - podium.length;
    final winnerLine =
        (game.winners.length > 1 ? 'Unentschieden: ' : '') + game.winnerNames;
    final finished = game.finishedAt;
    final meta = '${_time(finished)} Uhr · ${game.playerCount} Spieler · '
        '${game.roundsPlayed} Runden · ${_modeLabel(game.mode)}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
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
                    const SizedBox(height: 6),
                    _Podium(podium: podium, rest: rest),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '›',
                style: TextStyle(fontSize: 18, color: CustomColors.disabledText),
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
            _months[date.month - 1].toUpperCase(),
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
          if (i > 0) const SizedBox(width: 8),
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
                      color: i == 0
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
                    color: i == 0
                        ? CustomColors.rankBadgeTop
                        : CustomColors.disabledText,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (rest > 0) ...[
          const SizedBox(width: 8),
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

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.game});

  final GameSummary game;

  @override
  Widget build(BuildContext context) {
    final finished = game.finishedAt;
    final title = '${finished.day}. ${_months[finished.month - 1]} '
        '${finished.year}';
    final ranking = game.ranking;
    final winnerScore = game.winners.isEmpty ? 0 : game.winners.first.score;

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: title, titleWeight: FontWeight.w500),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EndstandCard(game: game, winnerScore: winnerScore),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            label: 'Datum',
                            value: '${_weekdays[finished.weekday - 1]}, '
                                '${finished.day}. ${_months[finished.month - 1]}',
                            sub: '${_time(finished)} Uhr',
                            subMono: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InfoTile(
                            label: 'Modus',
                            value: _modeLabel(game.mode),
                            sub: game.targetMode == TargetMode.auto
                                ? 'Automatische Ziele'
                                : 'Manuelle Ziele',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < ranking.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _RankingRow(entry: ranking[i]),
                    ],
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${game.playerCount} Spieler · '
                            '${game.roundsPlayed} Runden',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CustomColors.textFaint,
                            ),
                          ),
                          Text(
                            _durationLabel(game.duration),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndstandCard extends StatelessWidget {
  const _EndstandCard({required this.game, required this.winnerScore});

  final GameSummary game;
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
            game.winners.length > 1 ? 'Die Gewinner sind' : 'Der Gewinner ist',
            style: const TextStyle(fontSize: 14, color: CustomColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            game.winnerNames,
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
            '${game.roundsPlayed} gespielte Runden · '
            '${game.scoreLabel(winnerScore)}',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: top ? CustomColors.rankBadgeTop : CustomColors.disabledText,
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
            SizedBox(height: 6),
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
  const _TopBar({required this.title, this.titleWeight = FontWeight.w700});

  final String title;
  final FontWeight titleWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              style: TextStyle(
                fontSize: titleWeight == FontWeight.w700 ? 20 : 17,
                fontWeight: titleWeight,
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
