# Backlog — Next Session (Bierwiegen)

Open questions and tasks to tackle next. Each item lists what to decide/build and
notes tying it to the current code so the next session has a head start.

## Persistence

### 1. How we save games
- **Question:** Where and how do finished games get persisted?
- Today `gameHistoryProvider` (`lib/features/history/game_history_provider.dart`)
  keeps summaries **in memory only** — the "Letzte Spiele" list is empty on a
  fresh launch and clears on restart.
- Decide: storage mechanism (`shared_preferences` for a small JSON list, or a
  local DB like `sqflite`/`drift`/`hive` if we expect many games), serialization
  format, and retention (cap the list? delete old?).
- `GameSummary` (`lib/features/history/game_summary.dart`) is the snapshot to
  serialize — add `toJson`/`fromJson`.
- **Privacy note:** the app currently states "keine Daten gespeichert"
  (`lib/features/info/strings.dart`). Persisting games needs a matching update to
  the privacy text.

### 2. How we save player data
- **Question:** How do we persist per-player/account data (name, and later the
  account color, stats)?
- Today `profileNameProvider` (`lib/features/account/account_providers.dart`) is
  in-memory only. Ties into item 10 (auto-populate name) and item 9 (account
  color).
- Decide the same storage mechanism as item 1 (keep consistent).

### 2a. Update the privacy / legal text
- The privacy text (`AppStrings.privacy`, shown in the "Rechtliches" section of
  the account screen) currently states no data is collected or stored. Once we
  persist anything (game history, player name, account color — items 1, 2, 9),
  this is no longer accurate and **must be rewritten** to describe what is stored,
  where, and for how long.
- While editing, also fix the existing German typos in `AppStrings.privacy`
  (`werdn`, `gespreichert`) and review the `imprint` text.
- Consider whether persisted data needs a way to be cleared (e.g. a "Daten
  löschen" action) and reflect that in the text.

## Input / round flow

### 3. Better beer animation on the input (roll) screen
- The auto-target roll popup (`lib/features/game/presentation/widgets/roll_dialog.dart`)
  has a basic glass fill + count-down. Improve the beer animation (liquid motion,
  foam, easing, settle effect).

### 4. Use the same input screen for manual adding
- **Goal:** unify the manual "Neue Runde" flow to use the same popup UI as the
  auto roll screen instead of the plain number dialog.
- Today `startNewRound` (`lib/features/game/presentation/submit_flow.dart`)
  branches: auto → `showRollDialog`, manual → `Dialogs.weightInputDialog`.
- Make the roll/target screen accept a manual-entry mode (user types the target
  in the same layout), so both modes share one screen.

### 5. Bigger name in the "Gewicht eingeben" popup
- In `Dialogs.weightInputDialog` (`lib/features/game/presentation/dialogs.dart`),
  make the player name larger / more prominent so it's clear whose weight is being
  entered.

### 5a. Auto-mode first target must depend on the entered initial weights
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

### 5b. Finish condition must account for container tare (not a fixed 50 g)
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

### 5c. Remove a round
- **Goal:** let players delete a round, primarily the current/last one.
- **Example:** the group wants to finish, but someone accidentally taps
  "Neue Runde" and adds an empty round — we need a way to remove it so the finish
  flow becomes available again.
- Today rounds can only be added (`GameNotifier.addRound` in
  `lib/features/game/state/game_providers.dart`); there is no removal. Add a
  `removeRound` / `removeLastRound` and a UI affordance (e.g. on the round label
  `RoundLabelCell`, or next to the "Neue Runde" button).
- Decide scope: only the last round, or any round? Confirm before deleting a round
  that already has entered weights, and re-focus/refresh the table afterwards.
- Interacts with the finish-button visibility (`_buildPlayFooter`,
  `Game.canStartNewRound`): after removing an accidental empty round, the previous
  round is current again and the finish button should reappear when appropriate.

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

### 7. Updated Bluetooth connection flow
- Rework the scale connection UX end-to-end (scan → connect → connected →
  reconnect → disconnect), covering `scale_provider.dart`, the account screen's
  scale card (`_ScaleSection`), and the top-bar `ScaleChip`. Clarify states,
  errors, and the "connects automatically next game" behavior.

### 8. Better settings screen (split menu vs. settings vs. account)
- **Goal:** cleanly separate three concepts:
  - **Menu** — navigation only.
  - **Settings** — only the scale and the rules (with potential legal/privacy
    text).
  - **Account** — its own thing (name, color, games history).
- The old `OptionsScreen` was removed (see item 6). Right now everything —
  scale, rules, "Letzte Spiele", and the legal text — lives on the **account
  screen**. The rework should split this back out: a dedicated **Settings**
  (scale + rules + legal) distinct from **Account** (name, color, history).

## Account personalization

### 9. Account color
- Let the user pick an account color from **8 pastel colors** that fit the game's
  visual language (gold `#FEAD2E` / green `#789283` / warm off-white palette).
- Use it for the avatar background/initial on the account screen (currently the
  fixed gold tint in `account_screen.dart`) and wherever the player is shown.
- Define the 8-swatch palette in `lib/ui/tokens.dart`. Persist per item 2.

### 10. Auto-populate the user name in the player list on app start
- On launch, prefill the first player field on the start screen with the saved
  account name (`profileNameProvider`), instead of an empty field.
- See `_StartScreenState` in `lib/features/home/start_screen.dart`. Depends on
  item 2 (persisted name).
