#!/usr/bin/env bash
# Verifies every *.sha256 checksum under a backup directory.
# Each checksum is checked from its own directory, because backup_file.sh
# records only the file's base name.
# Usage: verify_backups.sh [backup_dir]
# Exit status: 0 when every checksum matches (or none exist), 1 otherwise.

set -euo pipefail

DIR=${1:-backups}
[ -d "$DIR" ] || { echo "Backup directory not found: $DIR" >&2; exit 1; }

if command -v sha256sum >/dev/null 2>&1; then
  SHA=(sha256sum)
else
  SHA=(shasum -a 256)
fi

# Collect the list first so a find failure aborts (set -e) instead of
# looking like "no checksums".
list=$(mktemp "${TMPDIR:-/tmp}/verify_backups.XXXXXX")
trap 'rm -f "$list"' EXIT
find "$DIR" -type f -name '*.sha256' -print0 > "$list"

total=0
failed=0
while IFS= read -r -d '' sumfile; do
  total=$((total + 1))
  if (cd "$(dirname "$sumfile")" && "${SHA[@]}" -c "$(basename "$sumfile")"); then
    :
  else
    failed=$((failed + 1))
    echo "FAILED: $sumfile" >&2
  fi
done < "$list"

if [ "$total" -eq 0 ]; then
  echo "No checksum files found under $DIR"
  exit 0
fi
echo "$((total - failed))/$total checksums OK"
[ "$failed" -eq 0 ]
