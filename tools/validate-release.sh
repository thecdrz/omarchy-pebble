#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

tools/validate-assets.sh
omarchy plugin validate .
git diff --check

jq -e '
  .schemaVersion == 1 and
  .id == "io.github.thecdrz.pebble" and
  (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) and
  .kinds == ["panel"] and
  .entryPoints.panel == "Companion.qml"
' manifest.json >/dev/null

for required in README.md LICENSE CHANGELOG.md PRIVACY.md ASSET_LICENSES.md \
  docs/BETA_TESTING.md docs/COMPATIBILITY.md docs/READINESS.md; do
  [[ -s "$required" ]] || { echo "FAIL: missing release file $required" >&2; exit 1; }
done

rg -q 'version: 9' Companion.qml
rg -q 'reducedMotion' Companion.qml
rg -q 'recentEpisodes' Companion.qml
rg -q 'omarchy plugin remove io.github.thecdrz.pebble' README.md

echo "Release validation passed: manifest, assets, state contract, docs, and plugin structure."

