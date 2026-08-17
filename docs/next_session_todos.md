# Backlog — Next Session (Bierwiegen)

Open questions and tasks to tackle next. Each item lists what to decide/build and
notes tying it to the current code so the next session has a head start.

## 1. Responsible-drinking disclaimer
- **Goal:** add a short "Trink verantwortungsvoll" disclaimer so a drinking-game
  app nudges responsible use (and covers us legally).
- **Content:** brief German note — drink responsibly, know your limits, don't
  drink and drive, not for minors. Keep the tone light but clear.
- **Where to show it:** decide placement — candidates are the "Rechtliches"
  section of the account screen (next to `AppStrings.privacy` / `imprint`), a
  one-time notice on first launch, and/or a small line on the start screen
  (`start_screen.dart`) before a game begins.
- Add the text to `AppStrings` (`lib/features/info/strings.dart`) alongside the
  other legal strings.
- Open questions: show once vs. always, and whether it needs an explicit
  "Ich bin über 18" acknowledgement before the first game.

## 2. Use `intl` for localization and locale-correct formatting
- **Goal:** adopt Dart's `intl` package for both string localization and
  formatting (dates, times, numbers) instead of hand-rolled helpers and inline
  German strings.
- **Formatting:** replace the manual helpers in
  `lib/features/history/date_format_de.dart` (month/weekday arrays, `clock`,
  `durationLabel`) and any manual number/weight formatting
  (`lib/features/game/presentation/format.dart`) with `DateFormat` / `NumberFormat`
  bound to the active locale (e.g. `DateFormat.MMM('de')`, `DateFormat.EEEE('de')`).
  `date_format_de.dart` is an interim manual stopgap meant to be superseded here.
- **Strings:** the UI is German-only with strings scattered inline across screens
  and in `AppStrings` (`lib/features/info/strings.dart`). Move them into localized
  resources — set up `flutter_localizations` + `intl` in `pubspec.yaml`, add
  `l10n.yaml` + ARB files, generate `AppLocalizations`, and wire
  `MaterialApp.localizationsDelegates` / `supportedLocales`.
- Decide the supported locales (de only, or de + en) — this is a broad refactor,
  best done as its own pass.

## 3. Audit and extend the design tokens for a consistent layout
- **Goal:** review `lib/ui/tokens.dart` and make the whole project use it
  consistently, so spacing, colors, radii and text styles are uniform.
- `Spacings` (small 8 / medium 16 / large 24) exists and covers the 6/8/16/24/26
  family, but off-scale gaps are still literals across the app (10, 12, 14, 18,
  20, 22). Decide the full scale — e.g. add `xsmall` (4) and steps for 12 / 20 —
  then sweep the remaining literals onto it.
- Also review the other tokens for consistency and coverage:
  - `standardBorderRadius` (12) vs. the many literal radii still in use (14, 22,
    28, the sheet's `Radius.circular(28)`), and one-off `Border`/`BoxShadow`
    values scattered inline (e.g. `Color(0x0F000000)`, `Color(0x1A000000)`).
  - Text styles — `ui/text_styles.dart` was deleted; styles are now inline
    `TextStyle`s everywhere. Consider a small shared type scale (headings, body,
    labels, mono) so screens stop redefining the same sizes/weights.
- Deliverable: a tightened token set in `tokens.dart` and a pass replacing
  remaining magic numbers with tokens where it improves consistency.
