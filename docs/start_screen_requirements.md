# Start Screen — Design Requirements (Bierwiegen)

## Context

Bierwiegen is a mobile party drinking game app (Flutter, portrait-only, German UI).
Players weigh their beer glasses on a Bluetooth scale and try to hit a target
weight. The start screen is the app's entry point: enter player names, configure
the game mode, start or join a game.

## Brand / visual language

- Primary color: warm gold/amber `#FEAD2E`; secondary: muted green `#789283`
- Background: warm off-white `#EFEEE9`; text: `#1C1B18` (primary), `#6F6C66` (muted)
- Supporting tints: green tint `#EDF1EE`, gold tint `#FDF1DC`, tile background `#F4F3EF`
- Border radius: 12 px standard; rounded, friendly, party-casual feel — clean, not childish
- Material Design 3 foundation; native platform components (system keyboard,
  standard text fields — no custom mockup controls)

## Screen structure (top to bottom)

1. **App bar area**
   - App title / branding: "Bierwiegen" (may include logo/illustration — beer
     glass + scale motif) with tagline "Dein Party-Game"
   - **Player icon / menu button, top right** → opens the menu page (see below)
2. **Player name input (core interaction, first content block)**
   - Short instruction: "Gib die Namen der Mitspieler ein und lege direkt los!"
   - One text field per player, hint "Spieler …"
   - There is always exactly one empty field at the bottom; as soon as the user
     types into it, a new empty field appears below (list grows dynamically —
     no explicit "add player" button)
   - Filled fields show a clear/remove affordance (✕ suffix icon) to delete
     that player
   - Uses the native system keyboard; "next" on the keyboard jumps to the
     following field
   - No hard player limit, list scrolls; usable from 2 up to ~10 players
3. **Game options button** (above the start button)
   - Opens a **bottom sheet** for configuring the game before starting
   - Bottom sheet contents: select the game rules / game mode
     (Standard / Points), select team mode
   - The bottom sheet is the extension point for all future game configuration —
     it does the heavy lifting so the start screen itself stays simple
   - The button should reflect the current selection (e.g. "Modus: Standard")
     so the choice is visible without opening the sheet
4. **Primary CTA: "Spiel starten"**
   - Full width, filled/primary style
   - Disabled until at least one name is entered
5. **Divider: "oder"**
   - Visually distinctive horizontal lines left and right of the word "oder"
6. **Secondary CTA: "Spiel beitreten" (join game)**
   - Full width, visually secondary to "Spiel starten" (outlined style)

Not on the start screen (moved to the menu page): settings, game rules /
"Was ist Bierwiegen?" info.

## Menu page (opened via player icon, top right)

Contents to be detailed in a separate spec; planned entries:

- Settings (scale connection etc.)
- Game info / rules ("Was ist Bierwiegen? Wie spiele ich Bierwiegen?")
- Game history (later — see future improvements)

## Behavior & constraints

- Portrait only, phone-first
- Whole screen scrolls when the keyboard is open / many players are entered
- The keyboard must not hide the field being edited
- Buttons come from the shared design system: PrimaryButton (filled) /
  SecondaryButton (outlined); one text-style scale (heading, subheading,
  regular, small)

## Future improvements (reserve space / plan patterns, don't build yet)

- **Game options bottom sheet as the config hub:** future game configuration
  lands in the bottom sheet, not on the start screen — team assignment UI for
  team mode, Easy Mode for beginners, and any further rule variants
- **Remembered players:** the app will remember previous players — plan for
  suggestions while typing or a row of recent-player chips near the name list
  to add them with one tap
- **Game history:** "show previous games / best results" lives in the menu
  page behind the player icon — it does not need space on the start screen
- **Join game flow:** "Spiel beitreten" is already in the layout; the flow
  behind it (how a device joins a running game) is still open
