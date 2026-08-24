#!/usr/bin/env bash
set -euo pipefail

# Capture real-bar marketplace stills via Quickshell IPC + grim.
# Requires: Omarchy shell running, Pebble enabled, grim, ImageMagick.
# Does NOT publish to the Omarchy marketplace — only writes docs/media/discord/*.png

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out_dir="$root_dir/docs/media/discord"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

shell_path="${OMARCHY_SHELL_PATH:-/usr/share/omarchy/shell}"
ipc=(quickshell ipc -p "$shell_path" call io.github.thecdrz.pebble)

pgrep -f '^quickshell -n -p '"$shell_path"'$' >/dev/null || {
  echo "FAIL: omarchy-shell is not running" >&2
  exit 1
}

monitor="$(hyprctl monitors -j | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["width"])')"
bar_h=34

# Crop hints tuned for a ~5120px-wide top bar; adjust if your bar layout differs.
home_x=2260
home_w=980
slip_x=900
slip_w=1200
panel_x=2280
panel_w=560
panel_h=600
panel_crop='350x418+205+32'

echo "Capturing 01 — Quiet at the nest…"
"${ipc[@]}" activity quiet
"${ipc[@]}" sleep
sleep 1.5
grim -g "${home_x},0 ${home_w}x${bar_h}" "$tmp_dir/01-raw.png"
magick "$tmp_dir/01-raw.png" -background '#1a1b26' -gravity north -extent "${home_w}x${bar_h}" \
  "$out_dir/01-pebble-at-home.png"

echo "Capturing 02 — Slip mid-bar…"
"${ipc[@]}" dev slip &
sleep 0.42
grim -g "0,0 ${monitor}x${bar_h}" "$tmp_dir/02-full.png"
wait
magick "$tmp_dir/02-full.png" -crop "${slip_w}x${bar_h}+${slip_x}+0" +repage \
  -background '#1a1b26' -gravity north -extent "${slip_w}x${bar_h}" \
  "$out_dir/02-pebble-slip.png"

echo "Capturing 03 — PEBBLE panel…"
"${ipc[@]}" wake
sleep 0.4
"${ipc[@]}" activity normal
"${ipc[@]}" journal
sleep 1.0
grim -g "${panel_x},0 ${panel_w}x${panel_h}" "$tmp_dir/03-raw.png"
magick "$tmp_dir/03-raw.png" -crop "$panel_crop" +repage \
  -background '#1a1b26' -bordercolor '#2a2b36' -border 12 \
  "$out_dir/03-pebble-journal.png"

"${ipc[@]}" journal >/dev/null 2>&1 || true

echo "Wrote:"
identify "$out_dir"/*.png
echo "Run tools/validate-release.sh to verify."
