#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
catalog="$root_dir/companions.json"

jq -e '
  .schemaVersion == 1 and
  (.residents | type == "array" and length > 0) and
  ([.residents[].id] | length == (unique | length)) and
  ([.residents[] | select(.status == "ready")] | length > 0) and
  ([.residents[].status] | all(. == "ready" or . == "lab" or . == "concept"))
' "$catalog" >/dev/null

while IFS=$'\t' read -r id directory; do
  [[ -n "$directory" && -d "$root_dir/$directory" ]] || {
    echo "FAIL: ready companion $id has no asset directory" >&2
    exit 1
  }
  for required in idle.png sleep-loop wake walk settle start idle-actions; do
    [[ -e "$root_dir/$directory/$required" ]] || {
      echo "FAIL: ready companion $id is missing $required" >&2
      exit 1
    }
  done
done < <(jq -r '.residents[] | select(.status == "ready") | [.id, .assetDirectory] | @tsv' "$catalog")

echo "Roster validation passed: every selectable resident meets the animation contract."

