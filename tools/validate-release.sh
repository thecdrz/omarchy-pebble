#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

python3 tools/render-props.py >/dev/null
tools/validate-assets.sh
tools/validate-roster.sh
omarchy plugin validate .
git diff --check

jq -e '
  .schemaVersion == 1 and
  .id == "io.github.thecdrz.pebble" and
  (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) and
  .kinds == ["panel"] and
  .entryPoints.panel == "Companion.qml"
' manifest.json >/dev/null

for required in README.md LICENSE CHANGELOG.md PRIVACY.md ASSET_LICENSES.md companions.json \
  docs/BETA_TESTING.md docs/COMPATIBILITY.md docs/READINESS.md docs/ROSTER.md; do
  [[ -s "$required" ]] || { echo "FAIL: missing release file $required" >&2; exit 1; }
done

rg -q 'version: 9' Companion.qml
rg -q 'reducedMotion' Companion.qml
rg -q 'curiousCursor' Companion.qml
rg -q 'recentEpisodes' Companion.qml
rg -q 'stateMaxBytes: 65536' Companion.qml
rg -q 'iflag=nofollow,nonblock' Companion.qml
rg -q 'timeout --foreground 1s dd' Companion.qml
! rg -q 'FileView' Companion.qml
rg -q 'mktemp --tmpdir=' Companion.qml
rg -q 'mv -fT --' Companion.qml
rg -q 'omarchy plugin remove io.github.thecdrz.pebble' README.md
rg -q 'Curious cursor' PRIVACY.md

[[ -s docs/media/discord/01-pebble-at-home.png ]]
[[ -s docs/media/discord/02-pebble-slip.png ]]
[[ -s docs/media/discord/03-pebble-journal.png ]]
echo "Release validation passed: manifest, assets, state contract, docs, and plugin structure."
