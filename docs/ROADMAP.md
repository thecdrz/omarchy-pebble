# Roadmap

Pebble is past feature parity with the main Omarchy bar-pet competitor on the
dimensions that define this product: authored outings, clock theatre, toy
physics, poke chains, journal/bond, and Quiet / Normal / Lively control.

Navbar Cat still leads on OS ambient reactions (music bob, charging nap,
notification watch, theme startle, off-bar pounce). Copying that stack would
make a weaker cat, not a stronger penguin. Those reactions stay a **later,
optional** track.

## Current hold (0.23)

Feature work for 0.23 is committed. **Push and publish** when ready.

## Track A — Lively spectacle (active)

Ship circus-of-the-bar stunts that only a penguin would attempt. Gate hard stunts
to **Lively** and never to Reduced / Calm motion. Quiet stays a sleeping animal.

| Stunt | Notes | Status |
|---|---|---|
| **Flame gate** | Bar-level posts + side flames; open center gap; sprint through; land or slip | In tree |
| **Fishing** | Mid-lane puddle cast (never tray-icon ends); line + bobber; optional star catch | In tree |
| **Parade / hat leaf** | Leaf hat on head + pennant flag; hat resigns mid-march (needs leaf) | In tree |
| **Sumo pebble** | Pebble shoulder-check; sometimes the pebble wins → slip | In tree |
| **Rain umbrella** | Open leaf umbrella on head; theoretical rain dots (needs leaf) | In tree |
| **Cannon** | Classic side-view barrel + round wheels + dark muzzle | In tree |
| **Sneeze** | Wind-up sneeze that relocates him | In tree |
| **Zoomies** | Rapid back-and-forth scoots, then proud stop | In tree |
| Magic clock exit | Bang vanish; wrong-side peek; full emerge (Lively rare + Dev) | In tree |
| Dusk watch | 17:00–19:00 linger; Quiet watches from the nest | In tree |
| Nest treasures | Favorite find sleeps beside him; leaf cap / show-and-tell | In tree |
| ~~Boss clock~~ | Cut — charge read as a zig-zag through the clock cluster | Cut |
| Wall kick | Parked until placement-aware free space exists | Parked |
| Icon-end staging | Far left/right tray zones are off-limits; use open lane inset | Rule |
| Prop art pass | Sprites via `PropArt.qml` + `render-props.py`; fishing rod + rain drops | In tree |
| ~~Tightrope~~ | Removed — did not read on the bar | Cut |

Use IPC `preview` / `dev` (or `PEBBLE_DEV=1` for the panel chips) to fire any stunt on demand while developing.

## Track B — Harden after publish

- Curious chase now respects Quiet / Normal / Lively (Quiet stays in the nest)
- Marketplace listing / screenshot refresh for 0.23
- Close soak + external beta gates in `docs/READINESS.md`

## Track C — Second resident

Pick one roster candidate by taste (cat / songbird / frog / raccoon / gecko) and
finish a full walk/sleep/play set before any picker UI. See `docs/ROSTER.md`.

## Track D — OS ambient (optional)

Only if soak feedback asks for “plugged into the machine”: music bob, charging
nap, or notification glance — penguin-native, not oneko clones.

## Non-goals for now

- Vertical-bar locomotion
- Off-bar desktop drawing / pounce overlays
- Two full-time roaming companions
- Wall-end combat without clear free space
