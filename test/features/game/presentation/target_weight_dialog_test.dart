import 'package:bierwiegen/features/game/presentation/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('target weight dialog builds, edits and returns a value', (
    tester,
  ) async {
    double? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await Dialogs.targetWeightDialog(
                        context,
                        eyebrow: 'Runde 3',
                        caption: 'Euer nächstes Zielgewicht',
                        confirmLabel: 'Runde starten',
                        fromWeight: 500,
                        initialValue: 400,
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Renders without layout exceptions (baseline row + beer glass).
    expect(find.text('ZIEL'), findsOneWidget);
    expect(find.text('von 500 g'), findsOneWidget);
    expect(find.text('RUNDE 3'), findsOneWidget);
    expect(find.text('−100 g gegenüber 500 g'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '250');
    await tester.pump();
    expect(find.text('−250 g gegenüber 500 g'), findsOneWidget);

    await tester.tap(find.text('Runde starten'));
    await tester.pumpAndSettle();

    expect(result, 250);
  });

  testWidgets('confirm is disabled until a value is entered', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed:
                        () => Dialogs.targetWeightDialog(
                          context,
                          eyebrow: 'Runde 1',
                          caption: 'Euer nächstes Zielgewicht',
                          confirmLabel: 'Runde starten',
                          fromWeight: 500,
                        ),
                    child: const Text('open'),
                  ),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Gib das Ziel für diese Runde ein.'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
