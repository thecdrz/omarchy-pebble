#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="${1:-/tmp/pebble-animation-reels}"
penguin="$root_dir/assets/species/penguin"

mkdir -p "$output_dir"
"$root_dir/tools/validate-assets.sh"

render_reel() {
  local name="$1" delay="$2"
  shift 2
  local args=()
  for frame in "$@"; do args+=(-delay "$delay" "$frame"); done
  magick "${args[@]}" -coalesce -filter point -resize 400% -loop 0 "$output_dir/$name.gif"
}

# These are the actual runtime orders. Stopping deliberately reverses start.
render_reel locomotion 11 \
  "$penguin/idle.png" \
  "$penguin/settle/3.png" "$penguin/settle/2.png" "$penguin/settle/1.png" "$penguin/settle/0.png" \
  "$penguin/start/0.png" "$penguin/start/1.png" "$penguin/start/2.png" "$penguin/start/3.png" \
  "$penguin/walk/0.png" "$penguin/walk/1.png" "$penguin/walk/2.png" "$penguin/walk/3.png" "$penguin/walk/4.png" "$penguin/walk/5.png" \
  "$penguin/walk/0.png" "$penguin/walk/1.png" "$penguin/walk/2.png" "$penguin/walk/3.png" "$penguin/walk/4.png" "$penguin/walk/5.png" \
  "$penguin/start/3.png" "$penguin/start/2.png" "$penguin/start/1.png" "$penguin/start/0.png" \
  "$penguin/idle.png"

render_reel wake 15 "$penguin/wake/"*.png
render_reel idle-personality 28 "$penguin/idle.png" "$penguin/idle-actions/"*.png "$penguin/idle.png"
render_reel tucked-sleep 65 "$penguin/sleep-loop/"*.png
render_reel belly-slide 13 "$penguin/slide/"*.png
render_reel slip-and-recover 10 "$penguin/slip/"*.png

montage \
  "$penguin/idle.png" "$penguin/settle/"*.png "$penguin/start/"*.png \
  "$penguin/walk/"*.png "$penguin/wake/"*.png "$penguin/idle-actions/"*.png \
  "$penguin/sleep-loop/"*.png "$penguin/slide/"*.png "$penguin/slip/"*.png \
  -background '#182034' -fill white -stroke none -pointsize 9 -label '%d/%t' \
  -geometry 112x68+4+12 -tile 8x "$output_dir/all-frames.png"

echo "Animation QA reels written to $output_dir"
