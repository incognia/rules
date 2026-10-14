#!/bin/bash

# =============================================================================
# ATLASSIAN ENV - Safe loading of local credentials (Jira and Confluence)
# =============================================================================
# Looks for the untracked .env in this order and loads the first one found:
#   1. $ATLASSIAN_ENV_FILE (when set)
#   2. <repository root>/.env
#   3. ~/rules/.env (copy installed by scripts/sync_global.sh)
#
# The file is parsed as plain KEY=VALUE lines (optionally prefixed with
# `export`, values optionally quoted, trailing `# comments` allowed). It is
# never sourced, so it cannot run code. Variables are set in the current shell
# but not exported, so child processes do not inherit the credentials through
# their environment. Values already set in the shell take precedence.
# Nothing read from the file is ever printed.
# =============================================================================

ATLASSIAN_ENV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATLASSIAN_REPO_ROOT="$(cd "$ATLASSIAN_ENV_SCRIPT_DIR/../.." && pwd)"

# Print the permission bits of a file (BSD and GNU stat).
_atlassian_file_mode() {
    stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null
}

# Parse a KEY=VALUE file into shell variables without executing it.
_atlassian_load_env() {
    local file="$1" line key value
    local re_assign='^([A-Za-z_][A-Za-z0-9_]*)=(.*)$'
    local re_dquote='^"([^"]*)"'
    local re_squote="^'([^']*)'"
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#"${line%%[![:space:]]*}"}"
        [[ -z "$line" || "$line" == \#* ]] && continue
        line="${line#export }"
        [[ "$line" =~ $re_assign ]] || continue
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        if [[ "$value" =~ $re_dquote ]]; then
            value="${BASH_REMATCH[1]}"
        elif [[ "$value" =~ $re_squote ]]; then
            value="${BASH_REMATCH[1]}"
        else
            value="${value%%[[:space:]]#*}"
            value="${value%"${value##*[![:space:]]}"}"
        fi
        [[ -n "${!key+x}" ]] && continue
        printf -v "$key" '%s' "$value"
    done < "$file"
}

ATLASSIAN_ENV_LOADED=""
for _atlassian_candidate in "${ATLASSIAN_ENV_FILE:-}" "$ATLASSIAN_REPO_ROOT/.env" "$HOME/rules/.env"; do
    if [[ -n "$_atlassian_candidate" && -f "$_atlassian_candidate" ]]; then
        case "$(_atlassian_file_mode "$_atlassian_candidate")" in
            600|400) ;;
            *) echo "⚠ $_atlassian_candidate is readable by other users; run: chmod 600 '$_atlassian_candidate'" >&2 ;;
        esac
        _atlassian_load_env "$_atlassian_candidate"
        ATLASSIAN_ENV_LOADED="$_atlassian_candidate"
        break
    fi
done
unset _atlassian_candidate

if [[ -z "$ATLASSIAN_ENV_LOADED" ]]; then
    echo "⚠ No .env found (ATLASSIAN_ENV_FILE, $ATLASSIAN_REPO_ROOT/.env or ~/rules/.env); copy .env.example to .env" >&2
fi
