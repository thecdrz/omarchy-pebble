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

## Pebble update (0.23.0)

| Field | Value |
|---|---|
| Plugin ID | `io.github.thecdrz.pebble` |
| Repository | `https://github.com/thecdrz/omarchy-pebble` |
| Preview | `preview.png` at repository root |
| Version | `0.23.0` in `manifest.json` |

**Verify issue:** [#2016](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/2016) (replaces incorrectly formatted [#2015](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/2015)).

After validation passes, a marketplace maintainer applies `approved-and-verified`.

### Helper (updates only)

```sh
tools/validate-release.sh
omarchy plugin validate .
chmod +x tools/marketplace-update.sh
tools/marketplace-update.sh   # prints body; prompts before creating issue
```

## Listing copy (source of truth)

| Field | Source |
|---|---|
| Name | `manifest.json` → `Pebble` |
| Version | `manifest.json` → `0.23.0` |
| ID | `io.github.thecdrz.pebble` |
| Short description | `manifest.json` → `description` |
| Long description | `README.md` → **What Pebble does** + **Interaction** |
| Install | `omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable` |
| Changelog | `CHANGELOG.md` → `[0.23.0]` |

## Preview image

- Root `preview.png` — marketplace card/detail thumbnail (optional but recommended)
- `docs/media/discord/pebble-panel.png` — README / human docs

## Pre-flight (before any marketplace issue)

- [ ] `tools/validate-release.sh` passes
- [ ] `omarchy plugin validate .` passes
- [ ] `manifest.json` version and description match the release
- [ ] `preview.png` at repo root (if you want a real image, not a letter tile)
- [ ] README has install **and** remove instructions
- [ ] Correct issue type: **verify** for updates, **submit** only for new listings
- [ ] Issue body uses exact `###` headings — no reordering, no `##` shortcuts

## After marketplace publish

- Tick **Marketplace listing / screenshot refresh** in `docs/ROADMAP.md` Track B
- Note publish date and verify-issue URL here
