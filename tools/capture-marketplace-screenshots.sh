#!/usr/bin/env bash
set -euo pipefail

# Optional helper to capture the PEBBLE panel via Quickshell IPC + grim.
# Prefer a clean manual crop into docs/media/discord/pebble-panel.png —
# automated crops are brittle on ultrawide / busy desktops.
# Does NOT publish to the Omarchy marketplace.

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out="$root_dir/docs/media/discord/pebble-panel.png"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

shell_path="${OMARCHY_SHELL_PATH:-/usr/share/omarchy/shell}"
ipc=(quickshell ipc -p "$shell_path" call io.github.thecdrz.pebble)

pgrep -f '^quickshell -n -p '"$shell_path"'$' >/dev/null || {
  echo "FAIL: omarchy-shell is not running" >&2
  exit 1
}

command -v tesseract >/dev/null || {
  echo "FAIL: tesseract required to locate the panel" >&2
  exit 1
}

echo "Opening PEBBLE panel…"
"${ipc[@]}" sleep
sleep 0.8
"${ipc[@]}" activity normal
"${ipc[@]}" journal
sleep 1.3

monitor_w="$(hyprctl monitors -j | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["width"])')"
grim -g "0,0 ${monitor_w}x700" "$tmp_dir/full-top.png"

qx="$(tesseract "$tmp_dir/full-top.png" stdout tsv 2>/dev/null | awk -F'\t' 'NR>1 && $12=="Quiet" && $7>400 {print $7; exit}')"
[[ -n "$qx" ]] || { echo "FAIL: could not locate Quiet button in panel" >&2; exit 1; }

left=$((qx - 28))
magick "$tmp_dir/full-top.png" -crop "372x455+${left}+28" +repage \
  -bordercolor '#1a1b26' -border 12 \
  "$out"

"${ipc[@]}" journal >/dev/null 2>&1 || true

identify "$out"
echo "Wrote $out — review before committing. Prefer a manual crop if this looks wrong."
