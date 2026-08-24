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

## Screenshots (0.23 refresh — captured)

Regenerate on your bar with:

```sh
tools/capture-marketplace-screenshots.sh
tools/validate-release.sh
```

| File | Shows | Status |
|---|---|---|
| `01-pebble-at-home.png` | Quiet sleep at the nest (`z` visible) | Refreshed Aug 2026 |
| `02-pebble-slip.png` | Mid-slip with dust puff | Refreshed Aug 2026 |
| `03-pebble-journal.png` | Flat **PEBBLE** panel: Quiet/Normal/Lively, Curious, energy contract | Refreshed Aug 2026 |

The filename `03-pebble-journal.png` is kept for validator/README compatibility.

**Optional extras** for a richer marketplace listing:

- Lively stunt in the open lane (cannon, flame gate, or fishing)
- Toy find or clock peek
- Quiet nest moment (dream or leaf-hat)

### Capture notes

- Script uses Quickshell IPC + `grim`; crop constants assume a wide top bar (~5120px). Adjust `tools/capture-marketplace-screenshots.sh` if your layout differs.
- Panel shot opens the panel while Pebble is awake at the nest so all controls are visible.
- After capture, run `tools/validate-release.sh`.

## Pre-submit checklist

- [x] `tools/validate-release.sh` passes
- [x] `manifest.json` version and description match 0.23
- [x] `03-pebble-journal.png` shows the current PEBBLE panel
- [x] GitHub release `v0.23.0` tagged
- [ ] **Maintainer green-light** for Omarchy marketplace publish
- [ ] Install smoke-test from `omarchy plugin add … --enable` on a clean profile (optional)

## After marketplace publish

- Tick **Marketplace listing / screenshot refresh** in `docs/ROADMAP.md` Track B
- Note publish date in this file
