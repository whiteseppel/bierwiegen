import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sizes/sizes.dart';

class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends ConsumerState<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bierwiegen'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Was ist Bierwiegen?', style: TextStyles.subheading),
                Text('''
            Bierwiegen ist ein Schätzspiel, welches nicht zwingend mit alkoholischen Getränken gespielt werden muss.
            Es geht um das Abschätzen von Inhalt, der in deinem Getränk übrig bleibt und wer am nähesten am Zielwert angekommen ist.
                  '''),

                Text(
                  'Was brauche ich für Bierwiegen?',
                  style: TextStyles.subheading,
                ),
                Text('''
            Um Bierwiegen zu spielen brauchst du eine Digitalwage und ein Getränk für jeden Mitspieler. Die Getränke sollten ein ähnliches Gewicht haben.
                  '''),
                Text(
                  'Wie spiele ich Bierwiegen?',
                  style: TextStyles.subheading,
                ),
                Text('''
                  Zuerst wird das Gewicht für alle Getränke gewogen, damit jeder weiß, wie man startet (Einwiegen).
                  Anschließend beginnt die erste Runde:
                  Der Spieler mit dem niedirgsten Gesamtgewicht gibt ein Ziel für die Runde an. Dieses muss zwischen 15 und 100 Gramm 
                  weniger als das letzte niedrigste Gewicht haben. Nun beginnt die Trinkphase. Jeder Spieler darf einmal ansetzten
                  jedoch beliebig lange von seinem Getränk trinken.
                  Nach dem Trinken werden die Getränke auf die Wage gestellt. Die Werte der Spieler werden notiert. Die Runde wird von 
                  dem Spieler gewonnen, der am nähesten am Zielgewicht ist. Nach jeder Runde kann entschieden werden, ob man eine
                  weitere Runde starten möchte.
            
                  Das Spiel gewinnt der mit den meisten Rundensiegen.
                  '''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
