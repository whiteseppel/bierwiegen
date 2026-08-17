# Roadmap — Connected players (host & join)

**Goal:** one player hosts a game (and connects the scale); others join from their
own phones, pick or enter their player name, and watch the same game screen live
— read-only in v1. When the game finishes, it lands in every joiner's own
"Letzte Spiele" history too.

**Approach:** host-authoritative sync over the local network, no shared backend.
The host phone runs an in-app WebSocket server; joiners connect over the same
Wi-Fi (or the host's hotspot) and receive the full serialized `Game` after every
change. Spectators render exactly the state they receive; only the host mutates.

Why this fits the codebase: `Game` is freezed with `toJson`/`fromJson`, the whole
game UI renders from `gameProvider`, and history persistence
(`GameRepository`/sembast) already round-trips games as JSON. A spectator is
"`gameProvider` fed from a socket, inputs disabled."

Rejected for v1: Nearby Connections / Wi-Fi Direct / BLE (platform-specific or
flaky, and the host's BLE is already used by the scale) and Firebase (cloud
dependency; would also break the privacy promise that data never leaves the
device). The transport abstraction in phase 2 keeps both open as later options.

## Phase 1 — Spectator-ready game screen (no networking yet)

- Introduce a session role (`host` — today's behavior — vs. `spectator`) exposed
  via a provider, and make the game screen honor it: no weight input, no
  "Neue Runde"/"Spiel beenden", no round delete; everything else (table, chips,
  dialogs' display parts) renders as usual.
- Cheap to verify in isolation (hardcode the role) and forces the input
  affordances through one switch instead of scattering checks later.

## Phase 2 — Sync protocol and transport

- Define a small message protocol, versioned from day one (the `Game` JSON schema
  will evolve between app versions):
  - `hello` (client → host): app/schema version, desired player name.
  - `welcome` / `reject` (host → client): assigned identity, current `Game`.
  - `state` (host → client): full `Game` JSON on every mutation. Full snapshots,
    not diffs — games are tiny (a few KB) and snapshots make reconnect trivial.
  - `finished` (host → client): final `Game`, signals "persist to your history".
- Abstraction: a `GameSession` interface (start/stop hosting, join, stream of
  snapshots, send) so the WebSocket implementation is swappable (Nearby/BLE/cloud
  later).
- Host side: `dart:io` `HttpServer` + WebSocket upgrade, broadcast on every
  `GameNotifier` state change. Keep the screen awake / use a foreground service
  so backgrounding doesn't kill the session mid-game.
- Client side: a provider that connects, deserializes `state` into the same
  `Game` model, and overrides/feeds `gameProvider` in spectator role.

## Phase 3 — Join flow UX

- Host: a "Spiel teilen" affordance (start screen options or the in-game menu)
  that starts the server and shows a QR code encoding `ip:port` (+ session id).
  Optional: mDNS advertisement (`bonsoir`) so joiners see nearby games without
  scanning.
- Joiner: "Spiel beitreten" on the start screen (the commented-out button in
  `start_screen.dart` anticipated this) → scan QR (or pick from discovered
  games) → claim one of the host's players or spectate unnamed.
  Prefill from `profileNameProvider`; if the name matches an existing player,
  offer that player directly.
- Handle the boring-but-real cases: rejoin after connection drop (re-`hello`,
  get a fresh snapshot), host quitting (show "Spiel beendet" state), version
  mismatch (friendly error).

## Phase 4 — History on every phone

- On `finished`, the joiner writes the final `Game` into their own sembast store
  via the existing `GameRepository`. Key by `meta.createdAt` as today — it's
  identical on all phones since it comes from the host's snapshot, which also
  gives natural dedupe on rejoin.
- Consider a small marker on the stored game (hosted vs. joined) for the history
  UI later; the model tolerates it as an additive field.

## Later / stretch

- Joiners enter their *own* weights (input goes client → host as a request, host
  stays authoritative and rebroadcasts). The phase-2 protocol should anticipate
  this with a client→host message type, even if v1 rejects it.
- Transports that need no shared network: Android Nearby Connections, or a
  cloud relay for remote spectators (revisit the privacy text if so).
- Live "who is connected" indicator on the host's screen.

## Platform gotchas to expect

- iOS: local-network permission prompt (`NSLocalNetworkUsageDescription`), and
  mDNS needs `NSBonjourServiceTypes`.
- Android 13+: `NEARBY_WIFI_DEVICES` if using mDNS discovery; QR-only join needs
  nothing special. Camera permission for scanning.
- Both: sockets die when the app is backgrounded long enough — design reconnect
  as a first-class path, not an error case.
