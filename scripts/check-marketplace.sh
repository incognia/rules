#!/usr/bin/env bash
# Check that marketplace/ is consistent: OpenSpec validation, main specs in sync
# with the unarchived change, and the starter kit (copies, JSON, tests).
# Usage: scripts/check-marketplace.sh   (from anywhere in the repository)
# Exit codes: 0 = all checks pass, 1 = a check failed.
set -Eeuo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MARKET="$REPO_ROOT/marketplace"
KIT="$MARKET/kit"
CHANGE=bootstrap-skill-marketplace
OPENSPEC="$REPO_ROOT/node_modules/.bin/openspec"
command -v "$OPENSPEC" >/dev/null 2>&1 || OPENSPEC=openspec

step() { printf '== %s\n' "$1"; }

step "OpenSpec validation"
(cd "$MARKET" && "$OPENSPEC" validate --all --strict)

step "Main specs equal the archived change"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -R "$MARKET/openspec" "$tmp/"
rm -rf "$tmp/openspec/specs"
mkdir "$tmp/openspec/specs"
(cd "$tmp" && "$OPENSPEC" archive "$CHANGE" --yes >/dev/null)
diff -r "$tmp/openspec/specs" "$MARKET/openspec/specs"

step "Kit: identical copies of python_check.py"
for copy in "$KIT"/skeleton/plugins/*/scripts/python_check.py; do
    cmp "$KIT/skeleton/scripts/python_check.py" "$copy"
done

step "Kit: JSON files parse"
find "$KIT" -name '*.json' -print0 | while IFS= read -r -d '' file; do
    python3 -m json.tool "$file" >/dev/null || { echo "invalid JSON: $file" >&2; exit 1; }
done

step "Kit: tests"
(cd "$KIT/skeleton" && PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests)

echo "marketplace checks passed"
