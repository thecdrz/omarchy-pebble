#!/usr/bin/env bash
set -euo pipefail

# Open a marketplace **update** issue for an existing listing.
# Uses the exact heading order from HANCORE-linux/omarchy-plugin-marketplace VERIFICATION.md.
# Does NOT publish — creates the GitHub issue only.

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

plugin_id="$(jq -r '.id' manifest.json)"
repo_url="$(git remote get-url origin | sed -E 's#git@github.com:(.+)\.git#https://github.com/\1#; s#\.git$##')"
commit="$(git rev-parse HEAD)"

body="$(mktemp)"
trap 'rm -f "$body"' EXIT

cat >"$body" <<EOF
### Verification action

Verify and publish a newer upstream commit

### Plugin ID

${plugin_id}

### Repository URL

${repo_url}

### Target commit

${commit}

### Verification acknowledgment

- [x] I understand that only the exact target commit can become a verified marketplace snapshot and that verification is not a security audit.
EOF

echo "Plugin: ${plugin_id}"
echo "Commit: ${commit}"
echo "Body preview:"
cat "$body"
echo
read -r -p "Create marketplace verify issue? [y/N] " confirm
[[ "${confirm,,}" == y ]] || exit 0

gh issue create \
  --repo HANCORE-linux/omarchy-plugin-marketplace \
  --title "[Verify]: $(jq -r '.name' manifest.json)" \
  --body-file "$body"
