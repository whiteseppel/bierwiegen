import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_round_provider.dart';
import '../providers/player_provider.dart';

class ActionButtonRow extends ConsumerStatefulWidget {
  const ActionButtonRow({super.key});

  @override
  ConsumerState<ActionButtonRow> createState() => _ActionButtonRowState();
}

class _ActionButtonRowState extends ConsumerState<ActionButtonRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          /// Back Button
          FloatingActionButton(
            key: Key("backButton"),
            onPressed: () {
              Navigator.of(context).pop();
            },
            heroTag: "Zurück",
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),

          /// Restart Game Button
          FloatingActionButton(
            key: Key("resetButton"),
            onPressed: () {
              // NOTE: maybe create a pop up before resetting the round?
              ref.read(gameRoundProvider.notifier).clearRounds();
              ref.read(playerProvider.notifier).resetInitialWeight();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            heroTag: "Runde neu starten",
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          // NOTE: we need a share button in the future for sharing the lobby
          // FloatingActionButton(
          //   onPressed: () {
          //     // Action for second button
          //   },
          //   heroTag: "share",
          //   child: const Icon(Icons.sports_esports),
          // ),
          // const SizedBox(width: 10),
        ],
        FloatingActionButton(
          key: Key("toggleButton"),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          heroTag: "toggle",
          child: Icon(_isExpanded ? Icons.close : Icons.more_vert),
        ),
      ],
    );
  }
}
