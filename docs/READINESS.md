# Release readiness

Pebble's intended claim is **the most polished ambient companion for Omarchy**.
The word “best” is earned by evidence, not feature count.

## Automated gates

- [x] Every animation frame has canvas, margin, silhouette, and scale checks.
- [x] Runtime-order animation reels can be regenerated for visual review.
- [x] Manifest and repository structure validate with Omarchy.
- [x] Persistent history and counters are bounded and sanitized.
- [x] No runtime network request, analytics, or global input monitoring.
- [x] Install, update, remove, backup, and reset behavior are documented.
- [ ] A 24-hour soak completes with no Pebble errors or shell restart.
- [ ] Idle CPU and memory stay within the release budget on that soak.

## Human gates

- [ ] Every reel passes same-scale transition review.
- [ ] Mixed-scale multi-monitor and ultrawide hardware pass the compatibility matrix.
- [ ] At least ten external testers complete three days of normal use.
- [ ] Median scores are at least 4/5 for delight, calmness, clarity, polish, and reliability.
- [ ] At least 80% of testers choose to leave Pebble enabled.
- [ ] No tester reports an unexplained repeated story within the same short session.

## Performance budget

- No shell restart or Pebble QML error during 24 hours.
- State file remains below 64 KiB.
- Resident-memory growth attributable to the shell remains below 20 MiB over the soak.
- Pebble introduces no continuously running helper process.

## Competitive scorecard

| Dimension | Pebble target |
|---|---|
| Ambient life | autonomous, calm, and legible from the bar |
| Reactivity | direct interaction plus privacy-safe time/workspace context |
| Long-term depth | collections, bounded history, bond, callbacks, rare stories |
| Control | Quiet/Normal/Lively, Snooze, Reduced Motion, immediate return home |
| Trust | local state, no network, no global input, documented data contract |
| Polish | stable silhouette, correct direction, smooth transitions, native theme fit |
| Reliability | validated package, migrations, soak budget, display matrix |

