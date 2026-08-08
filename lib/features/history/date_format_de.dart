const _monthsShort = [
  'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
];

const _weekdays = [
  'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', //
  'Freitag', 'Samstag', 'Sonntag',
];

/// Abbreviated German month for a `DateTime.month` (1–12).
String monthShort(int month) => _monthsShort[month - 1];

/// German weekday for a `DateTime.weekday` (1 = Monday … 7 = Sunday).
String weekdayName(int weekday) => _weekdays[weekday - 1];

String _two(int value) => value.toString().padLeft(2, '0');

/// "21:34" for [dt].
String clock(DateTime dt) => '${_two(dt.hour)}:${_two(dt.minute)}';

/// "48 Min" / "1 Std 6 Min" / "1 Std".
String durationLabel(Duration d) {
  final minutes = d.inMinutes;
  if (minutes < 60) {
    return '$minutes Min';
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours Std' : '$hours Std $rest Min';
}
