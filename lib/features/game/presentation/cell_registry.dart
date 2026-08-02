import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the text controllers and focus nodes for all input cells of the game
/// screen; the domain holds plain values only.
class CellRegistry {
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};

  static String initialWeightKey(int playerIndex) => 'initial:$playerIndex';

  static String measurementKey(int roundIndex, int playerIndex) =>
      'round:$roundIndex:$playerIndex';

  TextEditingController controller(String key) =>
      _controllers.putIfAbsent(key, TextEditingController.new);

  FocusNode focusNode(String key) =>
      _focusNodes.putIfAbsent(key, FocusNode.new);

  void requestFocus(String key) => focusNode(key).requestFocus();

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
  }
}

final cellRegistryProvider = Provider.autoDispose<CellRegistry>((ref) {
  final registry = CellRegistry();
  ref.onDispose(registry.dispose);
  return registry;
});
