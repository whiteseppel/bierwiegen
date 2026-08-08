import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_providers.dart';
import '../../state/game_ui_providers.dart';
import '../dialogs.dart';
import 'weight_cell.dart';

/// Affordance used to delete the last round. Both are implemented so the
/// interaction can be compared in the app; flip this to try the other.
enum RoundDeleteStyle {
  /// A trash-can cell that extends the last round's row past the last player,
  /// reached by scrolling the table horizontally.
  trashCell,

  /// The last round's label cell drags aside to reveal a delete button, and
  /// teases itself with a small peek when the round first appears.
  swipeReveal,
}

const RoundDeleteStyle roundDeleteStyle = RoundDeleteStyle.trashCell;

const Color _deleteRed = Color(0xFFC0392B);
const Color _deleteTint = Color(0xFFFCEDEA);

/// Removes the last round, confirming first when it already holds weights so an
/// accidental tap can't wipe entered data.
Future<void> confirmAndRemoveLastRound(
  BuildContext context,
  WidgetRef ref,
) async {
  final game = ref.read(gameProvider);
  if (game == null || game.rounds.isEmpty) {
    return;
  }

  final hasData = game.rounds.last.measurements.any((m) => m != 0);
  if (hasData) {
    final confirmed = await Dialogs.confirmDialog(
      context,
      title: 'Runde löschen?',
      body: 'Die letzte Runde und alle eingetragenen Gewichte werden entfernt.',
      confirmLabel: 'Löschen',
    );
    if (!confirmed) {
      return;
    }
  }

  FocusManager.instance.primaryFocus?.unfocus();
  ref.read(focusedCellProvider.notifier).state = null;
  ref.read(gameProvider.notifier).removeLastRound();
}

/// Option 1: a delete cell appended after the last player on the last round's
/// row, so the row visibly extends into the horizontal scroll area.
class DeleteRoundCell extends ConsumerWidget {
  const DeleteRoundCell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => confirmAndRemoveLastRound(context, ref),
      child: Container(
        width: weightCellWidth,
        height: weightCellHeight,
        decoration: BoxDecoration(
          color: _deleteTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1AC0392B)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, size: 24, color: _deleteRed),
            SizedBox(height: 2),
            Text(
              'Runde',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: _deleteRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Option 2: drags [child] aside to reveal a delete button, snapping open or
/// shut on release. On first build it briefly peeks the button so the hidden
/// action is discoverable.
class SwipeToRevealDelete extends StatefulWidget {
  const SwipeToRevealDelete({
    super.key,
    required this.width,
    required this.height,
    required this.revealWidth,
    required this.onDelete,
    required this.child,
  });

  final double width;
  final double height;
  final double revealWidth;
  final Future<void> Function() onDelete;
  final Widget child;

  @override
  State<SwipeToRevealDelete> createState() => _SwipeToRevealDeleteState();
}

class _SwipeToRevealDeleteState extends State<SwipeToRevealDelete>
    with SingleTickerProviderStateMixin {
  // 0 = closed, 1 = fully revealed.
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  bool get _open => _slide.value > 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playTease());
  }

  Future<void> _playTease() async {
    if (!mounted) {
      return;
    }
    final peek = (10 / widget.revealWidth).clamp(0.0, 1.0);
    await _slide.animateTo(
      peek,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOut,
    );
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    await _slide.animateBack(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeIn,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _slide.value =
        (_slide.value - details.primaryDelta! / widget.revealWidth).clamp(
          0.0,
          1.0,
        );
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final target =
        velocity < -200
            ? 1.0
            : velocity > 200
            ? 0.0
            : (_slide.value > 0.5 ? 1.0 : 0.0);
    _settle(target);
  }

  void _settle(double target) {
    _slide
        .animateTo(
          target,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTap: _open ? () => _settle(0) : null,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    color: _deleteRed,
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: widget.revealWidth,
                      child: const Icon(
                        Icons.delete_outline,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _slide,
                builder:
                    (context, child) => Transform.translate(
                      offset: Offset(-_slide.value * widget.revealWidth, 0),
                      child: child,
                    ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
