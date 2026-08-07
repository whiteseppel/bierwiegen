import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/tokens.dart';
import '../history/recent_games_screen.dart';
import '../scale/scale_provider.dart';
import '../scale/scale_state.dart';
import 'account_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _nameController =
      TextEditingController(text: ref.read(profileNameProvider));
  final ScrollController _scrollController = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 4;
      if (scrolled != _scrolled) {
        setState(() => _scrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(profileNameProvider).trim();
    final displayName = name.isEmpty ? 'Dein Name' : name;
    final initial = (name.isEmpty ? '?' : name[0]).toUpperCase();

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(scrolled: _scrolled),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfile(displayName, initial),
                    const SizedBox(height: 26),
                    const _Divider(),
                    const SizedBox(height: 26),
                    const _GamesSection(),
                    const SizedBox(height: 26),
                    const _Divider(),
                    const SizedBox(height: 26),
                    const _ScaleSection(),
                    const SizedBox(height: 26),
                    const _Divider(),
                    const SizedBox(height: 26),
                    const _StepsSection(),
                    const SizedBox(height: 26),
                    const _ModesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(String displayName, String initial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColors.goldTint,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: CustomColors.goldTextDark,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Profilbild ändern folgt',
                    style: TextStyle(fontSize: 13, color: CustomColors.textFaint),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _SectionLabel('Name'),
        const SizedBox(height: 6),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: const Color(0x1A000000)),
          ),
          child: TextField(
            controller: _nameController,
            onChanged: (value) =>
                ref.read(profileNameProvider.notifier).state = value,
            style: const TextStyle(fontSize: 16, color: CustomColors.textPrimary),
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'Dein Name',
              hintStyle: TextStyle(
                fontSize: 16,
                color: CustomColors.disabledText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'E-Mail und Benutzername kommen später dazu.',
          style: TextStyle(fontSize: 12, color: CustomColors.disabledText),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scrolled});

  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CustomColors.background,
        boxShadow: [
          if (scrolled)
            const BoxShadow(color: Color(0x14000000), offset: Offset(0, 1)),
        ],
      ),
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
          const Text(
            'Konto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: CustomColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GamesSection extends StatelessWidget {
  const _GamesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Spiele'),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(standardBorderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecentGamesScreen()),
            ),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(standardBorderRadius),
                border: Border.all(color: const Color(0x0F000000)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.greenTint,
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 20,
                      color: CustomColors.greenDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Letzte Spiele',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ergebnisse und Statistiken ansehen',
                          style: TextStyle(
                            fontSize: 13,
                            color: CustomColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
        ),
      ],
    );
  }
}

class _ScaleSection extends ConsumerWidget {
  const _ScaleSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(scaleProvider);
    final info = _ScaleCardInfo.of(scale);
    final notifier = ref.read(scaleProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Waage'),
        const SizedBox(height: 12),
        const Text(
          'Bierwiegen läuft mit einer Bluetooth-Küchenwaage. Verbinde sie '
          'einmal, danach übernimmt die App die Gewichte automatisch in die '
          'Tabelle.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: CustomColors.greenDark,
          ),
        ),
        const SizedBox(height: 12),
        _ScaleStatusCard(info: info),
        const SizedBox(height: 12),
        _ScaleActionButton(
          label: info.buttonLabel,
          primary: info.primaryButton,
          onTap: info.busy ? notifier.resetConnection : _actionFor(info, notifier),
        ),
        const SizedBox(height: 8),
        Text(
          info.hint,
          style: const TextStyle(fontSize: 12, color: CustomColors.disabledText),
        ),
      ],
    );
  }

  VoidCallback _actionFor(_ScaleCardInfo info, ScaleNotifier notifier) {
    return info.connected ? notifier.resetConnection : notifier.tryConnect;
  }
}

class _ScaleStatusCard extends StatelessWidget {
  const _ScaleStatusCard({required this.info});

  final _ScaleCardInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(color: info.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: info.iconBg),
            alignment: Alignment.center,
            child: Icon(Icons.bluetooth, size: 20, color: info.iconFg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (info.busy) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation(CustomColors.secondaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScaleActionButton extends StatelessWidget {
  const _ScaleActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? CustomColors.primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      elevation: primary ? 2 : 0,
      shadowColor: CustomColors.goldFocusRing,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: primary
                ? null
                : Border.all(color: CustomColors.secondaryColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color:
                  primary ? CustomColors.onPrimaryDark : CustomColors.greenDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleCardInfo {
  const _ScaleCardInfo({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.buttonLabel,
    required this.primaryButton,
    required this.busy,
    required this.connected,
    required this.border,
    required this.iconBg,
    required this.iconFg,
  });

  final String title;
  final String subtitle;
  final String hint;
  final String buttonLabel;
  final bool primaryButton;
  final bool busy;
  final bool connected;
  final Color border;
  final Color iconBg;
  final Color iconFg;

  factory _ScaleCardInfo.of(ScaleState scale) {
    switch (scale.connectionState) {
      case ScaleConnectionState.scanning:
      case ScaleConnectionState.connecting:
      case ScaleConnectionState.reconnecting:
        return const _ScaleCardInfo(
          title: 'Suche nach Geräten …',
          subtitle: 'Waage einschalten und warten',
          hint: 'Das dauert meistens ein paar Sekunden.',
          buttonLabel: 'Suche abbrechen',
          primaryButton: false,
          busy: true,
          connected: false,
          border: CustomColors.goldFocusRing,
          iconBg: CustomColors.goldTint,
          iconFg: CustomColors.goldTextDark,
        );
      case ScaleConnectionState.connected:
        final weight = scale.liveWeight;
        return _ScaleCardInfo(
          title: 'Bierwaage',
          subtitle: weight == null ? 'Verbunden' : 'Verbunden · $weight g',
          hint: 'Die Waage verbindet sich beim nächsten Spiel automatisch.',
          buttonLabel: 'Verbindung trennen',
          primaryButton: false,
          busy: false,
          connected: true,
          border: CustomColors.secondaryColor,
          iconBg: CustomColors.greenTint,
          iconFg: CustomColors.greenDark,
        );
      case ScaleConnectionState.notFound:
      case ScaleConnectionState.error:
      case ScaleConnectionState.disconnected:
        final failed = scale.connectionState == ScaleConnectionState.notFound ||
            scale.connectionState == ScaleConnectionState.error;
        final subtitle = switch (scale.connectionState) {
          ScaleConnectionState.notFound => 'Keine Waage gefunden',
          ScaleConnectionState.error =>
            scale.errorMessage ?? 'Verbindung fehlgeschlagen',
          _ => 'Bluetooth ist bereit',
        };
        return _ScaleCardInfo(
          title: 'Keine Waage verbunden',
          subtitle: subtitle,
          hint: 'Schalte die Waage ein und halte sie in die Nähe des Telefons.',
          buttonLabel: failed ? 'Erneut verbinden' : 'Waage verbinden',
          primaryButton: true,
          busy: false,
          connected: false,
          border: CustomColors.hairline,
          iconBg: CustomColors.neutralChipBg,
          iconFg: CustomColors.textFaint,
        );
    }
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection();

  static const _steps = [
    ('1', 'Startgewicht wiegen',
        'Jeder stellt sein volles Glas einmal auf die Waage.'),
    ('2', 'Ziel festlegen',
        'Für jede Runde gilt ein Zielgewicht, das unter dem aktuellen liegt.'),
    ('3', 'Trinken und wiegen',
        'Reihum trinken, danach das Glas zurück auf die Waage. Wer am nächsten '
            'am Ziel liegt, gewinnt die Runde.'),
    ('4', 'Spielende',
        'Sobald ein Glas unter 50 g fällt, endet das Spiel und der Endstand '
            'wird ermittelt.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('So wird gespielt'),
        const SizedBox(height: 12),
        for (final (index, step) in _steps.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          _StepRow(number: step.$1, title: step.$2, text: step.$3),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.text,
  });

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: CustomColors.goldTint,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: CustomColors.goldTextDark,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: CustomColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModesSection extends StatelessWidget {
  const _ModesSection();

  static const _modes = [
    ('Wertung', CustomColors.primaryColor, 'Standard',
        'Wer am nächsten am Ziel liegt, holt den Rundensieg. Gezählt werden '
            'die gewonnenen Runden.'),
    ('Wertung', CustomColors.primaryColor, 'Punkte',
        'Punkte nach Platzierung: 3 für den ersten, 2 für den zweiten, 1 für '
            'den dritten Platz. Exakt getroffen zählt 5.'),
    ('Ziele', CustomColors.secondaryColor, 'Manuelle Ziele',
        'Ihr legt das Zielgewicht jeder Runde selbst fest.'),
    ('Ziele', CustomColors.secondaryColor, 'Automatische Ziele',
        'Das nächste Ziel wird ausgelost: 30 bis 80 g unter dem aktuellen '
            'Ziel.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Spielmodi'),
        const SizedBox(height: 12),
        for (final (index, mode) in _modes.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          _ModeCard(
            group: mode.$1,
            dot: mode.$2,
            title: mode.$3,
            text: mode.$4,
          ),
        ],
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.group,
    required this.dot,
    required this.title,
    required this.text,
  });

  final String group;
  final Color dot;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(color: const Color(0x0F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dot,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
              ),
              Text(
                group,
                style: const TextStyle(
                  fontSize: 12,
                  color: CustomColors.disabledText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: CustomColors.textMuted,
            ),
          ),
        ],
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      child: ColoredBox(color: Color(0x14000000)),
    );
  }
}
