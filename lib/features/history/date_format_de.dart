import 'package:intl/intl.dart';

const _locale = 'de_DE';

final _dayMonthYear = DateFormat('d. MMM y', _locale);
final _weekdayDayMonth = DateFormat('EEEE, d. MMM', _locale);
final _dayMonth = DateFormat('d. MMM', _locale);
final _monthAbbrev = DateFormat('MMM', _locale);
final _clock = DateFormat('HH:mm', _locale);

/// "21. Aug. 2025".
String dayMonthYear(DateTime dt) => _dayMonthYear.format(dt);

/// "Donnerstag, 21. Aug.".
String weekdayDayMonth(DateTime dt) => _weekdayDayMonth.format(dt);

/// "21. Aug.".
String dayMonth(DateTime dt) => _dayMonth.format(dt);

/// Abbreviated German month, e.g. "Aug.".
String monthAbbrev(DateTime dt) => _monthAbbrev.format(dt);

/// "21:34".
String clock(DateTime dt) => _clock.format(dt);

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
