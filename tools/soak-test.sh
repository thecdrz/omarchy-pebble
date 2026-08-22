#!/usr/bin/env bash
set -euo pipefail

duration="${1:-86400}"
interval="${2:-60}"
report="${3:-/tmp/pebble-soak.csv}"

[[ "$duration" =~ ^[0-9]+$ && "$interval" =~ ^[0-9]+$ && "$duration" -gt 0 && "$interval" -gt 0 ]] || {
  echo "usage: $0 [duration-seconds] [sample-seconds] [report.csv]" >&2
  exit 2
}

pid="$(pgrep -n -f '^quickshell -n -p /usr/share/omarchy/shell$' || true)"
[[ -n "$pid" ]] || { echo "omarchy-shell is not running" >&2; exit 1; }

started_at="$(date --iso-8601=seconds)"
started_epoch="$(date +%s)"
deadline=$((started_epoch + duration))
printf 'timestamp,pid,rss_kib,cpu_percent,state_bytes\n' > "$report"

while (( $(date +%s) < deadline )); do
  current_pid="$(pgrep -n -f '^quickshell -n -p /usr/share/omarchy/shell$' || true)"
  [[ "$current_pid" == "$pid" ]] || { echo "FAIL: omarchy-shell restarted ($pid -> ${current_pid:-missing})" >&2; exit 1; }
  rss="$(awk '/^VmRSS:/ { print $2 }' "/proc/$pid/status")"
  cpu="$(ps -p "$pid" -o %cpu= | tr -d ' ')"
  state_bytes="$(stat -c %s "$HOME/.local/state/omarchy/pebble/state.json" 2>/dev/null || echo 0)"
  printf '%s,%s,%s,%s,%s\n' "$(date --iso-8601=seconds)" "$pid" "${rss:-0}" "${cpu:-0}" "$state_bytes" >> "$report"
  sleep "$interval"
done

errors="$(journalctl --user --since "$started_at" --no-pager | rg -ci 'pebble/Companion.qml.*(error|failed|typeerror|referenceerror|unable to assign|cannot read)' || true)"
errors="${errors:-0}"
first_rss="$(awk -F, 'NR==2 { print $3 }' "$report")"
last_rss="$(awk -F, 'END { print $3 }' "$report")"
delta=$(( ${last_rss:-0} - ${first_rss:-0} ))

echo "Pebble soak complete: errors=$errors rss_delta_kib=$delta report=$report"
(( errors == 0 )) || exit 1
