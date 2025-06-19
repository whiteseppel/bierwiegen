class AppStrings {
  static const String bierwiegenDescription = '''
Bierwiegen ist ein Schätzspiel, welches nicht zwingend mit alkoholischen Getränken gespielt werden muss. Es geht um das Abschätzen von Inhalt, der in deinem Getränk übrig bleibt und wer am nähesten am Zielwert angekommen ist.
''';

  static const String bierwiegenPrerequisites = '''
Um Bierwiegen zu spielen brauchst du eine Digitalwage und ein Getränk für jeden Mitspieler. Die Getränke sollten ein ähnliches Gewicht haben.
''';

  static const String bierwiegenGameRules = '''
Zuerst wird das Gewicht für alle Getränke gewogen, damit jeder weiß, wie man startet (Einwiegen). Anschließend beginnt die erste Runde: Der Spieler mit dem niedirgsten Gesamtgewicht gibt ein Ziel für die Runde an. Dieses muss zwischen 15 und 100 Gramm weniger als das letzte niedrigste Gewicht haben. Nun beginnt die Trinkphase. Jeder Spieler darf einmal ansetzten jedoch beliebig lange von seinem Getränk trinken. Nach dem Trinken werden die Getränke auf die Wage gestellt. Die Werte der Spieler werden notiert. Die Runde wird von dem Spieler gewonnen, der am nähesten am Zielgewicht ist. Nach jeder Runde kann entschieden werden, ob man eine weitere Runde starten möchte.

Das Spiel gewinnt der mit den meisten Rundensiegen.
''';

  static const String appFunctionality = '''
Neues Spiel mit selben Spielern:
Ein neues Spiel kann über die Einstellungen (-> Neues Spiel starten) gestartet werden.

Ändern von Zielgewicht einer Runde:
Beim langen Drücken auf das Zielgewicht lässt sich ein neuer Wert eingeben.

''';

  static const String privacy = '''
Es werden keine Daten gesammelt. Es werdn keine Daten auf dem Gerät gespreichert oder versendet.
''';

  static const String imprint = '''
Die App wird von www.bierwiegen.info entwickelt. Verbesserungsvorschläge und Feedback können gerne an info@bierwiegen.info gesendet werden.
''';
}
