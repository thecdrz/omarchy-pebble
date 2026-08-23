#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

check_sequence() {
  local species="$1" name="$2" expected="$3" max_height_spread="$4" max_components="${5:-1}" max_visible_area="${6:-0}"
  local min_opaque_pixels="${7:-0}" max_opaque_pixels="${8:-0}"
  local directory="$root_dir/assets/species/$species/$name"
  local count=0 min_height=999 max_height=0

  for frame in "$directory"/*.png; do
    count=$((count + 1))
    local dimensions geometry width height x y right bottom components opaque_pixels
    dimensions="$(identify -format '%wx%h' "$frame")"
    if [[ "$dimensions" != "56x34" ]]; then
      echo "FAIL $frame: expected 56x34, got $dimensions" >&2
      failures=$((failures + 1))
      continue
    fi

    geometry="$(magick "$frame" -alpha extract -threshold 10% -format '%@' info:)"
    if [[ ! "$geometry" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]]; then
      echo "FAIL $frame: could not determine visible bounds" >&2
      failures=$((failures + 1))
      continue
    fi
    width="${BASH_REMATCH[1]}"; height="${BASH_REMATCH[2]}"
    x="${BASH_REMATCH[3]}"; y="${BASH_REMATCH[4]}"
    right=$((x + width)); bottom=$((y + height))
    if (( x == 0 || y == 0 || right >= 56 || bottom >= 34 )); then
      echo "FAIL $frame: visible artwork touches a canvas edge ($geometry)" >&2
      failures=$((failures + 1))
    fi

    components="$(magick "$frame" -alpha extract -threshold 10% \
      -define connected-components:verbose=true -connected-components 8 null: \
      | awk '/srgb\(255,255,255\)/ && $4 >= 8 { count++ } END { print count+0 }')"
    if (( components > max_components )); then
      echo "FAIL $frame: expected at most $max_components connected silhouette parts, found $components" >&2
      failures=$((failures + 1))
    fi
    if (( max_visible_area > 0 && width * height > max_visible_area )); then
      echo "FAIL $frame: visible area box $((width * height)) exceeds $max_visible_area px ($geometry)" >&2
      failures=$((failures + 1))
    fi
    opaque_pixels="$(magick "$frame" -alpha extract -threshold 10% -format '%[fx:round(mean*w*h)]' info:)"
    if (( min_opaque_pixels > 0 && opaque_pixels < min_opaque_pixels )); then
      echo "FAIL $frame: silhouette mass $opaque_pixels px is below $min_opaque_pixels px" >&2
      failures=$((failures + 1))
    fi
    if (( max_opaque_pixels > 0 && opaque_pixels > max_opaque_pixels )); then
      echo "FAIL $frame: silhouette mass $opaque_pixels px exceeds $max_opaque_pixels px" >&2
      failures=$((failures + 1))
    fi
    (( height < min_height )) && min_height="$height"
    (( height > max_height )) && max_height="$height"
  done

  if (( count != expected )); then
    echo "FAIL $name: expected $expected frames, found $count" >&2
    failures=$((failures + 1))
  fi
  if (( max_height - min_height > max_height_spread )); then
    echo "FAIL $name: visible height varies by $((max_height - min_height)) px" >&2
    failures=$((failures + 1))
  fi
}

for species_dir in "$root_dir"/assets/species/*; do
  species="$(basename "$species_dir")"
  if [[ "$species" == "gecko" ]]; then
    check_sequence "$species" wake 8 10
    check_sequence "$species" walk 6 10
  elif [[ "$species" == "penguin" ]]; then
    check_sequence "$species" wake 8 1 1 1100 500 900
    check_sequence "$species" walk 6 1 1 950 450 700
    check_sequence "$species" settle 4 1 1 0 570 640
    check_sequence "$species" sleep-loop 4 3 2 600 300 450
    check_sequence "$species" idle-actions 8 1 2 950 380 750
    check_sequence "$species" start 4 1 1 0 570 650
    check_sequence "$species" stop 4 1 1 0 370 450
    check_sequence "$species" slide 8 12 1 1300 400 1320
    check_sequence "$species" slip 16 12 3 1300 560 750
  else
    check_sequence "$species" wake 8 4
    check_sequence "$species" walk 6 2
  fi

  for still in idle sleep; do
    file="$species_dir/$still.png"
    [[ "$(identify -format '%wx%h' "$file")" == "56x34" ]] || {
      echo "FAIL $file: expected 56x34" >&2
      failures=$((failures + 1))
    }
  done

  habitat="$species_dir/habitat.png"
  [[ "$(identify -format '%wx%h' "$habitat")" == "38x28" ]] || {
    echo "FAIL $habitat: expected 38x28" >&2
    failures=$((failures + 1))
  }
done

for concept in "$root_dir"/assets/concepts/*.png; do
  [[ "$(identify -format '%wx%h' "$concept")" == "56x34" ]] || {
    echo "FAIL $concept: expected 56x34" >&2
    failures=$((failures + 1))
  }
  geometry="$(magick "$concept" -alpha extract -threshold 10% -format '%@' info:)"
  if [[ "$geometry" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]]; then
    width="${BASH_REMATCH[1]}"; height="${BASH_REMATCH[2]}"
    x="${BASH_REMATCH[3]}"; y="${BASH_REMATCH[4]}"
    if (( x == 0 || y == 0 || x + width >= 56 || y + height >= 34 )); then
      echo "FAIL $concept: visible artwork touches a canvas edge ($geometry)" >&2
      failures=$((failures + 1))
    fi
  else
    echo "FAIL $concept: could not determine visible bounds" >&2
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  echo "$failures asset validation failure(s)" >&2
  exit 1
fi
echo "Asset validation passed: intact silhouettes, stable scale, safe canvas margins."
