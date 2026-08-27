# Omarchy marketplace listing — 0.23.0

Use this when submitting or updating Pebble on the [Omarchy plugin marketplace](https://omarchyplugins.com/).

Read the upstream guides first — they are authoritative:

- [SUBMISSION.md](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/blob/main/SUBMISSION.md) — **new** listings
- [VERIFICATION.md](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/blob/main/VERIFICATION.md) — **updates** and snapshot verification

## New listing vs update

| Situation | Workflow | Issue form |
|---|---|---|
| First time in the catalog | Submit | [submit-plugin.yml](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml) |
| **Existing listing** (Pebble) | Verify & publish newer commit | [verify-plugin.yml](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/new?template=verify-plugin.yml) |

**Do not** open a submit issue for an update. Validation expects exact `###` headings in a fixed order — copy from `SUBMISSION.md` or use `tools/marketplace-update.sh`.

## Pebble listing

| Field | Value |
|---|---|
| Plugin ID | `io.github.thecdrz.pebble` |
| Repository | `https://github.com/thecdrz/omarchy-pebble` |
| Category | Widgets (set at listing time) |
| Tags | `bar`, `quickshell`, `workspaces` — `workspaces` is a mismatch; ask a maintainer to drop it on the next verify |
| Preview | Root `preview.png` |
| Version | `manifest.json` |

**Last published verify:** [#2016](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/2016) at `7714a1d` (2026-08-24). The live card is still the 345×397 panel crop. A new still needs a fresh verify issue so the marketplace regenerates card and detail images.

### Helper (updates only)

```sh
tools/validate-release.sh
omarchy plugin validate .
tools/marketplace-update.sh   # prints body; prompts before creating issue
```

## Listing copy (source of truth)

| Field | Source |
|---|---|
| Name | `manifest.json` → `Pebble` |
| Version | `manifest.json` |
| ID | `io.github.thecdrz.pebble` |
| Short description | `manifest.json` → `description` |
| Long description | `README.md` (hero, install, what he does) |
| Install | `omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable` |
| Changelog | `CHANGELOG.md` |

## Capture the marketplace hero

The marketplace copies **only** root `preview.png`. Compose it from the shipped
animation frames — eight poses, actual-size strip, no desktop screenshot.

```sh
tools/render-listing-preview.py
```

Writes both files below. `tools/capture-marketplace-screenshots.sh` does the same thing.

| File | Used for |
|---|---|
| `preview.png` (repo root) | Marketplace card and detail |
| `docs/media/pebble-on-bar.png` | README hero (same image) |

Keep `docs/media/discord/pebble-panel.png` for the README **Care** section only.

A live bar photo is optional (`tools/capture-marketplace-screenshots.sh photo`) and is not the listing tile.

### Checklist before you commit the stills

- [ ] `preview.png` is the eight-pose card (landscape, width ≥ 1200)
- [ ] `tools/validate-release.sh` passes
- [ ] File a **verify** issue for the new commit after push; the old 345×397 webps stay until that publishes

Print this recipe anytime with `tools/capture-marketplace-screenshots.sh`.

## Pre-flight (before any marketplace issue)

- [ ] `tools/validate-release.sh` passes
- [ ] `omarchy plugin validate .` passes
- [ ] `manifest.json` version and description match the release
- [ ] `preview.png` is the eight-pose listing card, not a panel crop or desktop screenshot
- [ ] README has install **and** remove instructions
- [ ] Correct issue type: **verify** for updates, **submit** only for new listings
- [ ] Issue body uses exact `###` headings — no reordering, no `##` shortcuts

## After marketplace publish

- Tick the listing-card item in `docs/ROADMAP.md` Track B
- Note publish date and verify-issue URL here
