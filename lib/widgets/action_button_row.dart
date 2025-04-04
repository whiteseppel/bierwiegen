import 'package:flutter/material.dart';

class ActionButtonRow extends StatefulWidget {
  const ActionButtonRow({super.key});

  @override
  State<ActionButtonRow> createState() => _ActionButtonRowState();
}

class _ActionButtonRowState extends State<ActionButtonRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          /// Back Button
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            heroTag: "Zurück",
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),

          /// Restart Game Button
          FloatingActionButton(
            onPressed: () {
              // TODO: reset the whole game (not sure yet how i will do it)
            },
            heroTag: "Runde neu starten",
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          // TODO: adding round
          FloatingActionButton(
            onPressed: () {
              // Action for second button
            },
            heroTag: "share",
            child: const Icon(Icons.sports_esports),
          ),
          const SizedBox(width: 10),
        ],
        FloatingActionButton(
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
