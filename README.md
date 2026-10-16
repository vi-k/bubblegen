# bubblegen

A workbench for the next version of the
[bubble](https://pub.dev/packages/bubble) package: a chat bubble whose outline
has its own radius on every corner, and whose nip is an *inset* that can
replace any stretch of the perimeter, corners included.

The app has three tabs:

- **Generator** — one bubble, scaled up, with a panel for every setting: style,
  inset, nip, and the line settings of the earlier design. Draft mode shows the
  construction: the bounds, the corner sectors, the ends of the inset.
- **Bubble demo** — a chat feed drawn with the generator's settings, with an
  animation and a frame counter.
- **CustomBubble demo** — a placeholder.

This is a prototype from 2020, brought up to Flutter 3.27 without new features.
The nip is a sharp triangle; the rounded tip and three of the four corner
placements are unfinished. Known defects are listed in `docs/handoff.md`.

## Running

Flutter 3.27.0 or newer. The project uses 3.27.0 through
[fvm](https://fvm.app); `.fvmrc` is not committed, so pin it once:

```sh
fvm use 3.27.0
fvm flutter run -d macos     # or chrome, or a simulator
```

## Checks

```sh
fvm dart format --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
```

The tests are snapshots of the outline taken from the 2020 code: a change that
is not meant to alter the shape must leave them green.

## Layout

- `lib/custom_bubble.dart` — the outline: `CustomBubble`, its render object,
  insets and positions on the perimeter, draft mode.
- `lib/bubble.dart` — `Bubble`, a `CustomBubble` with a nip.
- `lib/geometry.dart` — points, lines, segments, circles and tangents.
- The other files are the app.

How the outline and the insets work is described in `docs/architecture.md`. The
documents in `docs/` and `AGENTS.md` are in Russian.
