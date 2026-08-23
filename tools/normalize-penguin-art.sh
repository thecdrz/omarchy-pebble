#!/usr/bin/env bash
# Normalizes penguin sprite art without redrawing pixels:
#   1. Re-grounds frames whose feet float above the sequence's baseline
#      (frames deliberately airborne stay airborne).
#   2. Centers ink horizontally so poses and direction flips do not jitter.
#   3. Lifts the dark body palette to a lighter slate so Pebble reads on
#      dark Omarchy themes (belly/beak/highlight tones are untouched).
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
penguin="$root_dir/assets/species/penguin"
canvas_w=56
canvas_h=34
airborne_tolerance=4

normalize_geometry() {
  local dir="$1" frame="$2" ground="$3"
  local geom w h ox oy
  geom="$(magick "$frame" -alpha extract -threshold 10% -format '%@' info:)"
  [[ "$geom" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]] || { echo "SKIP $frame (no bounds: $geom)"; return; }
  w="${BASH_REMATCH[1]}"; h="${BASH_REMATCH[2]}"; ox="${BASH_REMATCH[3]}"; oy="${BASH_REMATCH[4]}"
  local bottom=$((oy + h - 1))
  local ny
  if (( ground - bottom > airborne_tolerance )); then
    ny="$oy" # intentionally airborne pose, keep drawn height
  else
    ny=$((ground - h + 1))
  fi
  local nx=$(( (canvas_w - w) / 2 ))
  if (( nx == ox && ny == oy )); then return 0; fi
  local trimmed
  trimmed="$(mktemp --suffix=.png)"
  magick "$frame" -background none -trim +repage "$trimmed"
  magick -size "${canvas_w}x${canvas_h}" xc:none "$trimmed" -geometry "+$nx+$ny" -composite "$frame"
  rm -f "$trimmed"
  echo "MOVED $dir/$(basename "$frame") ${w}x${h}+$ox+$oy -> +$nx+$ny"
}

# Every shipped sequence was drawn with grounded feet on row 31 (0-indexed).
# Standing poses are normalized to exactly this ink height so Pebble never
# appears to grow or shrink between actions; deliberate squash-and-stretch
# sequences (slide, slip, sleep tuck) keep their dramatic silhouettes.
ground_baseline=31
stand_height=31

normalize_stand_height() {
  local dir="$1" frame="$2"
  local geom w h
  geom="$(magick "$frame" -alpha extract -threshold 10% -format '%@' info:)"
  [[ "$geom" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]] || return 0
  w="${BASH_REMATCH[1]}"; h="${BASH_REMATCH[2]}"
  (( h >= 24 && h < stand_height - 1 )) || return 0
  local scale=$(awk "BEGIN {printf \"%.4f\", $stand_height / $h}")
  local new_w
  new_w="$(awk "BEGIN {printf \"%d\", int($w * $scale + 0.5)}")"
  (( new_w <= canvas_w - 4 )) || return 0
  local trimmed tmp
  trimmed="$(mktemp --suffix=.png)"; tmp="$(mktemp --suffix=.png)"
  magick "$frame" -background none -trim +repage "$trimmed"
  magick "$trimmed" -filter point -resize "${new_w}x${stand_height}!" "$tmp"
  local nx=$(( (canvas_w - new_w) / 2 ))
  local ny=$((ground_baseline - stand_height + 1))
  magick -size "${canvas_w}x${canvas_h}" xc:none "$tmp" -geometry "+$nx+$ny" -composite "$frame"
  rm -f "$trimmed" "$tmp"
  echo "SCALED $dir/$(basename "$frame") ${w}x${h} -> ${new_w}x${stand_height}"
}

lift_palette() {
  local frame="$1"
  local step
  for step in r g b; do
    local lift
    case "$step" in
      r) lift='0.18+1.55*u.r' ;;
      g) lift='0.20+1.55*u.g' ;;
      b) lift='0.26+1.55*u.b' ;;
    esac
    local tmp
    tmp="$(mktemp --suffix=.png)"
    magick "$frame" -channel "$step" -fx "u.b<0.30 ? $lift : u.$step" "$tmp"
    mv "$tmp" "$frame"
  done
}

# Standing sequences: uniform standing height, then ground + center.
for sequence in wake walk idle-actions start stop settle; do
  dir="$penguin/$sequence"
  echo "== $sequence =="
  for frame in "$dir"/*.png; do
    normalize_stand_height "$sequence" "$frame"
  done
done

# Dramatic sequences: ground + center only, silhouettes untouched.
for sequence in slide slip sleep-loop; do
  dir="$penguin/$sequence"
  echo "== $sequence ground row $ground_baseline =="
  for frame in "$dir"/*.png; do
    normalize_geometry "$sequence" "$frame" "$ground_baseline"
  done
done

# A pose that is both wide and full-height (e.g. the slide recovery frame,
# originally 51x31) reads as Pebble suddenly growing. Cap wide+tall boxes by
# scaling them into wide-low crouches that keep the sequence's width rhythm.
cap_wide_tall() {
  local dir="$1" frame="$2" max_w="$3"
  local geom w h ox oy
  geom="$(magick "$frame" -alpha extract -threshold 10% -format '%@' info:)"
  [[ "$geom" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]] || return 0
  w="${BASH_REMATCH[1]}"; h="${BASH_REMATCH[2]}"; ox="${BASH_REMATCH[3]}"; oy="${BASH_REMATCH[4]}"
  (( w > max_w && h > 24 )) || return 0
  local new_w="$max_w"
  local new_h
  new_h="$(awk "BEGIN {printf \"%d\", int($h * $new_w / $w + 0.5)}")"
  local trimmed tmp
  trimmed="$(mktemp --suffix=.png)"; tmp="$(mktemp --suffix=.png)"
  magick "$frame" -background none -trim +repage "$trimmed"
  magick "$trimmed" -filter point -resize "${new_w}x${new_h}!" "$tmp"
  local nx=$(( (canvas_w - new_w) / 2 ))
  local ny=$((ground_baseline - new_h + 1))
  magick -size "${canvas_w}x${canvas_h}" xc:none "$tmp" -geometry "+$nx+$ny" -composite "$frame"
  rm -f "$trimmed" "$tmp"
  echo "CAPPED $dir/$(basename "$frame") ${w}x${h} -> ${new_w}x${new_h}"
}

for frame in "$penguin"/slide/*.png; do cap_wide_tall slide "$frame" 37; done
for frame in "$penguin"/slip/*.png; do cap_wide_tall slip "$frame" 38; done

for still in idle sleep; do
  frame="$penguin/$still.png"
  geom="$(magick "$frame" -alpha extract -threshold 10% -format '%@' info:)"
  [[ "$geom" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]] || continue
  {
    w="${BASH_REMATCH[1]}"; h="${BASH_REMATCH[2]}"; ox="${BASH_REMATCH[3]}"; oy="${BASH_REMATCH[4]}"
    nx=$(( (canvas_w - w) / 2 )); ny=$((canvas_h - 3 - h + 1))
    trimmed="$(mktemp --suffix=.png)"
    magick "$frame" -background none -trim +repage "$trimmed"
    magick -size "${canvas_w}x${canvas_h}" xc:none "$trimmed" -geometry "+$nx+$ny" -composite "$frame"
    rm -f "$trimmed"
    echo "MOVED $still.png ${w}x${h}+$ox+$oy -> +$nx+$ny"
  }
done

echo "== lifting dark body palette =="
for frame in "$penguin"/*.png "$penguin"/*/*.png; do
  lift_palette "$frame"
done

echo "Penguin art normalized: grounded, centered, theme-friendly palette."
