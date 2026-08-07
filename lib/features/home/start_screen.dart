import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../ui/tokens.dart';
import '../account/account_screen.dart';
import '../game/domain/game_config.dart';
import '../game/presentation/game_screen.dart';
import '../game/presentation/widgets/choice_tile.dart';
import '../game/state/game_providers.dart';
import '../info/introduction_screen.dart';
import '../settings/options_screen.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final List<TextEditingController> _playerControllers = [
    TextEditingController(),
  ];
  final ScrollController _scrollController = ScrollController();
  GameMode _mode = GameMode.standard;
  TargetMode _targetMode = TargetMode.manual;
  double _titleOpacity = 0;

  @override
  void initState() {
    WakelockPlus.enable();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    const start = 50.0;
    const end = 140.0;
    final value =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    if ((value - _titleOpacity).abs() > 0.01) {
      setState(() => _titleOpacity = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canStart = _playerControllers.any((c) => c.text.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(titleOpacity: _titleOpacity, onMenu: _openMenu),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 42,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _TitleBlock(),
                            const SizedBox(height: 24),
                            const Text(
                              'Gib die Namen der Mitspieler ein und lege '
                              'direkt los!',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: CustomColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPlayerFields(),
                            const SizedBox(height: 20),
                            const Spacer(),
                            _buildActions(canStart),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in _playerControllers.asMap().entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlayerField(
              number: entry.key + 1,
              controller: entry.value,
              onChanged: (_) => setState(_syncFields),
              onClear: () => _clearField(entry.key),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(bool canStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OptionsRow(
          summary: (_mode == GameMode.points ? 'Punkte' : 'Standard') +
              (_targetMode == TargetMode.auto ? ' · Auto-Ziele' : ''),
          onTap: _openOptions,
        ),
        const SizedBox(height: 12),
        _StartButton(enabled: canStart, onPressed: canStart ? _startGame : null),
        const SizedBox(height: 12),
        const _OrDivider(),
        const SizedBox(height: 12),
        _JoinButton(onPressed: _comingSoon),
      ],
    );
  }

  void _syncFields() {
    while (_playerControllers.length > 1 &&
        _playerControllers[_playerControllers.length - 1].text.isEmpty &&
        _playerControllers[_playerControllers.length - 2].text.isEmpty) {
      _playerControllers.removeLast().dispose();
    }
    if (_playerControllers.last.text.isNotEmpty) {
      _playerControllers.add(TextEditingController());
    }
  }

  void _clearField(int index) {
    setState(() {
      _playerControllers.removeAt(index).dispose();
      if (_playerControllers.isEmpty || _playerControllers.last.text.isNotEmpty) {
        _playerControllers.add(TextEditingController());
      }
    });
  }

  Future<void> _openOptions() async {
    final result = await showStartOptionsSheet(context, _mode, _targetMode);
    if (result != null) {
      setState(() {
        _mode = result.mode;
        _targetMode = result.targetMode;
      });
    }
  }

  Future<void> _openMenu() async {
    final action = await showStartMenuSheet(context);
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case _MenuAction.account:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AccountScreen()),
        );
      case _MenuAction.settings:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OptionsScreen()),
        );
      case _MenuAction.rules:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const IntroductionScreen()),
        );
      case _MenuAction.history:
        _comingSoon();
    }
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Bald verfügbar')));
  }

  void _startGame() {
    final names = [
      for (final controller in _playerControllers)
        if (controller.text.trim().isNotEmpty) controller.text.trim(),
    ];
    if (names.isEmpty) {
      return;
    }

    final notifier = ref.read(gameProvider.notifier);
    notifier.startGame(names);
    notifier.setMode(_mode);
    notifier.setTargetMode(_targetMode);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.titleOpacity, required this.onMenu});

  final double titleOpacity;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Color.lerp(CustomColors.background, Colors.white, titleOpacity),
        boxShadow: [
          BoxShadow(
            color: CustomColors.hairline.withValues(alpha: 0.06 * titleOpacity),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Opacity(
            opacity: titleOpacity,
            child: const Text(
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
          Material(
            color: CustomColors.goldTint,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onMenu,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.person_outline,
                  size: 24,
                  color: CustomColors.goldTextDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEIN PARTY-GAME',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.4,
            color: CustomColors.textFaint,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Bier\nwiegen',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 0.92,
            color: CustomColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 64,
          height: 6,
          decoration: BoxDecoration(
            color: CustomColors.primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class _PlayerField extends StatelessWidget {
  const _PlayerField({
    required this.number,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final int number;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        border: Border.all(
          color: filled ? const Color(0x1A000000) : CustomColors.hairline,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CustomColors.disabledText,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 16,
                color: CustomColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Spieler $number',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: CustomColors.disabledText,
                ),
              ),
            ),
          ),
          if (filled)
            IconButton(
              focusNode: FocusNode(skipTraversal: true),
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 20),
              color: CustomColors.textFaint,
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({required this.summary, required this.onTap});

  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.tileBg,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: CustomColors.hairline),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 20, color: CustomColors.textMuted),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Spieloptionen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
              ),
              Text(
                summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: CustomColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: CustomColors.disabledText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? CustomColors.primaryColor : CustomColors.trackBg,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      elevation: enabled ? 2 : 0,
      shadowColor: CustomColors.goldFocusRing,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Text(
            'Spiel starten',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? CustomColors.onPrimaryDark
                  : CustomColors.disabledText,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0x24000000), height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'oder',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: CustomColors.textFaint,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0x24000000), height: 1)),
      ],
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: CustomColors.secondaryColor),
          ),
          child: const Text(
            'Spiel beitreten',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CustomColors.greenDark,
            ),
          ),
        ),
      ),
    );
  }
}

typedef StartOptions = ({GameMode mode, TargetMode targetMode});

Future<StartOptions?> showStartOptionsSheet(
  BuildContext context,
  GameMode currentMode,
  TargetMode currentTargetMode,
) {
  return showModalBottomSheet<StartOptions>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _StartOptionsSheet(
      currentMode: currentMode,
      currentTargetMode: currentTargetMode,
    ),
  );
}

class _StartOptionsSheet extends StatefulWidget {
  const _StartOptionsSheet({
    required this.currentMode,
    required this.currentTargetMode,
  });

  final GameMode currentMode;
  final TargetMode currentTargetMode;

  @override
  State<_StartOptionsSheet> createState() => _StartOptionsSheetState();
}

class _StartOptionsSheetState extends State<_StartOptionsSheet> {
  late GameMode _mode = widget.currentMode;
  late TargetMode _targetMode = widget.currentTargetMode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 16),
            const Text(
              'Spieloptionen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Spielmodus'),
            const SizedBox(height: 8),
            ChoiceTile(
              label: 'Standard',
              description: 'Wer am nächsten dran ist, gewinnt die Runde.',
              selected: _mode == GameMode.standard,
              onTap: () => setState(() => _mode = GameMode.standard),
            ),
            const SizedBox(height: 8),
            ChoiceTile(
              label: 'Punkte',
              description:
                  'Punkte nach Platzierung, exakt getroffen zählt doppelt.',
              selected: _mode == GameMode.points,
              onTap: () => setState(() => _mode = GameMode.points),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Zielvorgabe'),
            const SizedBox(height: 8),
            ChoiceTile(
              label: 'Manuelle Ziele',
              description: 'Ihr legt das Zielgewicht jeder Runde selbst fest.',
              selected: _targetMode == TargetMode.manual,
              onTap: () => setState(() => _targetMode = TargetMode.manual),
            ),
            const SizedBox(height: 8),
            ChoiceTile(
              label: 'Automatische Ziele',
              description:
                  'Das nächste Ziel wird ausgelost: 30 – 80 g unter dem '
                  'aktuellen.',
              selected: _targetMode == TargetMode.auto,
              onTap: () => setState(() => _targetMode = TargetMode.auto),
            ),
            const SizedBox(height: 22),
            Material(
              color: CustomColors.primaryColor,
              borderRadius: BorderRadius.circular(standardBorderRadius),
              elevation: 2,
              shadowColor: CustomColors.goldFocusRing,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(
                  (mode: _mode, targetMode: _targetMode),
                ),
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
            ),
          ],
        ),
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

enum _MenuAction { account, settings, rules, history }

Future<_MenuAction?> showStartMenuSheet(BuildContext context) {
  return showModalBottomSheet<_MenuAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _MenuSheet(),
  );
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 6, 24, 10),
            child: _SectionLabel('Menü'),
          ),
          _MenuItem(
            dot: CustomColors.goldTextDark,
            label: 'Konto & Verbindung',
            note: 'Konto',
            onTap: () => Navigator.of(context).pop(_MenuAction.account),
          ),
          _MenuItem(
            dot: CustomColors.secondaryColor,
            label: 'Einstellungen',
            note: 'Waage',
            onTap: () => Navigator.of(context).pop(_MenuAction.settings),
          ),
          _MenuItem(
            dot: CustomColors.primaryColor,
            label: 'Was ist Bierwiegen?',
            note: 'Regeln',
            onTap: () => Navigator.of(context).pop(_MenuAction.rules),
          ),
          _MenuItem(
            dot: CustomColors.neutralDot,
            label: 'Spielverlauf',
            note: 'bald',
            onTap: () => Navigator.of(context).pop(_MenuAction.history),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.dot,
    required this.label,
    required this.note,
    required this.onTap,
  });

  final Color dot;
  final String label;
  final String note;
  final VoidCallback onTap;

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
              note,
              style: const TextStyle(
                fontSize: 12,
                color: CustomColors.disabledText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
