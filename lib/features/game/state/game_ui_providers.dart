import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A cell of the score table; [round] is -1 for the initial-weights row.
typedef CellRef = ({int round, int player});

/// Tap-region group shared by the weight cells and the scale panel so that
/// keypad taps don't blur the focused cell.
const weightInputTapGroup = 'weight-input';

final focusedCellProvider = StateProvider.autoDispose<CellRef?>((_) => null);

/// User switched the scale input off while it is connected.
final scalePausedProvider = StateProvider.autoDispose<bool>((_) => false);

final keypadOpenProvider = StateProvider.autoDispose<bool>((_) => false);
