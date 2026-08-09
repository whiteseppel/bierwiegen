# Backlog — Next Session (Bierwiegen)

Open questions and tasks to tackle next. Each item lists what to decide/build and
notes tying it to the current code so the next session has a head start.

## Persistence

### 1. How we save games — DONE
- Finished games now persist to a local **sembast** document store
  (`GameRepository`, `lib/features/history/game_repository.dart`): one JSON record
  per game keyed by `meta.createdAt`. The DB is opened at startup
  (`openAppDatabase`, `lib/features/persistence/app_database.dart`) and the loaded
  list seeds `gameHistoryProvider` via an override in `main`.
- The domain model (`Game` / `Player` / `GameRound` / `GameConfig` /
  `GameMetaData`) was converted to **freezed** with `toJson`/`fromJson`
  (`json_serializable`, `build.yaml` sets `explicit_to_json`).
- Round-trip covered by `test/features/history/game_repository_test.dart`.
- **Retention — DONE (decided):** we retain all games, no cap. Revisit only if a
  storage problem ever surfaces.

### 2. How we save player data — DONE
- The account name now persists via `ProfileRepository`
  (`lib/features/account/profile_repository.dart`), backed by the same sembast DB;
  `profileNameProvider` is a `StateNotifier` that writes on change and is seeded
  from storage in `main`. Account color/stats can extend the same repo.
- Still open: item 10 (auto-populate the name into the start screen) and item 9
  (account color).

### 2a. Update the privacy / legal text — DONE
- `AppStrings.privacy` (`strings.dart`) was rewritten to describe what is stored
  locally (name, profile color, games), that it never leaves the device or goes
  to third parties, that it is fully deletable, and that a future account + games
  may be stored the same way. The old typos (`werdn`, `gespreichert`) are fixed.
- Follow-up if wanted: a one-tap "alle löschen" action (see item 2b); the text
  currently points at per-game delete + uninstall.

### 2b. Remove played games from the list — DONE (follow-ups resolved / not pursued)
- Each card in the "Letzte Spiele" list is now a `flutter_slidable` `Slidable`
  (`RecentGamesScreen`): swipe right-to-left reveals a red trash button that
  deletes the game. Backed by `GameHistoryNotifier.remove(Game)` →
  `GameRepository.delete(Game)`, so it drops from state and storage.
- Follow-ups (confirm step / undo snackbar / "alle löschen") are not of concern
  for now — considered resolved.

### 2c. Responsible-drinking disclaimer
- **Goal:** add a short "Trink verantwortungsvoll" disclaimer so a drinking-game
  app nudges responsible use (and covers us legally).
- **Content:** brief German note — drink responsibly, know your limits, don't
  drink and drive, not for minors. Keep the tone light but clear.
- **Where to show it:** decide placement — candidates are the "Rechtliches"
  section of the account screen (next to `AppStrings.privacy` / `imprint`), a
  one-time notice on first launch, and/or a small line on the start screen
  (`start_screen.dart`) before a game begins.
- Add the text to `AppStrings` (`lib/features/info/strings.dart`) alongside the
  other legal strings. Ties into item 2a (legal-text rewrite) — do them together.
- Open questions: show once vs. always, and whether it needs an explicit
  "Ich bin über 18" acknowledgement before the first game.

## Input / round flow

### 3. Better beer animation on the input (roll) screen
- The auto-target roll popup (`lib/features/game/presentation/widgets/roll_dialog.dart`)
  has a basic glass fill + count-down. Improve the beer animation (liquid motion,
  foam, easing, settle effect).

### 4. Use the same input screen for manual adding — DONE
- Manual and auto "Neue Runde" now share one popup: `startNewRound`
  (`submit_flow.dart`) routes both through the roll/target screen; the old
  `Dialogs.weightInputDialog` branch is gone.

### 5. Bigger name in the "Gewicht eingeben" popup — DONE
- The unified target/weight popup (`Dialogs.targetWeightDialog`, `dialogs.dart`)
  now shows the player name prominently.

### 5a. Auto-mode first target must depend on the entered initial weights — DONE
- The first auto round now anchors at `lowestCurrentWeight + kAutoDrawMin` instead
  of a flat 500 (`startNewRound`, `submit_flow.dart`); later rounds still chain off
  `lastTarget`. The draw range is named (`kAutoDrawMin` 30 / `kAutoDrawMax` 80 in
  `roll_dialog.dart`) so the boundary is one variable. Effect: the lightest glass's
  owner drinks at most `kAutoDrawMax − kAutoDrawMin` (50 g) in round 1, and never a
  negative amount. Single global target kept by design, so heavier glasses drink
  more per round — accepted trade-off.

### 5a (original notes)
- **Problem:** in automatic mode the very first round currently starts from a flat
  `500 g` baseline (`startNewRound` in `submit_flow.dart` →
  `showRollDialog(current: lastTarget ?? 500)`, drawing 30–80 g below). This
  ignores the container's tare weight.
- **Example:** playing with a bottle that weighs ~300 g and a full total of ~800 g,
  a first target of ~450 g means drinking ~350 g in one go — far too big a step.
- **Requirement:** the auto starting weight (and each drawn target) should be
  derived from the players' entered initial weights, so the *amount to drink* is
  reasonable regardless of how heavy the glass/bottle is.
- Notes to work out next time: base the first target on the players' initial
  weights (e.g. relative to the lowest current total), and consider expressing the
  30–80 g step against the *drink* amount rather than the gross weight. The initial
  weights are on `Game.players[i].initialWeight`; `Game.previousWeight` /
  `lastMeasurement` give the current per-player weight.

### 5b. Finish condition must account for container tare (not a fixed 50 g) — DONE
- Solved by making finishing **manual** instead of tare-based, so tare never has to
  be known. The "Spiel beenden" button (primary) now shows below the "+ Neue Runde"
  button (secondary) whenever `canStartNewRound && rounds.isNotEmpty` — i.e. once at
  least one round is finished and the last round is complete (`_buildPlayFooter`,
  `game_screen.dart`). The old absolute `Game.finishThreshold` (50 g) and `finishers`
  getter were removed, along with the footer hint text. `finishGameDialog` still
  confirms, so a mis-tap can't end the game accidentally.

### 5b (original notes)
- **Problem:** the game ends via an absolute threshold — a glass under
  `Game.finishThreshold` (50 g) marks a player as a *finisher*
  (`Game.finishers`), which is also what reveals the "Spiel beenden" button.
  This assumes an almost weightless empty container.
- **Example:** a 330 ml glass bottle can have a total weight around 550 g (same
  ballpark as a 500 ml can or a plastic cup with 500 ml), but the empty bottle
  alone weighs far more than 50 g. Those players can **never** drop under 50 g, so
  the game can never finish for them.
- **Requirement:** rethink when a game is finished / when players may press the
  finish button so it works across container types. It should be driven by the
  *remaining drink* rather than the gross weight — e.g. relative to each player's
  entered initial (full) weight, not an absolute number.
- Open sub-questions to resolve next time:
  - We only know the initial **full** weight, not the empty-container (tare)
    weight — decide whether to ask for the empty weight, assume a standard fill
    volume, or define "finished" as "drank at least X % / X g of the starting
    amount".
  - Should finishing be per-player and automatic, or a manual decision once a
    round is complete? (Ties into the current finish-button visibility rules in
    `game_screen.dart` `_buildPlayFooter` and `Game.canStartNewRound`.)
  - Keep it consistent with the auto-target step sizing in item 5a.

### 5c. Remove a round — DONE
- **Goal:** let players delete the current/last round.
- **Example:** the group wants to finish, but someone accidentally taps
  "Neue Runde" and adds an empty round — we need a way to remove it so the finish
  flow becomes available again.
- **State:** `GameNotifier.removeLastRound` (`game_providers.dart`) drops the last
  round; `confirmAndRemoveLastRound` (`widgets/round_delete.dart`) confirms first
  when the round already holds weights, then clears focus.
- **Two UI affordances** live behind the `roundDeleteStyle` switch in
  `widgets/round_delete.dart` so they can be compared in the app:
  - `trashCell` — the last round's row extends past the last player with a
    distinct trash-can cell (`DeleteRoundCell`) in the horizontal scroll area.
  - `swipeReveal` — the last round's `RoundLabelCell` drags aside
    (`SwipeToRevealDelete`) to reveal a delete button, teasing a peek when the
    round first appears.
- **Follow-ups to decide:** pick one variant (or keep both), whether to allow
  deleting any round vs. only the last, and consider a destructive-red confirm
  button (`Dialogs._styledDialog` currently hardcodes the gold confirm).
- Scope note: currently only the **last** round is removable. Finish-button
  visibility (`_buildPlayFooter`, `Game.canStartNewRound`) already reacts, so
  removing an accidental empty round re-enables the finish flow.

## Navigation / structure

### 6. Update the menu button on the home screen — DONE
- The home person icon now navigates **straight to the account screen**
  (`_openAccount` in `lib/features/home/start_screen.dart`); the old bottom-sheet
  menu was removed. The account screen already covers scale, rules, and
  "Letzte Spiele".
- **Follow-up (done):** the legal text (`AppStrings.privacy` / `imprint`) now lives
  in a "Rechtliches" section at the end of the account screen, and the orphaned
  screens/helpers were deleted: `options_screen.dart`, `introduction_screen.dart`,
  `game_info_widget.dart`, `privacy_widget.dart`, `privacy_and_imprint.dart`, plus
  the now-unused `ui/text_styles.dart` and `ui/button_styles.dart`. `strings.dart`
  stays (some entries are currently unused but kept for the settings rework).

### 7. Updated Bluetooth connection flow — DONE
- The scale connection UX was reworked end-to-end (scan → connect → reconnect →
  disconnect) across `scale_provider.dart`, the account/settings scale card, and
  the top-bar `ScaleChip`.

### 8. Better settings screen (split menu vs. settings vs. account) — DONE
- Settings and Account are now split: a dedicated `settings_screen.dart` (scale +
  rules + legal, with `legal_detail_screen.dart`) distinct from
  `account_screen.dart` (name, color, history); shared pieces live in
  `account_ui.dart`.

## Account personalization

### 9. Account color — DONE
- The player picks an avatar color, persisted via `ProfileRepository.saveColor`
  and exposed through `profileColorProvider`; used for the avatar on the account
  screen and wherever the player is shown (`start_screen`, `settings_screen`).
- Shipped as **5 colors** defined in `lib/features/account/profile_color.dart`
  (`ProfileColor` enum), not the originally-planned 8 pastels in `tokens.dart`.

### 10. Auto-populate the user name in the player list on app start — DONE
- `_StartScreenState.initState` (`start_screen.dart`) prefills the first player
  field with the saved account name (`profileNameProvider`) when it is non-empty,
  and adds a trailing empty field so more players can be added.

## Localization / formatting

### 11. Use `intl` for localization and locale-correct formatting
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

## Design system

### 12. Audit and extend the design tokens for a consistent layout
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
