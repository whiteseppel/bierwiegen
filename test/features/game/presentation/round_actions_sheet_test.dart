import 'package:bierwiegen/features/game/presentation/widgets/round_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(void Function(BuildContext) onPressed) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows edit and delete for the last round, returns delete', (
    tester,
  ) async {
    RoundAction? result;
    await tester.pumpWidget(
      _harness((context) async {
        result = await showRoundActionsSheet(
          context,
          roundIndex: 2,
          canDelete: true,
        );
      }),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('RUNDE 3'), findsOneWidget);
    expect(find.text('Ziel ändern'), findsOneWidget);
    expect(find.text('Runde löschen'), findsOneWidget);

    await tester.tap(find.text('Runde löschen'));
    await tester.pumpAndSettle();
    expect(result, RoundAction.delete);
  });

  testWidgets('hides delete when the round may not be removed', (tester) async {
    RoundAction? result;
    var returned = false;
    await tester.pumpWidget(
      _harness((context) async {
        result = await showRoundActionsSheet(
          context,
          roundIndex: 2,
          canDelete: false,
        );
        returned = true;
      }),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Ziel ändern'), findsOneWidget);
    expect(find.text('Runde löschen'), findsNothing);

    await tester.tap(find.text('Ziel ändern'));
    await tester.pumpAndSettle();
    expect(returned, isTrue);
    expect(result, RoundAction.editTarget);
  });
}
