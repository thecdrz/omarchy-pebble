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
rg -q 'devToolsEnabled' Companion.qml
rg -q 'PEBBLE_DEV' Companion.qml
rg -q 'omarchy plugin remove io.github.thecdrz.pebble' README.md
rg -q 'omarchy plugin add https://github.com/thecdrz/omarchy-pebble.git --enable' README.md
rg -q 'Curious cursor' PRIVACY.md
rg -q 'capturePoseJson' Companion.qml
rg -q 'render-listing-preview.py' docs/MARKETPLACE.md

[[ -s docs/media/discord/pebble-panel.png ]]
[[ -s docs/media/pebble-on-bar.png ]] || {
  echo "FAIL: missing README hero docs/media/pebble-on-bar.png — see docs/MARKETPLACE.md" >&2
  exit 1
}
[[ -s preview.png ]] || {
  echo "FAIL: missing marketplace preview.png — see docs/MARKETPLACE.md" >&2
  exit 1
}

preview_geom="$(identify -format '%w %h' preview.png)"
# shellcheck disable=SC2086
set -- $preview_geom
preview_w="$1"
preview_h="$2"
if (( preview_w <= preview_h || preview_w < 1000 )); then
  echo "FAIL: preview.png must be landscape and at least 1000px wide (got ${preview_w}x${preview_h}). Do not use the portrait panel crop. See docs/MARKETPLACE.md." >&2
  exit 1
fi

echo "Release validation passed: manifest, assets, state contract, docs, and plugin structure."
