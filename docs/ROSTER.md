# Companion roster

Pebble is the first resident, not the permanent identity of every companion.
The product should support a small, deeply authored roster while keeping one
primary inhabitant on the bar at a time.

## Product model

- **One resident:** the selected companion owns the home position, journal, and
  ordinary outings. This keeps the bar calm and preserves clear interaction.
- **A real roster:** changing resident changes animation, temperament, routines,
  stories, collection preferences, and relationship—not merely the sprite.
- **Rare company:** cameos and authored two-character moments may arrive after two
  residents independently meet the quality bar. Two full-time roaming companions
  are intentionally out of scope until collision, click-mask, and clutter tests pass.
- **No disposable pets:** changing resident preserves the former companion's bond
  and memories for a later return.

## State direction

Global settings remain shared:

- Activity level
- Reduced Motion
- Snooze deadline
- Privacy behavior

Identity state becomes per companion:

- first meeting and days together;
- outings, pokes, discoveries, and collection;
- recent episodes, cooldowns, and preferences;
- last adventure and relationship stage.

Schema 9 remains authoritative while Pebble is the only selectable resident. The
multi-resident migration will move existing identity fields into
`companions.penguin` without changing their values, then add `residentId` and a
shared `settings` object.

## Readiness contract

A companion becomes `ready` only after it has:

1. A coherent idle and genuinely distinct resting pose.
2. At least a six-frame directional locomotion cycle.
3. Authored emerge/start/stop/return transitions with a stable baseline and scale.
4. At least four idle-personality poses and one signature action.
5. At least three home routines and five species-specific outing stories.
6. Its own temperament weights and interaction reactions.
7. Per-frame asset validation and runtime-order animation reels.
8. Reduced Motion behavior.
9. Three-day external testing with no unresolved visual or interaction defect.
10. Documented asset provenance.

## Current candidates

| Candidate | Current material | Gap before selection |
|---|---|---|
| Pebble, penguin | Complete production animation and behavior | Ready |
| Cat | Strong resting concept | Full animation and personality system |
| Songbird | Strong perch concept | Flight/hop language, home, and stories |
| Frog | Strong resting concept | Hop transitions, sleep, and stories |
| Raccoon | Walk and wake prototypes | Coherent rest, transitions, signature actions, stories |
| Gecko | Walk and wake prototypes | Coherent rest, transitions, signature actions, stories |

The next resident should follow the owner's genuine preference, not whichever
prototype is cheapest to finish.

### Species-specific behavior anchors

Pebble's waddle, belly slide, and pebble-collecting identity remain the sole
production direction for this release.
