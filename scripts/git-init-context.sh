#!/usr/bin/env bash
set -euo pipefail

# git-init-context.sh
# Configures a new repository for SSH (never HTTPS) with the right identity.
#
# Non-interactive (same arguments as the /git-init skill):
#   git-init-context.sh <personal|laboral> [key_name] [remote_url] [branch]
#     key_name    SSH key in ~/.ssh/ (default: incognia for personal, kone for laboral);
#                 a value containing / is used as a path
#     remote_url  SSH URL for origin (git@host:org/repo.git or ssh://...); optional
#     branch      default branch (default: main)
#   Example: git-init-context.sh personal incognia git@github.com:incognia/repo.git main
#
# Interactive: run it without arguments and answer the prompts.
#
# Steps: git init (when the directory is not a repository yet), user.name and
# user.email, core.sshCommand with the key, default branch, and origin.

usage() {
  sed -n '7,13p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

CONTEXT="" KEY_NAME="" REMOTE_URL="" BRANCH=""

if [ "$#" -gt 0 ]; then
  [ "$#" -le 4 ] || usage
  CONTEXT="$1"
  KEY_NAME="${2:-}"
  REMOTE_URL="${3:-}"
  BRANCH="${4:-}"
else
  read -rp "Repository type? [p] Personal / [l] Work (Kabat One) [p]: " answer
  case "${answer:-p}" in
    p|P) CONTEXT="personal" ;;
    l|L) CONTEXT="laboral" ;;
    *) echo "Invalid option. Use 'p' or 'l'." >&2; exit 1 ;;
  esac
fi

case "$CONTEXT" in
  personal)
    NAME="Rodrigo Álvarez"
    EMAIL="incognia@gmail.com"
    DEFAULT_KEY="incognia"
    ORG="incognia"
    ;;
  laboral)
    NAME="Rodrigo Álvarez"
    EMAIL="ralvarez@kabatone.com"
    DEFAULT_KEY="kone"
    ORG="incogniadev"
    ;;
  *)
    echo "Invalid context '$CONTEXT'. Use 'personal' or 'laboral'." >&2
    usage
    ;;
esac

if [ "$#" -eq 0 ]; then
  read -rp "SSH key name in ~/.ssh/ [$DEFAULT_KEY]: " KEY_NAME
  read -rp "Default branch [main]: " BRANCH
  read -rp "Configure 'origin' now? [y/N]: " set_origin
  if [[ "${set_origin:-N}" =~ ^[yYsS]$ ]]; then
    read -rp "Platform [1] GitHub / [2] GitLab [1]: " platform
    read -rp "Repository name (without organisation): " repo
    [ -n "${repo:-}" ] || { echo "A repository name is required." >&2; exit 1; }
    case "${platform:-1}" in
      1) REMOTE_URL="git@github.com:${ORG}/${repo}.git" ;;
      2) REMOTE_URL="git@gitlab.com:${ORG}/${repo}.git" ;;
      *) echo "Invalid platform; use 1 or 2." >&2; exit 1 ;;
    esac
  fi
fi

KEY_NAME="${KEY_NAME:-$DEFAULT_KEY}"
BRANCH="${BRANCH:-main}"
case "$KEY_NAME" in
  */*) KEY="$KEY_NAME" ;;
  *) KEY="$HOME/.ssh/$KEY_NAME" ;;
esac

if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
  echo "Invalid branch name: $BRANCH" >&2
  exit 1
fi
if [ -n "$REMOTE_URL" ] && [[ ! "$REMOTE_URL" =~ ^(git@|ssh://) ]]; then
  echo "The remote must be an SSH URL (git@host:org/repo.git or ssh://...), not: $REMOTE_URL" >&2
  exit 1
fi

# --- Repository: initialise here, or require the root of an existing one ---
if top=$(git rev-parse --show-toplevel 2>/dev/null); then
  if [ "$(cd "$top" && pwd -P)" != "$(pwd -P)" ]; then
    echo "Run this from the repository root ($top), not from a subdirectory." >&2
    exit 1
  fi
else
  git init
fi

# --- Identity ---
git config user.name "$NAME"
git config user.email "$EMAIL"

# --- SSH key forced for this repository ---
if [ ! -f "$KEY" ]; then
  echo "WARNING: SSH key not found: $KEY (available keys: ls ~/.ssh/)" >&2
fi
git config core.sshCommand "ssh -i $(printf '%q' "$KEY") -o IdentitiesOnly=yes"

# --- Default branch ---
if git rev-parse --verify -q HEAD >/dev/null; then
  git branch -M "$BRANCH"
else
  # No commits yet: point HEAD at the new branch name.
  git symbolic-ref HEAD "refs/heads/$BRANCH"
fi

# --- Remote ---
if [ -n "$REMOTE_URL" ]; then
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REMOTE_URL"
  else
    git remote add origin "$REMOTE_URL"
  fi
fi

echo "=== CONFIGURATION ==="
echo "Identity: $(git config user.name) <$(git config user.email)>"
echo "SSH:      $(git config core.sshCommand)"
echo "Remote:   $(git remote get-url origin 2>/dev/null || echo '(not configured)')"
echo "Branch:   $(git symbolic-ref --short HEAD)"
echo "====================="
