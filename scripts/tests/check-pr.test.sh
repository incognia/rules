#!/usr/bin/env bash
#
# check-pr.test.sh - tests for check-pr.sh. It builds a throwaway repository, opens pull
# requests of known quality against it and checks the verdicts.
#
# Usage: ~/rules/scripts/tests/check-pr.test.sh
# Exit status: 0 when every test passed, 1 otherwise.
#
# Author: Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Licence: GNU General Public License v3.0 (GPLv3)

set -u

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/check-pr.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

PASSED=0
FAILED=0
OUT=""
CODE=0

TODAY=$(TZ=America/Mexico_City date +%F)
YESTERDAY=$(TZ=America/Mexico_City date -v-1d +%F 2>/dev/null || TZ=America/Mexico_City date -d yesterday +%F)

ok()  { echo "ok   - $*"; PASSED=$((PASSED + 1)); }
nok() { echo "FAIL - $*"; FAILED=$((FAILED + 1)); }

# A base repository whose only CHANGELOG block is from yesterday.
new_repo() {
    rm -rf "$TMP/repo"
    mkdir "$TMP/repo"
    cd "$TMP/repo" || exit 1
    git init -q
    git symbolic-ref HEAD refs/heads/main
    git config user.name "Tester"
    git config user.email "tester@example.com"
    printf '# Historial de cambios\n\n<!-- markdownlint-disable -->\n## [%s] - Base\n\n- docs: base\n' "$YESTERDAY" > CHANGELOG.md
    echo base > README.md
    mkdir .github
    printf '# project settings\nstray = secret/*\n' > .github/pr-check.conf
    git add -A
    git commit -q -m "docs: base"
}

branch() { git checkout -q main && git checkout -q -b "$1"; }

# commit "<subject>" [no-trailer]: a message with a body and, by default, a trailer.
commit() {
    {
        printf '%s\n\n- Change something\n' "$1"
        [ "${2-}" = "no-trailer" ] || printf '\nCo-Authored-By: Test Tool 1.0 <noreply@example.com>\n'
    } > "$TMP/msg"
    git commit -q -F "$TMP/msg"
}

# new_block <date>: add a CHANGELOG block for that date above the existing ones.
new_block() {
    awk -v d="$1" '{print} /^<!-- markdownlint-disable -->$/ {print "## [" d "] - New day\n\n- docs: add a test entry\n"}' CHANGELOG.md > CHANGELOG.tmp
    mv CHANGELOG.tmp CHANGELOG.md
}

# run <branch> [extra options]
run() {
    git checkout -q "$1"
    OUT=$(bash "$SCRIPT" --base main --head "$1" --skip-openspec "${@:2}" 2>&1)
    CODE=$?
}

expect_pass() {
    run "$1"
    if [ "$CODE" -eq 0 ]; then ok "$2"; else nok "$2"; printf '%s\n' "$OUT" | sed 's/^/      /'; fi
}

# expect_fail <branch> <name> <text in the output> [extra options]
expect_fail() {
    run "$1" "${@:4}"
    if [ "$CODE" -eq 1 ] && printf '%s' "$OUT" | grep -q -F "$3"; then ok "$2"
    else nok "$2 (expected exit 1 and '$3', got $CODE)"; printf '%s\n' "$OUT" | sed 's/^/      /'; fi
}

new_repo

branch good; new_block "$TODAY"; echo x >> README.md; git add -A; commit "docs: add a test entry"
expect_pass good "a compliant pull request passes"

branch bad-subject; new_block "$TODAY"; git add -A; commit "Actualiza documentación"
expect_fail bad-subject "a subject that is not Conventional Commits fails" "subject is not"
expect_fail bad-subject "a Spanish subject fails" "seems to be in Spanish"

branch no-trailer; new_block "$TODAY"; git add -A; commit "docs: add a test entry" no-trailer
expect_fail no-trailer "a missing Co-Authored-By trailer fails" "Co-Authored-By"

branch fixup; new_block "$TODAY"; git add -A; commit "fixup! docs: base"
expect_fail fixup "a fixup commit fails" "fixup"

branch changelog-twice; new_block "$TODAY"; git add -A; commit "docs: add a test entry"
echo x >> README.md; git add -A; commit "docs: touch the readme"
expect_fail changelog-twice "a CHANGELOG that is not in the last commit only fails" "only in the last commit"

branch no-changelog; echo x >> README.md; git add -A; commit "docs: touch the readme"
expect_fail no-changelog "a pull request without CHANGELOG changes fails" "was not changed"

branch edits-line; new_block "$TODAY"
awk '{ if ($0 == "- docs: base") print "- docs: edited"; else print }' CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md
git add -A; commit "docs: add a test entry"
expect_fail edits-line "editing an existing CHANGELOG line fails" "insertion-only"

branch future; new_block "2099-01-01"; git add -A; commit "docs: add a test entry"
expect_fail future "a CHANGELOG date after today fails" "after today"

branch stray; new_block "$TODAY"; mkdir secret; echo x > secret/key.txt; git add -A; commit "docs: add a test entry"
expect_fail stray "a file matching a project stray pattern fails" "stray files"

branch title; new_block "$TODAY"; git add -A; commit "docs: add a test entry"
expect_fail title "a pull request title that is not Conventional Commits fails" "pull request title" --title "Fix stuff"

branch touches-checks; new_block "$TODAY"; echo "# more" >> .github/pr-check.conf; git add -A; commit "ci: tweak the settings"
run touches-checks
if [ "$CODE" -eq 0 ] && printf '%s' "$OUT" | grep -q -F "[WARN]"; then ok "changing the checks passes with a warning"
else nok "changing the checks passes with a warning (got $CODE)"; printf '%s\n' "$OUT" | sed 's/^/      /'; fi

printf '# bad\nunknown = 1\n' > "$TMP/bad.conf"
git checkout -q good
bash "$SCRIPT" --base main --head good --skip-openspec --config "$TMP/bad.conf" >/dev/null 2>&1
if [ $? -eq 2 ]; then ok "an unknown configuration key is a usage error"; else nok "an unknown configuration key is a usage error"; fi

if bash "$SCRIPT" --help >/dev/null 2>&1; then ok "--help exits successfully"; else nok "--help exits successfully"; fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
