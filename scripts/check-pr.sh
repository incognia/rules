#!/usr/bin/env bash
# pass() only echoes and always returns 0, so "A && pass ... || fail ..." is a safe if-else.
# shellcheck disable=SC2015
#
# check-pr.sh - verify that a pull request follows the conventions of /commit and
# /changelogger, so that a pull request that does not is rejected before it is reviewed.
#
# Checks (a FAIL means the pull request is rejected): Conventional Commits subjects in
# English, commit body format, Co-Authored-By trailers, no fixup commits, CHANGELOG.md
# rules, stray files, pull request title and body structure, and OpenSpec validation.
#
# Usage (from the repository that holds the pull request, with bash):
#   ~/rules/scripts/check-pr.sh [--base REF] [--head REF] [--title TEXT]
#                               [--body-file FILE] [--config FILE] [--skip-openspec]
#
# Defaults: --base origin/main and --head HEAD. On Windows run it from WSL or Git Bash.
# Exit status: 0 when nothing failed, 1 when a check failed, 2 on bad usage.
#
# Project settings (optional): .github/pr-check.conf, relative to the repository root,
# one "key = value" per line, "#" starts a comment. Keys:
#   stray    = <glob>   extra path pattern that must not appear in a pull request (repeatable)
#   template = <path>   pull request template (default: .github/PULL_REQUEST_TEMPLATE.md)
#   openspec = auto|off validate openspec/ when it exists (default: auto)
#
# Rules and rationale: ~/rules/rulesets/PR_CHECK.md and ~/rules/cot/pr_check.md
#
# Author: Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Licence: GNU General Public License v3.0 (GPLv3)

set -u

BASE="origin/main"
HEAD_REF="HEAD"
TITLE=""
BODY_FILE=""
CONFIG=""
TEMPLATE=""
SKIP_OPENSPEC=0

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
    case "$1" in
        --base)          [ $# -ge 2 ] || { usage; exit 2; }; BASE="$2"; shift 2 ;;
        --head)          [ $# -ge 2 ] || { usage; exit 2; }; HEAD_REF="$2"; shift 2 ;;
        --title)         [ $# -ge 2 ] || { usage; exit 2; }; TITLE="$2"; shift 2 ;;
        --body-file)     [ $# -ge 2 ] || { usage; exit 2; }; BODY_FILE="$2"; shift 2 ;;
        --config)        [ $# -ge 2 ] || { usage; exit 2; }; CONFIG="$2"; shift 2 ;;
        --skip-openspec) SKIP_OPENSPEC=1; shift ;;
        -h|--help)       usage; exit 0 ;;
        *)               echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

FAILS=0
WARNS=0
pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*"; FAILS=$((FAILS + 1)); }
warn() { echo "[WARN] $*"; WARNS=$((WARNS + 1)); }
skip() { echo "[SKIP] $*"; }

trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

# True when the text contains characters that only appear in Spanish (accents, n with tilde,
# inverted marks). Used as a heuristic to catch commit messages not written in English.
has_spanish() {
    printf '%s' "$1" | LC_ALL=C grep -q -E $'\xc3[\xa1\xa9\xad\xb3\xba\xb1]|\xc2[\xbf\xa1]'
}

# Commit subjects use the same types as .githooks/commit-msg; CHANGELOG bullets use the
# types listed in the /changelogger skill (no "revert").
COMMIT_TYPES='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'
CHANGELOG_TYPES='feat|fix|docs|style|refactor|chore|ci|perf|test|build'
SUBJECT_RE="^($COMMIT_TYPES)(\\([a-z0-9._/-]+\\))?!?: [^ ].*"
BULLET_RE="^- ($CHANGELOG_TYPES): .+"
HEADING_RE='^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\] - .+'

# A commit message must not report CHANGELOG upkeep ("update the CHANGELOG", "CHANGELOG entry",
# "add a line to the changelog"). Merely naming the CHANGELOG, or the /changelogger skill,
# is fine: a commit that documents or implements the checks has to talk about it.
# Quoted text ("...", `...`, «...», “...”) is ignored, because that is how a message cites the
# phrases it talks about; single quotes are kept, since they double as apostrophes.
# The backticks in the sed script are literal characters, not command substitution.
# shellcheck disable=SC2016
strip_quoted() { sed -E 's/"[^"]*"//g; s/`[^`]*`//g; s/«[^»]*»//g; s/“[^”]*”//g'; }
UPKEEP_VERBS='(update|updates|updated|updating|edit|edits|edited|editing|modify|modifies|modified|amend|bump|regenerate|touch|sync|append|rewrite|refresh)'
RECORD_VERBS='(add|adds|added|adding|record|records|recorded|log|logs|logged|write|writes|wrote)'
CHANGELOG_UPKEEP_RE="(^|[^[:alpha:]])$UPKEEP_VERBS( (the|a|an|our|this|that|all|every|its))? (project )?changelog([^[:alpha:]]|\$)|changelog(\\.md)? (entry|entries|bullet|bullets|update|updates)|(^|[^[:alpha:]])$RECORD_VERBS [^.]{0,40}(to|in|into) (the |a |our )?(project )?changelog([^[:alpha:]]|\$)"

# CHANGELOG.md helpers; they read the file from stdin.
cl_dates()  { grep -E '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' | cut -c5-14; }
cl_dupes()  { cl_dates | sort | uniq -d; }
cl_blanks() { awk '/^$/ {blank=1; next} /^- / {if (blank && last) print; last=1; blank=0; next} {last=0; blank=0}' | sort; }

# Build output, logs and OS files do not belong in a pull request. A project adds its own
# patterns with "stray = <glob>" in its configuration file.
STRAY_PATTERNS='.DS_Store
*/.DS_Store
Thumbs.db
*/Thumbs.db
*.log
*.exe
*.dll
*.pdb
*.o
*.obj
bin/*
*/bin/*
obj/*
*/obj/*
.vs/*
*/.vs/*
node_modules/*
*/node_modules/*
*/__pycache__/*'

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not inside a git repository" >&2; exit 2; }

# ---------------------------------------------------------------- project configuration
if [ -z "$CONFIG" ] && [ -f .github/pr-check.conf ]; then CONFIG=".github/pr-check.conf"; fi
if [ -n "$CONFIG" ]; then
    [ -f "$CONFIG" ] || { echo "configuration file not found: $CONFIG" >&2; exit 2; }
    while IFS= read -r raw || [ -n "$raw" ]; do
        line=$(trim "$raw")
        case "$line" in ''|'#'*) continue ;; esac
        key=$(trim "${line%%=*}")
        val=$(trim "${line#*=}")
        case "$key" in
            stray)    STRAY_PATTERNS="$STRAY_PATTERNS
$val" ;;
            template) TEMPLATE="$val" ;;
            openspec) case "$val" in
                          auto) ;;
                          off)  SKIP_OPENSPEC=1 ;;
                          *)    echo "$CONFIG: openspec must be auto or off, not '$val'" >&2; exit 2 ;;
                      esac ;;
            *)        echo "$CONFIG: unknown key '$key'" >&2; exit 2 ;;
        esac
    done < "$CONFIG"
fi
if [ -z "$TEMPLATE" ]; then
    for candidate in .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md \
                     PULL_REQUEST_TEMPLATE.md docs/PULL_REQUEST_TEMPLATE.md; do
        [ -f "$candidate" ] && { TEMPLATE="$candidate"; break; }
    done
fi

is_stray() {
    local f="$1" p
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        # $p is a glob from STRAY_PATTERNS, so it must stay unquoted to match as a pattern.
        # shellcheck disable=SC2254
        case "$f" in $p) return 0 ;; esac
    done <<EOF
$STRAY_PATTERNS
EOF
    return 1
}

git rev-parse --verify --quiet "$BASE^{commit}" >/dev/null || { echo "unknown base ref: $BASE" >&2; exit 2; }
git rev-parse --verify --quiet "$HEAD_REF^{commit}" >/dev/null || { echo "unknown head ref: $HEAD_REF" >&2; exit 2; }

echo "Checking $BASE..$HEAD_REF"
echo

# ---------------------------------------------------------------- commits
COMMITS=$(git rev-list --no-merges --reverse "$BASE..$HEAD_REF")
if [ -z "$COMMITS" ]; then
    fail "the pull request has no commits"
else
    pass "$(printf '%s\n' "$COMMITS" | wc -l | tr -d ' ') commit(s) in the pull request"
fi

if [ -n "$(git rev-list --merges "$BASE..$HEAD_REF")" ]; then
    warn "the pull request contains merge commits; rebase instead to keep the history atomic"
fi

BAD_SUBJECT=""; BAD_FIXUP=""; BAD_LANG=""; BAD_BLANK=""; BAD_BULLET=""; BAD_CHANGELOG=""; BAD_TRAILER=""; WARN_BODY_LANG=""
for sha in $COMMITS; do
    short=$(git rev-parse --short "$sha")
    subject=$(git log -1 --format=%s "$sha")
    msg=$(git log -1 --format=%B "$sha")
    body=$(git log -1 --format=%b "$sha")

    case "$subject" in
        "fixup! "*|"squash! "*|"amend! "*) BAD_FIXUP="$BAD_FIXUP $short" ;;
        *) [[ $subject =~ $SUBJECT_RE ]] || BAD_SUBJECT="$BAD_SUBJECT $short" ;;
    esac
    has_spanish "$subject" && BAD_LANG="$BAD_LANG $short"
    has_spanish "$body" && WARN_BODY_LANG="$WARN_BODY_LANG $short"
    [ -z "$(printf '%s\n' "$msg" | sed -n '2p')" ] || BAD_BLANK="$BAD_BLANK $short"
    printf '%s\n' "$msg" | grep -q -E '^[[:space:]]+- ' && BAD_BULLET="$BAD_BULLET $short"
    printf '%s\n' "$msg" | strip_quoted | grep -q -i -E "$CHANGELOG_UPKEEP_RE" && BAD_CHANGELOG="$BAD_CHANGELOG $short"
    printf '%s\n' "$msg" | grep -q -E '^Co-Authored-By: .+ <[^>]+@[^>]+>$' || BAD_TRAILER="$BAD_TRAILER $short"
done

if [ -n "$COMMITS" ]; then
    [ -z "$BAD_FIXUP" ]     && pass "no fixup, squash or amend commits" \
                            || fail "fixup/squash/amend commits must be squashed before the pull request:$BAD_FIXUP"
    [ -z "$BAD_SUBJECT" ]   && pass "commit subjects follow Conventional Commits" \
                            || fail "subject is not 'type(scope): summary' in:$BAD_SUBJECT (types: $COMMIT_TYPES)"
    [ -z "$BAD_LANG" ]      && pass "commit subjects look like English" \
                            || fail "subject seems to be in Spanish in:$BAD_LANG (commit messages must be in international English, UK)"
    [ -z "$BAD_BLANK" ]     && pass "a blank line separates subject and body" \
                            || fail "missing blank line after the subject in:$BAD_BLANK"
    [ -z "$BAD_BULLET" ]    && pass "body bullets start at column 1" \
                            || fail "indented bullet in the body of:$BAD_BULLET (bullets start at column 1, continuation lines use two spaces)"
    [ -z "$BAD_CHANGELOG" ] && pass "no commit message reports CHANGELOG upkeep" \
                            || fail "commit message mentions the changelog upkeep in:$BAD_CHANGELOG (changelog upkeep is not a body detail)"
    [ -z "$BAD_TRAILER" ]   && pass "every commit has a Co-Authored-By trailer" \
                            || fail "missing 'Co-Authored-By: [Tool ]Model (effort) <email>' trailer in:$BAD_TRAILER"
    [ -z "$WARN_BODY_LANG" ] || warn "the body seems to be in Spanish in:$WARN_BODY_LANG"
fi

# ---------------------------------------------------------------- CHANGELOG.md
if ! git cat-file -e "$HEAD_REF:CHANGELOG.md" 2>/dev/null; then
    fail "CHANGELOG.md does not exist"
else
    TOUCHING=$(git rev-list --no-merges --full-history "$BASE..$HEAD_REF" -- CHANGELOG.md)
    NEWEST=$(git rev-list --no-merges -n 1 "$BASE..$HEAD_REF")
    if [ -z "$TOUCHING" ]; then
        fail "CHANGELOG.md was not changed by the pull request"
    elif [ "$TOUCHING" = "$NEWEST" ]; then
        pass "CHANGELOG.md changes only in the last commit"
    else
        fail "CHANGELOG.md must change only in the last commit; it changes in: $(printf '%s\n' "$TOUCHING" | while read -r s; do printf '%s ' "$(git rev-parse --short "$s")"; done)"
    fi

    if [ -n "$TOUCHING" ]; then
        REMOVED=$(git diff "$BASE...$HEAD_REF" -- CHANGELOG.md | grep -E '^-' | grep -cvE '^---')
        [ "$REMOVED" -eq 0 ] && pass "CHANGELOG.md diff only adds lines" \
                             || fail "CHANGELOG.md diff removes or edits $REMOVED existing line(s); it must be insertion-only"

        BAD_LINES=""
        TODAY=$(TZ=America/Mexico_City date +%F)
        FUTURE=""
        while IFS= read -r line; do
            l=${line#+}
            [ -z "$l" ] && continue
            if [[ $l =~ $HEADING_RE ]]; then
                d=${l:4:10}
                [[ "$d" > "$TODAY" ]] && FUTURE="$FUTURE $d"
            elif [[ ! $l =~ $BULLET_RE ]]; then
                BAD_LINES="$BAD_LINES
    $l"
            fi
        done < <(git diff -U0 "$BASE...$HEAD_REF" -- CHANGELOG.md | grep -E '^\+' | grep -vE '^\+\+\+')
        [ -z "$BAD_LINES" ] && pass "added CHANGELOG.md lines are typed bullets or date headings" \
                            || fail "added CHANGELOG.md lines that are neither '- type: text' nor '## [YYYY-MM-DD] - Title':$BAD_LINES"
        [ -z "$FUTURE" ] && pass "no CHANGELOG.md date is after today in Mexico City time (CST, UTC-6)" \
                         || fail "CHANGELOG.md has dates after today in Mexico City time:$FUTURE (dates are CST, not UTC)"
    fi

    # Defects that CHANGELOG.md already had before the pull request are reported as warnings:
    # only the ones the pull request introduces fail it.
    BASE_CL=$(git show "$BASE:CHANGELOG.md" 2>/dev/null || true)
    HEAD_CL=$(git show "$HEAD_REF:CHANGELOG.md")

    NEW_DUPES=$(comm -13 <(printf '%s\n' "$BASE_CL" | cl_dupes) <(printf '%s\n' "$HEAD_CL" | cl_dupes))
    OLD_DUPES=$(comm -12 <(printf '%s\n' "$BASE_CL" | cl_dupes) <(printf '%s\n' "$HEAD_CL" | cl_dupes))
    [ -z "$NEW_DUPES" ] && pass "the pull request adds no duplicate date headings" \
                        || fail "CHANGELOG.md has duplicate date headings: $(printf '%s' "$NEW_DUPES" | tr '\n' ' ')"
    [ -z "$OLD_DUPES" ] || warn "CHANGELOG.md already had duplicate date headings before this pull request: $(printf '%s' "$OLD_DUPES" | tr '\n' ' ')"

    HEAD_DATES=$(printf '%s\n' "$HEAD_CL" | cl_dates)
    BASE_DATES=$(printf '%s\n' "$BASE_CL" | cl_dates)
    if [ "$HEAD_DATES" = "$(printf '%s\n' "$HEAD_DATES" | sort -r)" ]; then
        pass "CHANGELOG.md dates are in reverse chronological order"
    elif [ "$BASE_DATES" = "$(printf '%s\n' "$BASE_DATES" | sort -r)" ]; then
        fail "the pull request breaks the reverse chronological order of the CHANGELOG.md dates"
    else
        warn "CHANGELOG.md dates were already out of order before this pull request"
    fi

    NEW_BLANKS=$(comm -13 <(printf '%s\n' "$BASE_CL" | cl_blanks) <(printf '%s\n' "$HEAD_CL" | cl_blanks))
    OLD_BLANKS=$(comm -12 <(printf '%s\n' "$BASE_CL" | cl_blanks) <(printf '%s\n' "$HEAD_CL" | cl_blanks))
    [ -z "$NEW_BLANKS" ] && pass "the pull request adds no blank line between bullets of the same date block" \
                         || fail "the pull request adds a blank line between bullets of the same date block, before: $(printf '%s\n' "$NEW_BLANKS" | head -1 | cut -c1-80)"
    [ -z "$OLD_BLANKS" ] || warn "CHANGELOG.md already had $(printf '%s\n' "$OLD_BLANKS" | wc -l | tr -d ' ') blank line(s) between bullets before this pull request"
fi

# ---------------------------------------------------------------- stray files
STRAY=""
while IFS= read -r f; do
    is_stray "$f" && STRAY="$STRAY $f"
done < <(git diff --name-only --diff-filter=ACMR "$BASE...$HEAD_REF")
[ -z "$STRAY" ] && pass "no build output, logs or OS files added" \
                || fail "stray files in the pull request:$STRAY"

# ---------------------------------------------------------------- the checks themselves
# A pull request could weaken the checks that judge it, so changes to them need a human look.
if git diff --name-only "$BASE...$HEAD_REF" | grep -q -E '^(scripts/check-pr\.sh|scripts/tests/check-pr|\.github/)'; then
    warn "the pull request changes the checks, their configuration or the pull request template; review those files by hand"
fi

# ---------------------------------------------------------------- title and body
if [ -n "$TITLE" ]; then
    if [[ $TITLE =~ $SUBJECT_RE ]]; then pass "pull request title follows Conventional Commits"
    else fail "pull request title is not 'type(scope): summary': $TITLE"; fi
    has_spanish "$TITLE" && fail "pull request title seems to be in Spanish: $TITLE"
fi

if [ -n "$BODY_FILE" ]; then
    if [ ! -s "$BODY_FILE" ]; then
        fail "the pull request description is empty"
    elif [ -z "$TEMPLATE" ]; then
        skip "no pull request template to compare the description with"
    else
        MISSING=""
        while IFS= read -r h; do
            grep -q -F "$h" "$BODY_FILE" || MISSING="$MISSING
    $h"
        done < <(grep -E '^## ' "$TEMPLATE")
        [ -z "$MISSING" ] && pass "the description keeps every section of $TEMPLATE" \
                          || fail "sections missing from the description:$MISSING"
        UNCHECKED=$(grep -c -E '^- \[ \]' "$BODY_FILE")
        [ "$UNCHECKED" -eq 0 ] || warn "$UNCHECKED checklist item(s) left unchecked in the description"
    fi
fi

# ---------------------------------------------------------------- OpenSpec
if [ "$SKIP_OPENSPEC" -eq 1 ]; then
    skip "OpenSpec validation (disabled)"
elif [ ! -d openspec ]; then
    skip "OpenSpec validation (no openspec/ directory)"
else
    if command -v openspec >/dev/null 2>&1; then RUNNER="openspec"
    elif command -v npx >/dev/null 2>&1; then RUNNER="npx -y @fission-ai/openspec@latest"
    else RUNNER=""; fi
    if [ -z "$RUNNER" ]; then
        warn "OpenSpec validation skipped: neither openspec nor npx is installed"
    else
        OUT=$(mktemp)
        if $RUNNER validate --all --strict >"$OUT" 2>&1; then
            pass "openspec validate --all --strict"
        else
            fail "openspec validate --all --strict failed:"
            sed 's/^/    /' "$OUT" | tail -15
        fi
        rm -f "$OUT"
    fi
fi

echo
if [ "$FAILS" -gt 0 ]; then
    echo "$FAILS check(s) failed, $WARNS warning(s): this pull request would be rejected."
    exit 1
fi
echo "All checks passed ($WARNS warning(s))."
exit 0
