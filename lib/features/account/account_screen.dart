import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/tokens.dart';
import 'account_providers.dart';
import 'account_ui.dart';
import 'profile_color.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: ref.read(profileNameProvider),
  );
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

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Diese Funktion kommt bald.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(profileNameProvider).trim();
    final color = ref.watch(profileColorProvider);
    final displayName = name.isEmpty ? 'Dein Name' : name;
    final initial = (name.isEmpty ? '?' : name[0]).toUpperCase();

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AccountTopBar(title: 'Konto', scrolled: _scrolled),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      displayName: displayName,
                      initial: initial,
                      color: color,
                    ),
                    const SizedBox(height: Spacings.large),
                    _NameSection(controller: _nameController),
                    const SizedBox(height: Spacings.large),
                    const _ColorSection(),
                    const SizedBox(height: Spacings.large),
                    const HairlineDivider(),
                    const SizedBox(height: Spacings.large),
                    _SignInSection(onTap: _comingSoon),
                    const SizedBox(height: Spacings.large),
                    const HairlineDivider(),
                    const SizedBox(height: Spacings.large),
                    _SignOutButton(onTap: _comingSoon),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.initial,
    required this.color,
  });

  final String displayName;
  final String initial;
  final ProfileColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.background,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: color.foreground,
            ),
          ),
        ),
        const SizedBox(width: Spacings.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                'Nur auf diesem Gerät',
                style: TextStyle(fontSize: 13, color: CustomColors.textFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NameSection extends ConsumerWidget {
  const _NameSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Name'),
        const SizedBox(height: Spacings.small),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: Spacings.medium),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: const Color(0x1A000000)),
          ),
          child: TextField(
            controller: controller,
            onChanged:
                (value) => ref.read(profileNameProvider.notifier).setName(value),
            style: const TextStyle(
              fontSize: 16,
              color: CustomColors.textPrimary,
            ),
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
        const SizedBox(height: Spacings.small),
        const Text(
          'So sehen dich Mitspieler in der Tabelle.',
          style: TextStyle(fontSize: 12, color: CustomColors.disabledText),
        ),
      ],
    );
  }
}

class _ColorSection extends ConsumerWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(profileColorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Farbe'),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final color in ProfileColor.values) ...[
              if (color != ProfileColor.values.first)
                const SizedBox(width: 12),
              _Swatch(
                color: color,
                selected: color == selected,
                onTap:
                    () =>
                        ref.read(profileColorProvider.notifier).setColor(color),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Deine Farbe im Profil und in der Spielübersicht.',
          style: TextStyle(fontSize: 12, color: CustomColors.disabledText),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ProfileColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.background,
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: color.background,
                      blurRadius: 0,
                      spreadRadius: 5,
                    ),
                    const BoxShadow(
                      color: CustomColors.background,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child:
            selected
                ? Icon(Icons.check, size: 20, color: color.foreground)
                : null,
      ),
    );
  }
}

class _SignInSection extends StatelessWidget {
  const _SignInSection({required this.onTap});

  final VoidCallback onTap;

  static const _providers = [
    ('Mit Google anmelden', 'G', Color(0xFFF1F0EC), Color(0xFF4A4843)),
    ('Mit Apple anmelden', 'A', Color(0xFF1C1B18), Colors.white),
    ('Mit E-Mail anmelden', '@', Color(0xFFEDF1EE), Color(0xFF3F5348)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Anmelden'),
        const SizedBox(height: 12),
        const Text(
          'Melde dich an, um deine Spiele auf mehreren Geräten zu behalten. Bis '
          'dahin bleibt alles nur auf diesem Telefon.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF4A4843),
          ),
        ),
        const SizedBox(height: 12),
        for (final (index, provider) in _providers.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _ProviderRow(
            label: provider.$1,
            badge: provider.$2,
            badgeBg: provider.$3,
            badgeFg: provider.$4,
            onTap: onTap,
          ),
        ],
      ],
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.label,
    required this.badge,
    required this.badgeBg,
    required this.badgeFg,
    required this.onTap,
  });

  final String label;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(standardBorderRadius),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: Spacings.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: const Color(0x0F000000)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeBg,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: badgeFg,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  static const Color _danger = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(standardBorderRadius),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(color: const Color(0x4DC0392B)),
          ),
          child: const Text(
            'Alle Daten auf diesem Gerät löschen',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _danger,
            ),
          ),
        ),
      ),
    );
  }
}
