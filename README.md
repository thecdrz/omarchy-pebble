# Pebble

A quiet, expressive penguin companion who inhabits the Omarchy bar.

Pebble is designed to feel like a tiny animal sharing the bar rather than a
widget displaying one: curious, slightly clumsy, calm when ignored, and entirely
local.

## Current behavior

- Defaults to a fully animated Linux-inspired penguin with a genuinely tucked four-frame sleep loop and six-frame waddle
- Adds authored start, stop, turn, settle, tucked-sleep, idle-personality, and belly-slide sequences
- Uses a small personality director: sleepy autonomous outings, curious invited outings, and playful repeated-poke reactions
- Prevents directed adventures from repeating back-to-back and applies per-episode cooldowns
- Adds nine autonomous micro-stories, including edge watching, firefly following, collection play, stretching, and listening behind the clock
- Unlocks pebble, leaf, and collection stories from Pebble's actual memories instead of exposing them immediately
- Reserves stargazing and star dreams for the evening while varying dreams and nest-tidying at home
- Wakes briefly to look around or preen while resting, with the sleep marker reserved for intermittent deep sleep
- Starts Normal outings every 30–75 seconds and lets some journeys linger for a second or third activity
- Gives rare stories their own six-to-twenty-minute cooldowns so the full repertoire unfolds gradually
- Makes Quiet, Normal, and Lively distinct in frequency, playfulness, and spontaneous antics
- Remembers rapid pokes without interrupting stand-up or stopping transitions
- Avoids repeating the same idle pose and varies the number and tempo of personality beats
- Measures the active screen and makes the full bar available for mood-dependent journeys
- Adapts long-trip pacing on ultrawide displays while keeping movement readable
- Chooses purposeful autonomous episodes instead of only pacing a small fixed lane
- Occasionally performs a sixteen-frame slip, embarrassed look-around, recovery, and innocent walk-away
- Crossfades and lightly bridges consecutive idle poses instead of hard-swapping sprites
- Resolves the live clock widget as a spatial landmark, including format-aware position and width
- Can disappear behind the live clock, fully emerge from its other side, and return through the same hidden passage
- Uses the clock and neighboring center widgets as a bidirectional passage during ordinary full-bar journeys
- Keeps the side-walking cycle active during clock approaches instead of substituting a forward-facing transition pose
- Turns discoveries into visible approach, inspection, pickup, carry-home, and storage stories
- Treats a third rapid poke as an annoyed retreat and suspicious clock-side peek
- Gives Pebble a compact local journal with a clear current state, last adventure, memories, and direct controls
- Keeps the journal glanceable by showing only outings, clock passages, and pokes as lifetime totals
- Protects significant discoveries in Last Adventure from being immediately replaced by minor antics
- Follows the focused monitor and filters live bar landmarks to that screen
- Pauses safely while the bar is hidden and resumes from home when it returns
- Supports top and bottom bars; stays dormant on vertical bars instead of opening an incorrect surface
- Sanitizes malformed counters, timestamps, cooldowns, and journal text while migrating older state
- Uses one contextual journal action: Explore while resting, then Go home while roaming
- Makes Explore choose a clock passage, discovery story, slip, or belly slide
- Rustles immediately when the den is clicked, before emerging
- Emerges when clicked, explores the full measured bar, investigates, and returns home
- Occasionally makes the same purposeful outing without demanding attention
- Sometimes discovers a leaf, pebble, or rare star and visibly carries it home
- Records outings, pokes, distance, and discoveries in a private local journal
- Offers Quiet, Normal, and Lively activity plus a one-hour Snooze / Wake now control
- Uses a six-frame walking cycle with compositor-driven movement
- Uses authored eight-frame emerge and return transitions
- Is click-through everywhere except its body or den
- Uses preloaded natural-color poses with a light live theme tint
- Exposes `pet`, `roam`, and `sleep` shell actions
- Does not monitor global keyboard or pointer input
- Opens only a compact, user-requested journal and never covers application windows during ordinary behavior

## Interaction

- Left-click the den to rustle it and invite the companion out.
- Left-click once while outside for a small hop and head tilt.
- Poke again during or shortly after wake-up to queue a playful belly slide without interrupting the transition.
- Right-click the den or companion to open the local journal.
- Middle-click to send the companion home.
- Use **Snooze 1h** in the journal to pause autonomous outings; direct interaction wakes Pebble early.

Journal state is stored at
`~/.local/state/omarchy/pebble/state.json`. It never leaves the machine.

## Companion identity

The public experience is centered on Pebble, the animated Linux-inspired
penguin. Earlier raccoon, gecko, and concept artwork remains in the lab as
internal development material, but is intentionally absent from Pebble's
journal until another character can match his animation and behavior depth.

Artwork remains isolated under `assets/species/<species>/` so future characters
can retain their own movement, home, and temperament without becoming simple
skins.

## Asset checks

Animation frames are validated for canvas size, margins, connected silhouettes,
and scale consistency. Run the checks after changing any sprite:

```sh
tools/validate-assets.sh
```

## Compatibility

- Omarchy shell with panel plugin support
- Horizontal bars at the top or bottom of the display
- One active Pebble instance on the currently focused monitor

Pebble intentionally stays dormant on vertical bars. Multi-monitor placement
uses Omarchy's per-window screen information; the current release has been
implemented against that API but physically exercised on a single-monitor
system.

## Release notes

This repository currently tracks the `0.21.0` development preview. No stable
release has been published yet. See [`CHANGELOG.md`](CHANGELOG.md) for the
development history.

## Install

```sh
omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable
```

## Install for development

```sh
install -d ~/.config/omarchy/plugins/io.github.thecdrz.pebble
cp -a Companion.qml manifest.json README.md LICENSE assets \
  ~/.config/omarchy/plugins/io.github.thecdrz.pebble/
omarchy plugin validate ~/.config/omarchy/plugins/io.github.thecdrz.pebble
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.thecdrz.pebble
```

Repeat the explicit `cp` and validation steps to update a development install.
This avoids copying repository metadata into the live plugin directory.

## Try the actions

```sh
omarchy-shell io.github.thecdrz.pebble pet
omarchy-shell io.github.thecdrz.pebble roam
omarchy-shell io.github.thecdrz.pebble explore
omarchy-shell io.github.thecdrz.pebble sleep
omarchy-shell io.github.thecdrz.pebble clock
omarchy-shell io.github.thecdrz.pebble retreat
omarchy-shell io.github.thecdrz.pebble discover
omarchy-shell io.github.thecdrz.pebble journal
```

## Remove

```sh
omarchy plugin remove io.github.thecdrz.pebble
```

Removal intentionally leaves the private journal in
`~/.local/state/omarchy/pebble/state.json`, allowing a later reinstall
to resume. Delete that file separately only when you also want to reset Pebble.

## License

MIT
