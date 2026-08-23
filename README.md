# Pebble

A quiet, expressive penguin who inhabits the Omarchy bar.

Pebble is the only companion currently shipped by this plugin. He is designed
to feel like a tiny animal sharing the bar rather than a widget displaying one:
curious, slightly clumsy, calm when ignored, and entirely local.

## What Pebble does

- Wanders the full horizontal bar, including behind the center clock widgets.
- Sleeps, stretches, preens, slips, belly-slides, and occasionally gets curious.
- Finds leaves, pebbles, and stars, then carries them home to remember.
- Builds a small local history of moments without repeating the same behavior constantly.
- Responds to clicks, right-click journal controls, and a one-hour snooze.
- Offers Quiet, Normal, Lively, and Reduced Motion modes.
- Adapts to the active monitor and pauses safely when the bar is hidden.
- Uses no network, analytics, global input monitoring, or cloud account.

## Interaction

- When Pebble is resting, left-click his small resting spot to wake him.
- When Pebble is walking on the bar, left-click his body for a small hop and head tilt.
- Poke again during or shortly after wake-up to queue a playful belly slide without interrupting the transition.
- Right-click Pebble or his resting spot to open the local journal.
- Middle-click to send Pebble home.
- Use **Snooze 1h** in the journal to pause autonomous outings; direct interaction wakes Pebble early.
- Use **Motion · Reduced** to suppress dramatic autonomous antics and continuous breathing animation.

## See Pebble in motion

These demos are rendered from the same runtime-ordered frames shipped in the
plugin. They are intentionally enlarged so the transitions and silhouette are
easy to inspect on GitHub.

| Waddle and return | Tucked sleep |
|---|---|
| ![Pebble locomotion](docs/media/pebble-locomotion.gif) | ![Pebble sleeping](docs/media/pebble-sleep.gif) |

| Belly slide | Slip and recover |
|---|---|
| ![Pebble belly slide](docs/media/pebble-belly-slide.gif) | ![Pebble slip and recover](docs/media/pebble-slip.gif) |

The complete frame sheet is available at
[`docs/media/pebble-animation-sheet.png`](docs/media/pebble-animation-sheet.png).
Regenerate the review reels with:

```sh
tools/render-animation-reels.sh /tmp/pebble-animation-reels
```

Journal state is stored at
`~/.local/state/omarchy/pebble/state.json`. It never leaves the machine.

The journal shows Pebble's current status, latest moment, collected objects,
outing totals, activity level, motion setting, and snooze control.

On a new installation, Pebble's first journal note explains that it explores the
entire bar, rests near the center widgets, and remembers discoveries. There is no
forced tutorial or automatic popup.

## Compatibility

- Omarchy shell with panel plugin support
- Horizontal bars at the top or bottom of the display
- One active Pebble instance on the currently focused monitor

Pebble intentionally stays dormant on vertical bars. Multi-monitor placement
uses Omarchy's per-window screen information; the current release has been
implemented against that API but physically exercised on a single-monitor
system. See [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) for the explicit
physical test matrix.

## Install

```sh
omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable
```

## Remove

```sh
omarchy plugin remove io.github.thecdrz.pebble
```

Removal intentionally leaves the private journal in
`~/.local/state/omarchy/pebble/state.json`, allowing a later reinstall
to resume. Delete that file separately only when you also want to reset Pebble.

Back up or reset state explicitly:

```sh
cp ~/.local/state/omarchy/pebble/state.json ~/pebble-state-backup.json
rm ~/.local/state/omarchy/pebble/state.json
```

Pebble's complete data contract is documented in [`PRIVACY.md`](PRIVACY.md),
and artwork provenance is recorded in [`ASSET_LICENSES.md`](ASSET_LICENSES.md).

## License

MIT
