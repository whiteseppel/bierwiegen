import 'package:flutter/material.dart';

import '../../ui/tokens.dart';

/// The top bar shared by the settings and account screens: a back button that
/// pops, a title, and a shadow that appears once [scrolled].
class AccountTopBar extends StatelessWidget {
  const AccountTopBar({super.key, required this.title, this.scrolled = false});

  final String title;
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: Spacings.small),
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
          Text(
            title,
            style: const TextStyle(
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

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

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

class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      child: ColoredBox(color: Color(0x14000000)),
    );
  }
}
