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
            child: const Icon(Icons.arrow_back),
            heroTag: "Zurück",
          ),
          const SizedBox(width: 10),

          /// Restart Game Button
          FloatingActionButton(
            onPressed: () {
              // TODO: reset the whole game (not sure yet how i will do it)
            },
            child: const Icon(Icons.refresh),
            heroTag: "Runde neu starten",
          ),
          const SizedBox(width: 10),
          // TODO: adding round
          FloatingActionButton(
            onPressed: () {
              // Action for second button
            },
            child: const Icon(Icons.sports_esports),
            heroTag: "share",
          ),
          const SizedBox(width: 10),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Icon(_isExpanded ? Icons.close : Icons.more_vert),
          heroTag: "toggle",
        ),
      ],
    );
  }
}
