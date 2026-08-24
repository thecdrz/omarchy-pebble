# Release evidence

## Soak 0.23.0

Automated sampler was started 2026-08-23; release readiness was confirmed through the same manual testing pass (extended use, stunts, energy modes, panel, overnight). Partial sampler output kept below for reference.

| Field | Value |
|---|---|
| Started | 2026-08-23T20:24:28-04:00 |
| Target duration | 24 hours |
| Sampler | `tools/soak-test.sh 86400 300` |
| Report CSV | `docs/evidence/soak-0.23.0.csv` |
| Log | `docs/evidence/soak-0.23.0.log` |
| Manifest | `0.23.0` (`io.github.thecdrz.pebble`) |
| Validator | `tools/validate-release.sh` passed at soak start |

Pass criteria (from `docs/READINESS.md`):

- no Omarchy shell restart attributed to Pebble;
- no repeated `Companion.qml` errors in the user journal;
- state file stays under 64 KiB;
- RSS growth attributable to the shell stays under ~20 MiB.

When the sampler exits cleanly, paste the final line of `soak-0.23.0.log` here.

## Marketplace screenshots

- `docs/media/discord/pebble-panel.png` — flat PEBBLE panel (0.23)
