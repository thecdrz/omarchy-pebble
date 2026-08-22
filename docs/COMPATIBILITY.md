# Compatibility matrix

The checkboxes distinguish automated coverage from physical verification. A stable
release requires every physical row to be exercised on real hardware.

| Environment | Automated | Physically verified | Result |
|---|---:|---:|---|
| Top horizontal bar | yes | yes | passing |
| Bottom horizontal bar | yes | yes | passing |
| Vertical bar | yes | yes | intentionally dormant |
| Bar hide and restore | yes | yes | passing |
| Fullscreen application | structural | yes | passing |
| Single monitor, 1× scale | yes | yes | passing |
| Two monitors, same scale | structural | no | pending |
| Two monitors, mixed scale | structural | no | pending |
| Fractional display scale | asset bounds | no | pending |
| Ultrawide display | geometry | no | pending |
| Bar heights 24–48 px | asset bounds | no | pending |

Physical checks must cover focused-monitor handoff, click masks, journal anchoring,
clock-passage geometry, fullscreen stacking, and absence of apparent sprite-scale
changes. Record hardware, scale, bar position, and result in the beta report.

