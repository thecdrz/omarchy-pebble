# Changelog

All notable changes to Pebble are documented here.

## [0.23.0] - 2026-08-23

### Added

- Hover presence: hand cursor and light stir / look reactions on Pebble (no on-bar tip text).
- **Curious cursor** on by default: bar-local pointer awareness. Quiet looks only; Normal mild scoots; Lively may nest-wake, chase, or flee.
- Single flat **PEBBLE** panel (story + Explore/home, snooze, Quiet/Normal/Lively, Curious, Calm motion) instead of a Journal → Care drill-down; popup sizes from content and anchors to the active sprite.
- Interactive finds: pebbles, leaves, and stars roll/bounce with velocity, edge rebound, grab fumbles, and occasional clock escapes that become chase episodes.
- Clock as a stage: shy / bold peeks, toy-chase behind the clock, and rare tumble-out slips.
- Lively-only circus stunts: **flame gate**, **parade leaf**, **sumo pebble**, **cannon**, **rain umbrella**, **fishing**, **sneeze**, and **zoomies** — see [`docs/ROADMAP.md`](docs/ROADMAP.md). Tightrope removed.
- **Dev triggers** for animation review via IPC (`preview` / `dev`) and optional `PEBBLE_DEV=1` panel section (hidden from the default PEBBLE UI).
- Fixed-contrast spectacle props (bar-lane cannon tube, flame gate, toy pebble) for dark and light bars.
- Authored bar-lane prop sprite pipeline: `tools/render-props.py` → `assets/props/*.png` → `PropArt.qml`.
- Deeper home moments weighted by bond and collection size, with occasional memory notes.
- Nest treasures: favorite pebble/leaf/star sits beside the sleeping nest; Quiet gets richer nest life (more z’s, dusk-from-nest, leaf sleep-cap).
- **Dusk watch** (17:00–19:00): a signature linger looking at the bar go gold (Normal+). Quiet watches from the nest.
- **Show-and-tell**: Normal+ outing that presents a collected find.
- Energy contract line in the PEBBLE panel: Quiet sleeps · Normal wanders · Lively shows off.
- IPC helpers for `care`, `activity`, and `curious`.
- Bar-local cursor helper `bin/pebble-cursor`, marketplace capture script `tools/capture-marketplace-screenshots.sh`, and real-bar screenshots under `docs/media/discord/`.

### Changed

- Cannon and flame gate stunts redesigned for the bar lane only — horizontal tube launch and a low gate with an open center (no props above/below the penguin).
- Spectacle staging stays inside an icon-safe open lane (far left/right tray zones avoided); fishing is a mid-lane puddle cast, not a bar-end cast.
- Story props are authored pixel sprites (`PropArt.qml`, `assets/props/`, `tools/render-props.py`) — classic side-view cannon, fishing rod, rain drops, parade flag/hat.
- Magic clock exit: bang vanish, wrong-side peek, reappear (Lively rare + Dev trigger).
- Sleeping silhouette reads larger/brighter on dark bars; mid belly-slide frames no longer balloon.
- Curious chase now follows Energy: Quiet looks only, Normal mild scoots, Lively nest-wake and chase. Defaults remain Normal + Curious on + Full motion.
- Go home / middle-click walk home when out instead of teleporting into the nest.
- Quiet nest life favors dreams and nest-rustle over stand-up idle beats; switching to Quiet sends him home.
- Removed tiny poke telegraph tips beside the sprite.

### Added (prior)

- Bounded eight-episode history, per-story counts, repeat-avoidance metrics, and a persistent relationship stage.
- Privacy-safe ambient reactions to time and occasional workspace changes.
- A Reduced Motion preference that suppresses dramatic autonomous antics and continuous ambient animation.
- Runtime-order animation reels, a 24-hour soak harness, and a consolidated release validator.
- Privacy, asset provenance, compatibility, beta-testing, and evidence-based release-readiness documents.
- A machine-readable companion roster and a production-readiness contract for future residents.
- Enlarged animated demo reels and a complete frame sheet for release review and the project page.
- A genuinely tucked four-frame sleep loop with subtle breathing.
- Visible penguin wake-and-look and preening moments while resting.
- Occasional multi-act outings that linger or continue to another destination.
- Nine autonomous micro-stories: edge inspection, firefly following, pebble polishing, leaf tossing, stargazing, collection sorting, stretching, runaway-pebble recovery, and listening behind the clock.
- Three quieter at-home moments: drifting dreams, nest tidying, and a night-only star dream.
- Memory-dependent stories that unlock naturally after Pebble has collected the relevant objects.
- Time-of-day behavior with rare stargazing and night dreams.
- Dedicated story cooldowns, eligibility rules, and no immediate story repeats.

### Changed

- Local state schema advanced to version 9 for relationship, accessibility, and bounded variety history.
- Normal autonomous cadence is now 30–75 seconds; Lively is 14–40 seconds.
- The `z` marker appears only during intermittent deep sleep.
- Locomotion now reverses the same silhouette sequence for braking, removing the apparent size jump into a front-facing idle.
- Asset validation now checks visible bounds and opaque silhouette mass across every penguin animation frame.
- Adopted the permanent public plugin ID `io.github.thecdrz.pebble`.
- Resting moments now arrive less mechanically and choose among several behaviors.
- Autonomous outings draw from a much larger weighted story pool while keeping the journal and controls unchanged.
- Local state schema advanced to version 8 to preserve the expanded cooldown history.

## [0.19.0] - 2026-08-22

Initial development preview.

### Added

- A fully animated penguin companion that explores the complete horizontal Omarchy bar.
- Purposeful adventures including discoveries, belly slides, slips, and hidden passages behind the center widgets.
- A compact local journal with current state, last adventure, lifetime memories, activity level, and one-hour snooze.
- Persistent, versioned local state with migration and malformed-state recovery.
- Focused-monitor tracking, hidden-bar handling, and support for top and bottom bars.
- Asset validation for frame dimensions, silhouette continuity, scale, and canvas margins.

### Refined

- Contextual journal controls replace redundant movement controls.
- Walking direction remains visually correct while approaching the center passage.
- Significant discoveries remain visible in Last Adventure instead of being immediately displaced by minor events.

### Compatibility

- Omarchy shell panel plugin (`schemaVersion: 1`).
- Horizontal top and bottom bars are supported.
- Vertical bars intentionally keep Pebble dormant.
