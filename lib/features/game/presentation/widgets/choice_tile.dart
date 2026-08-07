import 'package:flutter/material.dart';

import '../../../../ui/tokens.dart';

/// Radio-style option row used in the option/settings sheets: a filled dot when
/// [selected], a title and a description.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CustomColors.goldTint : CustomColors.tileBg,
      borderRadius: BorderRadius.circular(standardBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(standardBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(standardBorderRadius),
            border: Border.all(
              color:
                  selected ? CustomColors.goldFocusRing : CustomColors.hairline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? CustomColors.primaryColor
                        : CustomColors.neutralDot,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? CustomColors.primaryColor
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CustomColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
