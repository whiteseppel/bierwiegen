# Automatic target algorithm

How the app picks the next round's **target weight** in automatic mode. This is the
single source of truth for the rationale; the code lives in:

- `Game.autoTargetBase`, `kAutoDrawMin`, `kAutoDrawMax` —
  `lib/features/game/domain/game.dart`
- `drawAutoTarget` — `lib/features/game/presentation/widgets/roll_dialog.dart`
- `startNewRound` — `lib/features/game/presentation/submit_flow.dart`

## Model

- There is **one global target per round**, shared by all players. Everyone aims to
  bring their glass down to the same absolute gram number. This is a deliberate
  choice — no per-player targets.
- Each player's *amount to drink* in a round is `currentWeight − target`.
- A round draws the target **down** from a base weight by a random `draw`:

  ```
  draw ∈ [kAutoDrawMin, kAutoDrawMax]   (uniform, currently 30–80 g)
  newTarget = base − draw               (clamped at 0)
  ```

  `kAutoDrawMin` / `kAutoDrawMax` are the only tuning knobs for step size — change
  them in one place (`game.dart`).

## Choosing the base

```
base = max(lastTarget, lowestCurrentWeight)          // rounds 2+
base = lowestCurrentWeight + kAutoDrawMin             // round 1
```

where `lowestCurrentWeight` is the lightest current glass (each player's last
measurement, else their initial weight), and `lastTarget` is the previous round's
target (absent for round 1).

| Situation | base | Effect |
|---|---|---|
| Someone reached/passed `lastTarget` (`lowest < lastTarget`) | `lastTarget` | Target keeps chaining down normally. |
| Nobody reached `lastTarget` (all undershot, `lowest ≥ lastTarget`) | `lowestCurrentWeight` | Re-anchors to the real glasses so the next drink is bounded. |
| Round 1 (no `lastTarget`) | `lowestCurrentWeight + kAutoDrawMin` | Gentle opening: the lightest glass drinks only 0–(`kAutoDrawMax`−`kAutoDrawMin`) g. |

## Why re-anchor on an undershoot

The naive rule `newTarget = lastTarget − draw` marches the target down **regardless
of what players actually drank**. When players undershoot (leave their glass above
the target), the gap accumulates: the next `lastTarget − draw` demands the leftover
gap **plus** a fresh `draw`, i.e. two large drinks back-to-back.

Anchoring to `max(lastTarget, lowestCurrentWeight)` prevents that. Because
`base ≥ lowestCurrentWeight` is only ever *raised* to `lastTarget` when the lightest
glass is already below it, the lightest player's drink is:

```
lowestCurrentWeight − newTarget
  = draw − (base − lowestCurrentWeight)
  ≤ draw
  ≤ kAutoDrawMax
```

**Invariant: no player is ever forced to drink more than `kAutoDrawMax` (80 g) in a
single automatic round.** Heavier glasses than the lightest may still drink more —
that is the accepted cost of a single global target (see below).

## Accepted trade-offs

- **Single global target ⇒ heavier glasses drink more per round.** With one shared
  target, a player whose glass is heavier than the lightest drinks the difference on
  top. Acceptable because players normally pour into similar glasses; the alternative
  (per-player targets) was rejected to keep the model simple.
- **Round 1 is deliberately gentle.** The base adds `kAutoDrawMin`, so the lightest
  player drinks only `draw − kAutoDrawMin` ∈ 0–(`kAutoDrawMax`−`kAutoDrawMin`) g
  (0–50 g today) in the opening round — easing players in rather than a full step.
- **A big overshoot makes the game "wait."** If one player massively overshoots
  (drops far below the target), `base` stays at `lastTarget`, so that player drinks
  little or nothing while the others catch up. Intended.
