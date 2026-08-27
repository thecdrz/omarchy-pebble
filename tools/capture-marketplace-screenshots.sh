#!/usr/bin/env bash
set -euo pipefail

# Listing stills. Default: compose preview.png from penguin frames.
# Does NOT publish to the marketplace. See docs/MARKETPLACE.md.

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
shell_path="${OMARCHY_SHELL_PATH:-/usr/share/omarchy/shell}"
ipc=(quickshell ipc -p "$shell_path" call io.github.thecdrz.pebble)
mode="${1:-preview}"
hero="$root_dir/docs/media/pebble-on-bar.png"
preview="$root_dir/preview.png"

require_shell() {
  pgrep -f '^quickshell -n -p '"$shell_path"'$' >/dev/null || {
    echo "FAIL: omarchy-shell is not running" >&2
    exit 1
  }
}

use_live_hyprland() {
  command -v hyprctl >/dev/null || { echo "FAIL: hyprctl not found" >&2; exit 1; }
  if hyprctl monitors -j >/dev/null 2>&1; then
    return
  fi
  local latest
  latest="$(ls -1dt "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/hypr/*/ 2>/dev/null | head -1 || true)"
  [[ -n "$latest" ]] || { echo "FAIL: no Hyprland instance" >&2; exit 1; }
  export HYPRLAND_INSTANCE_SIGNATURE
  HYPRLAND_INSTANCE_SIGNATURE="$(basename "$latest")"
  hyprctl monitors -j >/dev/null 2>&1 || {
    echo "FAIL: could not talk to Hyprland" >&2
    exit 1
  }
}

print_recipe() {
  cat <<'EOF'
Marketplace card (eight poses, no desktop capture):

  tools/render-listing-preview.py
  tools/capture-marketplace-screenshots.sh          # same thing
  tools/capture-marketplace-screenshots.sh preview

Optional:
  tools/capture-marketplace-screenshots.sh photo    # grim the live bar
  tools/capture-marketplace-screenshots.sh panel    # Care still only
  tools/capture-marketplace-screenshots.sh manual   # slurp a region
EOF
}

render_preview() {
  python3 "$root_dir/tools/render-listing-preview.py"
}

ipc_try() {
  "${ipc[@]}" "$@" >/dev/null 2>&1 || true
}

pose_json() {
  "${ipc[@]}" pose 2>/dev/null || true
}

compute_geom() {
  POSE_JSON="${1:-}" hyprctl monitors -j | python3 -c '
import json, os, sys
mons = json.load(sys.stdin)
pose = {}
raw = os.environ.get("POSE_JSON") or ""
if raw.strip().startswith("{"):
    try:
        pose = json.loads(raw)
    except json.JSONDecodeError:
        pose = {}

wanted = str(pose.get("screen") or "")
mon = next((m for m in mons if wanted and str(m.get("name") or "") == wanted), None)
if mon is None:
    mon = next((m for m in mons if m.get("focused")), mons[0])

mx, my = int(mon["x"]), int(mon["y"])
mw, mh = int(mon["width"]), int(mon["height"])
bar_pos = str(pose.get("barPosition") or "top")
bar_size = int(pose.get("barSize") or 30)
pebble = pose.get("pebble") if pose.get("ok") else None

frame_w, frame_h = 960, 540
if mw < frame_w or mh < frame_h:
    if mw / mh < 16 / 9:
        frame_w, frame_h = mw, int(mw * 9 / 16)
    else:
        frame_h, frame_w = mh, int(mh * 16 / 9)

strip_h = min(mh, max(bar_size + 8, bar_size))
strip_w = min(mw, frame_w)

if pebble:
    cx = mx + int(pebble["x"]) + int(pebble["width"]) / 2
else:
    # Nest sits just to the right of the centered Omarchy clock.
    cx = mx + mw / 2 + 240

sx = int(round(cx - strip_w / 2))
sx = max(mx, min(mx + mw - strip_w, sx))
if bar_pos == "bottom":
    sy = my + mh - strip_h
else:
    sy = my

print(f"{sx},{sy} {strip_w}x{strip_h}")
print(f"{frame_w}x{frame_h}")
print(bar_pos)
'
}

pad_to_canvas() {
  local strip="$1" out="$2" canvas="$3" bar_pos="$4"
  local bg
  # Sample the bar itself, not window chrome that may sit under it.
  bg="$(magick "$strip" -crop "1x1+20+2" +repage -format '%[hex:u.p{0,0}]' info:)"
  local gravity="North"
  [[ "$bar_pos" == "bottom" ]] && gravity="South"
  magick "$strip" -background "#${bg}" -gravity "$gravity" -extent "$canvas" \
    -filter point -resize 200% "$out"
}

capture_bar() {
  require_shell
  command -v grim >/dev/null || { echo "FAIL: grim not found" >&2; exit 1; }
  command -v magick >/dev/null || { echo "FAIL: magick not found" >&2; exit 1; }
  use_live_hyprland

  echo "Posing Pebble on the bar…"
  ipc_try closePanel
  ipc_try sleep
  sleep 1.4

  local pose geom strip_g canvas bar_pos tmp
  pose="$(pose_json)"
  geom="$(compute_geom "$pose")"
  strip_g="$(printf '%s\n' "$geom" | sed -n '1p')"
  canvas="$(printf '%s\n' "$geom" | sed -n '2p')"
  bar_pos="$(printf '%s\n' "$geom" | sed -n '3p')"

  tmp="$(mktemp --suffix=.png)"
  trap 'rm -f "$tmp"' RETURN
  echo "Capturing $strip_g → $canvas…"
  grim -g "$strip_g" "$tmp"
  mkdir -p "$(dirname "$hero")"
  pad_to_canvas "$tmp" "$hero" "$canvas" "$bar_pos"
  cp -f -- "$hero" "$preview"
  identify "$hero"
  echo "Wrote $hero and $preview"
}

capture_manual() {
  require_shell
  command -v grim >/dev/null || { echo "FAIL: grim not found" >&2; exit 1; }
  [[ -t 0 ]] || { echo "FAIL: manual capture needs a terminal" >&2; exit 1; }
  command -v slurp >/dev/null || { echo "FAIL: slurp not found" >&2; exit 1; }
  echo "Draw a landscape rectangle with the bar at the top and Pebble inside."
  grim -g "$(slurp -d)" "$hero"
  cp -f -- "$hero" "$preview"
  identify "$hero"
}

capture_panel() {
  require_shell
  use_live_hyprland
  command -v tesseract >/dev/null || {
    echo "FAIL: tesseract required to locate the panel" >&2
    exit 1
  }
  command -v grim >/dev/null || { echo "FAIL: grim not found" >&2; exit 1; }
  command -v magick >/dev/null || { echo "FAIL: magick not found" >&2; exit 1; }

  local out tmp_dir monitor_w qx left
  out="$root_dir/docs/media/discord/pebble-panel.png"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  echo "Opening PEBBLE panel…"
  ipc_try sleep
  sleep 0.8
  ipc_try activity normal
  "${ipc[@]}" journal
  sleep 1.3

  monitor_w="$(hyprctl monitors -j | python3 -c 'import json,sys
mons=json.load(sys.stdin)
m=next((x for x in mons if x.get("focused")), mons[0])
print(int(m["width"]))')"
  grim -g "0,0 ${monitor_w}x700" "$tmp_dir/full-top.png"

  qx="$(tesseract "$tmp_dir/full-top.png" stdout tsv 2>/dev/null | awk -F'\t' 'NR>1 && $12=="Quiet" && $7>400 {print $7; exit}')"
  [[ -n "$qx" ]] || { echo "FAIL: could not locate Quiet button in panel" >&2; exit 1; }

  left=$((qx - 28))
  magick "$tmp_dir/full-top.png" -crop "372x455+${left}+28" +repage \
    -bordercolor '#1a1b26' -border 12 \
    "$out"

  ipc_try journal
  identify "$out"
  echo "Wrote $out — Care still only, not preview.png."
}

case "$mode" in
  preview|bar) render_preview ;;
  photo) capture_bar ;;
  panel) capture_panel ;;
  manual) capture_manual ;;
  help|-h|--help) print_recipe ;;
  *)
    echo "Usage: $0 [preview|photo|panel|manual|help]" >&2
    exit 1
    ;;
esac
