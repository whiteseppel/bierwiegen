import 'package:flutter/material.dart';

import '../../../../ui/tokens.dart';

enum RoundAction { editTarget, delete }

/// Bottom sheet with the actions available for a single round. [canDelete] is
/// false for rounds that may not be removed (only the last round can).
Future<RoundAction?> showRoundActionsSheet(
  BuildContext context, {
  required int roundIndex,
  required bool canDelete,
}) {
  return showModalBottomSheet<RoundAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) =>
        _RoundActionsSheet(roundIndex: roundIndex, canDelete: canDelete),
  );
}

class _RoundActionsSheet extends StatelessWidget {
  const _RoundActionsSheet({required this.roundIndex, required this.canDelete});

  final int roundIndex;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x26000000),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RUNDE ${roundIndex + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: CustomColors.textMuted,
                ),
              ),
            ),
          ),
          _ActionItem(
            icon: Icons.tune,
            iconBg: CustomColors.goldTint,
            iconFg: CustomColors.goldTextDark,
            label: 'Ziel ändern',
            subtitle: 'Zielgewicht dieser Runde anpassen',
            onTap: () => Navigator.of(context).pop(RoundAction.editTarget),
          ),
          if (canDelete)
            _ActionItem(
              icon: Icons.delete_outline,
              iconBg: const Color(0x14BF4B3A),
              iconFg: CustomColors.danger,
              label: 'Runde löschen',
              subtitle: 'Die letzte Runde entfernen',
              destructive: true,
              onTap: () => Navigator.of(context).pop(RoundAction.delete),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacings.large, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconFg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: destructive
                          ? CustomColors.danger
                          : CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}
