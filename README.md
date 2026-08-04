# bierwiegen

This is a project digitalizing a party drinking game. 

## Tasks

### Next Steps
- [ ] Scrollable game field with fixed headers (see requirements below)
- [ ] Shared component library / design system (see requirements below)
- [ ] Input methods: keyboard + scale measurement overlay (see requirements below)
- [ ] Scale connection feedback in the options screen (see requirements below)
- [ ] 2 Game modes (Standard, Points)
- [ ] "Spiel beenden"
  - [ ] Freeze game input and changes when current game is finished - also remove unfinished game rounds

### Nice to have
- [ ] Fake scale for development and tests: `ScaleService` wrapper around
      FlutterBluePlus plus a `FakeScaleService` playing scripted scenarios
      (weight ramps up and settles, no scale found, disconnect mid-round) so the
      measurement overlay and connection feedback can be built and tested
      without hardware
- [ ] Join game
- [ ] Rework Bluetooth connection process (scan, then confirm on popup, then connect)
      — error feedback is covered by "Scale connection feedback" under Requirements
- [ ] Update Visuals
  - [ ] Better visual star
- [ ] Save games and see history of game

### Release for Apple Appstore
- [ ] Create Apple App Store account

## Changelog

### Unreleased

- [x] Restructure repository to the target architecture (feature folders,
  domain/state/presentation split for the game, design tokens in `ui/`)
- [x] Focus next text input after adding a round (fixed as part of the
  focus-flow rework)
- [x] Scale connection: show scanning state, "Keine Waage gefunden" and
  connection errors in the options screen
- [x] App theme is seeded from the app colors instead of `Colors.deepPurple`

### [0.3.0] - 2025-06-22

- [x] Screen orientation only portrait
- [x] Limit number input for new round to 5
- [x] "Spiel beenden"
  - [x] Create button to end the game
  - [x] Button only available after at least one round is played
  - [x] Add winning player widget on Bottom
  - [x] Add animation (confetti) when game finishes
  - [x] Below the winner Widget should be a "Neues Spiel starten" button

### [0.2.0]

- [x] Optical improvements
  - [x] Add header (back button, title, options button)
  - [x] move "Ziel" back to top row
- [x] Splash Screen for Android 12 and higher
- [x] Adapt target weight (if someone misclicks)
- [x] Retain splash screen for 1 sec
- [x] Continue to next field with "next" button
- [x] Multiple winners if they have the same weight
- [x] Rework calculation for winning player (so that multiple can win)
- [x] Options screen should be able to reset game - going back should not start a new game
- [x] Max weight - max value should be 10000 (or 5 digits)

### [0.1.0]

- [x] App Icon
- [x] Launch Screen
- [x] Fix row height based on players and screen orientation
- [x] Color Scheme
- [x] Last layout rework
  - [x] Area for displaying current points is too big
  - [x] Add padding to bottom of game screen
- [x] Screen always on
- [x] Initial Weight input also with scale
- [x] Game rule description
- [x] Settings button in app bar - remove FAB
- [x] Privacy policy
- [x] Impressum
- [x] Google Play Store test release

## Architecture

Target structure for the repository. New code should follow this; existing code is
migrated by the refactoring plan below.

### Repository structure

```
lib/
  app/                      # MyApp, theme wiring, splash — main.dart stays tiny
  ui/                       # design system: tokens, text styles, buttons
  features/
    game/
      domain/               # pure Dart, zero Flutter imports
                            #   game.dart (aggregate: players, rounds, config, meta)
                            #   game_round.dart, measurement.dart, player.dart
                            #   game_config.dart (mode + future game settings)
                            #   scoring.dart (single scoring implementation,
                            #   parameterized by config)
      state/                # Riverpod notifiers — the only writers of game state
      presentation/         # game screen + widgets (grid cells, overlay, winner)
    home/                   # start screen, player-name entry
    scale/                  # Bluetooth: service wrapper + state machine
    settings/               # options screen
    info/                   # game rules intro, privacy/imprint — leaf feature,
                            # linked from home and settings
```

Features without enough code for layers (`home/`, `scale/`, `settings/`) stay
flat until they hurt — no folders for symmetry's sake.

### Rules

- **Domain and state code never imports `package:flutter/`.** This is the
  enforceable test for the UI/logic split.
- **`ui/` imports nothing but Flutter.** Features import `ui/`; importing another
  feature's screens for navigation is fine, but logic dependencies between
  features are limited to `game → scale`, never the reverse. The scale feature
  exposes state (connection, live weight, stability progress, committed values)
  and knows nothing about rounds or players.
- **One game at a time, one owner.** A single `Game` aggregate held by one
  notifier with intent methods (`startGame`, `addRound`, `setMeasurement`,
  `finishGame`). Scores are a derived provider computed from the aggregate, not
  synced state.
- **Unidirectional flow.** The presentation layer owns all
  `TextEditingController`s and `FocusNode`s (created per cell in a small
  registry). Presentation feeds parsed values into the domain via notifier
  methods; the domain publishes new state; presentation re-renders from it. The
  domain never touches a controller; widgets never mutate game data directly.
  Focus logic follows the same split: the domain answers "which cell is next?",
  presentation moves the focus there.
- **Strings** live in one file per feature (no full l10n setup until a second
  language is actually wanted).
- **Tests** mirror the tree (`test/features/...`). The scale service wrapper
  exists so the connection state machine can be tested against a fake, without a
  physical scale.

### Refactoring plan (before implementing new features)

1. [x] Delete dead code (`current_game_provider.dart`, commented-out
       `initial_input_field.dart`, unused `action_button_row.dart`, stray
       `print`s) and consolidate the three duplicated scoring loops into
       `scoring.dart`
2. [x] Separate domain state from UI controllers: `Measurement` becomes a pure
       value, controllers/focus nodes move to a presentation-layer registry,
       `forceRefresh()` is deleted, updates go through notifier methods
3. [x] Consolidate the four game providers into the single `Game` aggregate +
       notifier; derive scores
4. [x] Rework the scale layer: subscriptions out of `ScaleState` into the
       notifier, richer connection states (scanning / connecting / connected /
       not-found / error), fix the stacked `scanResults` listeners, move the
       2-second stability logic from `WeightInputField` into the scale state
5. [x] Extract game-screen cell widgets (player header, target, measurement) in
       preparation for the fixed-header grid
6. [x] Move the design-system seed (`sizes.dart`) to `ui/`, wire `CustomColors`
       into `ThemeData` (previously seeded with `Colors.deepPurple`), migrate the
       folder structure

## Requirements

### Start screen redesign

See [docs/start_screen_requirements.md](docs/start_screen_requirements.md) —
layout (player input → game options button → start → "oder" → join game),
game-options bottom sheet, and the menu page behind the top-right player icon.

### Scrollable game field with fixed headers

Currently the game field divides the screen width by the number of players, so with
many players the columns become unreadably narrow, and long games push rounds off
screen. The game field should behave like a spreadsheet with frozen panes: the
player header row and the target ("Ziel") column stay fixed while the measurement
grid scrolls in both directions.

**Layout recap:** each player is one column (header row on top shows name and win
count), each game round is one row (first cell of a row is the round's target
weight).

**Requirements:**

- [ ] Horizontal scrolling through players
  - [ ] Only a limited number of player columns is visible at a time; the column
        width is derived from that number, not from the total player count
  - [ ] The maximum number of visible player columns is a configurable constant
        (e.g. 4); with fewer players than that, columns fill the screen as today
  - [ ] Scrolling left/right reveals the remaining players
  - [ ] The player header row scrolls horizontally in sync with the measurement
        grid, so names always sit above their own column
  - [ ] The "Ziel" column (round targets) stays fixed on the left while scrolling
        horizontally
- [ ] Vertical scrolling through rounds
  - [ ] Only a limited number of round rows is visible at a time (row height stays
        fixed); the maximum number of visible rounds is a configurable constant
        (e.g. 10)
  - [ ] Scrolling up/down reveals the remaining rounds
  - [ ] The player header row (names + win counts) stays fixed on top while
        scrolling vertically
  - [ ] The "Ziel" column scrolls vertically in sync with the measurement grid, so
        each target stays aligned with its round's measurements
- [ ] Behavior
  - [ ] When a new round is added, the grid scrolls automatically so the new round
        is visible
  - [ ] The initial-weight row scrolls horizontally with the player columns
  - [ ] Existing interactions keep working inside the scrollable area: weight
        input, long-press to adapt the target, star display for round winners
  - [ ] The initial-weight row is not pinned; it scrolls away vertically with the
        rounds
  - [ ] Moving focus with the "next" button does not auto-scroll to the focused
        player's column (may be added later)

### Shared component library (design system)

The UI should be composed from a small set of shared components and text styles
instead of ad-hoc widgets, so screens look consistent and style changes happen in
one place. A starting point already exists in `lib/sizes/sizes.dart`
(`ButtonStyles`, `TextStyles`, `CustomColors`); the component library builds on
top of it.

**Requirements:**

- [ ] Buttons as reusable widgets, not just styles
  - [ ] `PrimaryButton` — filled, for the main action of a screen (e.g. "Neues
        Spiel starten")
  - [ ] `SecondaryButton` — outlined, for secondary actions (e.g. "Spiel
        beenden")
  - [ ] Both take a label and an `onPressed` callback and render their own
        disabled state; callers never pass a `ButtonStyle`
- [ ] Text styles as a complete scale
  - [ ] One style per role: heading, subheading, regular text, small text
  - [ ] Consolidate the current overlapping styles (`regularFont` 18 vs.
        `regular` 14, `large` 17) into the scale — one source of truth per role
  - [ ] Styles define size, weight, and color together, so callers don't add
        their own `fontWeight`/`color` on top
- [ ] Shared design tokens
  - [ ] Colors, border radius, and standard spacing live as named constants next
        to the components; no hard-coded hex values or magic paddings in screens
- [ ] Adoption
  - [ ] All components live in one place (e.g. `lib/ui/` or
        `lib/widgets/design_system/`)
  - [ ] Existing screens are migrated to the shared components; direct uses of
        `ButtonStyles`/raw `TextStyle` in screens are replaced
  - [ ] New UI is composed from these components only

### Input methods

There are two distinct ways to enter a measurement, and both must work on the same
game field. Which one is used depends on whether a scale is connected — keyboard
input is the fallback and always available.

**1. Keyboard input**

The smartphone is passed around; each player types their weight.

- [ ] Tapping a measurement field gives it the focus and opens the number
      keyboard
- [ ] The keyboard's "next" action moves the focus to the next player's empty
      field in the current round
- [ ] After the last player of a round, "next" triggers the flow for adding a new
      round (target weight dialog), as it does today
- [ ] Typed input keeps the current constraints: digits only, max 5 characters

**2. Scale input (measurement overlay)**

The smartphone stays put; a connected Bluetooth scale delivers the weight for the
player whose field currently has the focus. Instead of the current snackbars, a
pop-up overlay shows the measurement in progress.

- [ ] The overlay appears when a scale is connected and a measurement field has
      the focus
- [ ] The overlay shows, top to bottom:
  - [ ] The name of the player whose field has the focus (the field the weight
        will be written into)
  - [ ] The live weight currently reported by the scale
  - [ ] The player's current weight, i.e. their measurement from the previous
        round (the initial weight if no round has been played yet)
  - [ ] The drinking goal: how much the player has to drink to land exactly on
        the round's target (previous weight minus target)
  - [ ] A progress bar for the stability countdown
- [ ] Stability rule: the weight is only committed to the field when it has not
      changed for 2 seconds
  - [ ] The progress bar fills over those 2 seconds and resets whenever the
        weight changes
  - [ ] When the bar completes, the weight is written into the focused field and
        the overlay confirms the result (e.g. "Dein Bier hat 512 Gramm!")
- [ ] After a committed measurement, the focus moves to the next player's empty
      field, so consecutive players can weigh without touching the phone
- [ ] The overlay replaces the current snackbar-based feedback
      ("Biermessung erfolgt ..")

**Input method switch (future feature)**

The user must be able to turn off the automatic scale input (e.g. when the scale
misbehaves) without dropping the Bluetooth connection, and turn it back on
seamlessly. The concrete UI is still open, but the implementation of the input
methods must be prepared for it:

- [ ] Connection state (disconnected / connecting / connected) and input mode
      (automatic / manual) are two independent states — toggling the input mode
      never touches the connection
- [ ] Disabling automatic input only stops scale values from being written into
      fields (and hides the overlay); the weight stream keeps running, so
      re-enabling is instant — no scan or reconnect

Open question — where the switch lives. Candidates:

- Scale icon in the game screen app bar with three visual states
  (active / paused / disconnected); tap to toggle, tap while disconnected jumps
  to the options screen
- A "Manuell eingeben" action on the measurement overlay that pauses automatic
  input and opens the keyboard (disable-only; needs a persistent counterpart to
  re-enable)
- A toggle in the options screen, separate from the connect button
- Implicit rule on top of any of these: typing always wins — manual typing
  cancels the pending stability timer so the scale never overwrites typed input

### Scale connection feedback (options screen)

Connecting the scale is currently a black box: the button switches between
"Verbinden" / "Verbinde ..." / "Verbunden", but when nothing is found the button
silently resets, and errors are only printed to the console. The whole connection
process should be visible to the user.

**Requirements:**

- [ ] Bluetooth status
  - [ ] The options screen shows whether Bluetooth is switched on before/while
        connecting
  - [ ] If Bluetooth is off, the user is told to enable it instead of a scan
        silently failing
  - [ ] If the required Bluetooth permissions are missing, the user is told so
- [ ] Connection progress
  - [ ] Every stage of the process is visible: scanning for the scale → scale
        found → connecting → connected
  - [ ] While scanning, the user sees that the search is running (the scan takes
        up to 7 seconds)
- [ ] Failure feedback
  - [ ] If the scan finishes without finding a scale, a pop-up says that no scale
        was found
  - [ ] If an error occurs while establishing the connection, the error is shown
        to the user instead of only being logged
  - [ ] If an already connected scale disconnects, the user is informed and can
        reconnect from the options screen
- [ ] After a successful connection, the live weight remains visible as
      confirmation that values arrive (as today)

## Ideas for project improvement

### Save previous games
I want to show my friends the games of the previous days and flex how close
i got several times to the weight

### Game modes
I want to have 2 game modes:
- Regular Mode: only the one with the closest score gets one point
- Point Mode: first place gets 3 points, second 2 and third 1. If you get the target 
  exactly you get 5 points.

### Short animation after each round
I want to have a short animation after finishing each round before the next round is
started.

### Configure players
I want to configure players to enter the name (and the game should remember previous players)

### Teammode
I want to have a mode where players are in a team and play together against another team - a 
team wins the round if all people have a combined lower offset as the other team.

## Further Ideas
Easy Mode for beginner players - when you start with the game you do not have to be exactly on 
the weight to get better results compared to users that have played the game for some time.
