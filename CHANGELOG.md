# Changelog

All notable changes to Pebble are documented here.

## [Unreleased]

### Added

- Nine autonomous micro-stories: edge inspection, firefly following, pebble polishing, leaf tossing, stargazing, collection sorting, stretching, runaway-pebble recovery, and listening behind the clock.
- Three quieter at-home moments: drifting dreams, nest tidying, and a night-only star dream.
- Memory-dependent stories that unlock naturally after Pebble has collected the relevant objects.
- Time-of-day behavior with rare stargazing and night dreams.
- Dedicated story cooldowns, eligibility rules, and no immediate story repeats.

### Changed

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
