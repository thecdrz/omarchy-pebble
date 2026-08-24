# Omarchy marketplace listing — 0.23.0

Use this when submitting or updating Pebble on the Omarchy plugin marketplace.

**Do not publish until you explicitly green-light it.** This doc and the capture script only prepare assets and copy.

## Listing copy (source of truth)

| Field | Source |
|---|---|
| Name | `manifest.json` → `Pebble` |
| Version | `manifest.json` → `0.23.0` |
| ID | `io.github.thecdrz.pebble` |
| Short description | `manifest.json` → `description` |
| Long description | `README.md` → **What Pebble does** + **Interaction** (trim if the form has a limit) |
| Install | `omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable` |
| Changelog | `CHANGELOG.md` → `[0.23.0]` section |

## Screenshots

| File | Shows | Status |
|---|---|---|
| `docs/media/discord/pebble-panel.png` | Flat **PEBBLE** panel: Quiet/Normal/Lively, Curious, energy contract | Maintainer capture (Aug 2026) |

**Optional extras** for a richer marketplace listing:

- Quiet nest sleep on the real bar
- Mid-slip or belly-slide
- Lively stunt in the open lane (cannon, flame gate, or fishing)

Prefer a clean manual crop over the automated helper — `tools/capture-marketplace-screenshots.sh` is layout-sensitive on ultrawide bars.

## Pre-submit checklist

- [x] `tools/validate-release.sh` passes
- [x] `manifest.json` version and description match 0.23
- [x] `pebble-panel.png` shows the current PEBBLE panel
- [x] GitHub release `v0.23.0` tagged
- [ ] **Maintainer green-light** for Omarchy marketplace publish
- [ ] Install smoke-test from `omarchy plugin add … --enable` on a clean profile (optional)

## After marketplace publish

- Tick **Marketplace listing / screenshot refresh** in `docs/ROADMAP.md` Track B
- Note publish date in this file
