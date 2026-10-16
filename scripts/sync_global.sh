#!/usr/bin/env bash
#
# sync_global.sh — Install the repository's skills, Warp workflows and rules
# into the global locations each tool reads.
#
# Usage (always from a clone; piping it from curl is not supported):
#   ./scripts/sync_global.sh          # from the root of the clone
#   ~/rules/scripts/sync_global.sh    # from any directory
#
# What it does:
#   1. Mirrors every .agents/skills/<name>/ into the global skills directory
#      (files deleted inside a skill are pruned) and removes skills it
#      installed earlier that no longer exist in the repository.
#   2. Symlinks ~/.claude/commands/<name>.md to each installed SKILL.md, only
#      for skills from this repository, never overwriting a command it does
#      not own, and removes dangling links into the skills directory.
#   3. When Antigravity CLI is installed, symlinks each installed skill
#      directory into ~/.gemini/antigravity-cli/skills/ (it does not read
#      ~/.agents/skills) and removes dangling links there.
#   4. Copies .warp/workflows/*.yaml to Warp's workflow directory and removes
#      workflows it installed earlier that no longer exist in the repository.
#   5. When the clone is not ~/rules itself, copies cot/, rulesets/,
#      templates/ and scripts/atlassian/ to ~/rules, plus .env with mode 600.
#
# Author: Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Licence: GNU General Public License v3.0 (GPLv3)

set -Eeuo pipefail

trap 'echo "✗ Synchronisation aborted: command failed at line $LINENO." >&2' ERR

die() {
    echo "Error: $*" >&2
    exit 1
}

# --- Locate the repository from the script's own path ---
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
if [ ! -f "$SCRIPT_PATH" ]; then
    die "this script must be run from a clone of the repository, not piped from curl.
  git clone git@github.com:incognia/rules.git ~/rules && ~/rules/scripts/sync_global.sh"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$REPO_ROOT/.agents/skills" ] || [ ! -d "$REPO_ROOT/.warp/workflows" ] ||
    [ ! -f "$REPO_ROOT/scripts/sync_global.sh" ]; then
    die "$REPO_ROOT does not look like a clone of the rules repository.
  git clone git@github.com:incognia/rules.git ~/rules && ~/rules/scripts/sync_global.sh"
fi

# --- Detect platform ---
case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
            PLATFORM="wsl"
        else
            PLATFORM="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
    *) PLATFORM="unknown" ;;
esac

echo "Platform: $PLATFORM"
echo "Repository: $REPO_ROOT"
echo ""

# Mirror a directory: the destination ends up identical to the source,
# including hidden files, and files removed from the source are deleted.
mirror_dir() {
    local src="$1" dst="$2" tmp
    if command -v rsync >/dev/null 2>&1; then
        mkdir -p "$dst"
        rsync -a --delete "$src/" "$dst/"
    else
        tmp="$(mktemp -d "$(dirname "$dst")/.sync.XXXXXX")"
        cp -R "$src/." "$tmp/"
        rm -rf "$dst"
        mv "$tmp" "$dst"
    fi
}

# --- Skills ---
SKILLS_SRC="$REPO_ROOT/.agents/skills"

# On WSL the skills go to the Windows home, where Warp reads them.
if [ "$PLATFORM" = "wsl" ]; then
    WIN_PROFILE="$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')" ||
        die "could not read %USERPROFILE% through cmd.exe"
    [ -n "$WIN_PROFILE" ] || die "empty %USERPROFILE% from cmd.exe"
    WIN_HOME="$(wslpath "$WIN_PROFILE")"
    SKILLS_DST="$WIN_HOME/.agents/skills"
else
    SKILLS_DST="$HOME/.agents/skills"
fi

echo "=== Skills ==="
mkdir -p "$SKILLS_DST"
MANAGED_SKILLS_FILE="$SKILLS_DST/.rules-managed-skills"

# Legacy skills that were renamed or removed before the managed list existed.
for legacy in changelog cad-access; do
    if [ -e "$SKILLS_DST/$legacy" ] && [ ! -d "$SKILLS_SRC/$legacy" ]; then
        rm -rf "${SKILLS_DST:?}/$legacy"
        echo "  - removed legacy skill: $legacy"
    fi
done

# Remove skills installed earlier by this script that left the repository.
if [ -f "$MANAGED_SKILLS_FILE" ]; then
    while IFS= read -r managed_skill || [ -n "$managed_skill" ]; do
        [ -z "$managed_skill" ] && continue
        case "$managed_skill" in */*|.|..) continue ;; esac
        if [ ! -d "$SKILLS_SRC/$managed_skill" ] && [ -e "$SKILLS_DST/$managed_skill" ]; then
            rm -rf "${SKILLS_DST:?}/$managed_skill"
            echo "  - removed obsolete skill: $managed_skill"
        fi
    done < "$MANAGED_SKILLS_FILE"
fi

TMP_MANAGED_SKILLS_FILE="$(mktemp "$SKILLS_DST/.rules-managed-skills.XXXXXX")"
SKILL_COUNT=0
for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    mirror_dir "${skill_dir%/}" "$SKILLS_DST/$skill_name"
    printf '%s\n' "$skill_name" >> "$TMP_MANAGED_SKILLS_FILE"
    SKILL_COUNT=$((SKILL_COUNT + 1))
    echo "  ✓ $skill_name"
done
mv "$TMP_MANAGED_SKILLS_FILE" "$MANAGED_SKILLS_FILE"
echo "  $SKILL_COUNT skills synchronised → $SKILLS_DST"
echo ""

# --- Claude Code ---
# ~/.claude/commands/<name>.md → installed SKILL.md, so Claude Code exposes
# /<name>. Without this link Claude Code ignored these slash commands. The link
# points at the copy in SKILLS_DST (not at the repository file) to keep the
# validated behaviour.
echo "=== Claude Code ==="

CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

# True when a symlink target lives inside a skills directory this script manages.
points_into_skills() {
    case "$1" in
        "$SKILLS_DST"/*|"$HOME/.agents/skills"/*) return 0 ;;
        *) return 1 ;;
    esac
}

CLAUDE_SKILL_COUNT=0
while IFS= read -r skill_name; do
    [ -z "$skill_name" ] && continue
    skill_src="$SKILLS_DST/$skill_name/SKILL.md"
    skill_link="$CLAUDE_COMMANDS_DIR/$skill_name.md"
    [ -f "$skill_src" ] || continue
    if [ -L "$skill_link" ]; then
        if ! points_into_skills "$(readlink "$skill_link")"; then
            echo "  ! $skill_name.md is a symlink not managed by this script; left untouched"
            continue
        fi
    elif [ -e "$skill_link" ]; then
        echo "  ! $skill_name.md already exists as a regular file; left untouched"
        continue
    fi
    ln -sfn "$skill_src" "$skill_link"
    CLAUDE_SKILL_COUNT=$((CLAUDE_SKILL_COUNT + 1))
    echo "  ✓ $skill_name.md → $skill_src"
done < "$MANAGED_SKILLS_FILE"

# Remove dangling links into the skills directory (skills that were removed).
for link in "$CLAUDE_COMMANDS_DIR"/*.md; do
    [ -L "$link" ] || continue
    if points_into_skills "$(readlink "$link")" && [ ! -e "$link" ]; then
        rm -f "$link"
        echo "  - removed dangling link: $(basename "$link")"
    fi
done
echo "  $CLAUDE_SKILL_COUNT skills linked → $CLAUDE_COMMANDS_DIR"
echo ""

# --- Antigravity CLI ---
# Antigravity CLI (agy) does not read ~/.agents/skills: its global skills live
# in ~/.gemini/antigravity-cli/skills/<name>/ (workspace skills come from the
# repository's .agents/skills/). Each skill directory is symlinked to the
# installed copy, only when Antigravity CLI is installed.
AGY_HOME="$HOME/.gemini/antigravity-cli"
if [ -d "$AGY_HOME" ]; then
    echo "=== Antigravity CLI ==="
    AGY_SKILLS_DIR="$AGY_HOME/skills"
    mkdir -p "$AGY_SKILLS_DIR"

    AGY_SKILL_COUNT=0
    while IFS= read -r skill_name; do
        [ -z "$skill_name" ] && continue
        skill_src="$SKILLS_DST/$skill_name"
        skill_link="$AGY_SKILLS_DIR/$skill_name"
        [ -f "$skill_src/SKILL.md" ] || continue
        if [ -L "$skill_link" ]; then
            if ! points_into_skills "$(readlink "$skill_link")"; then
                echo "  ! $skill_name is a symlink not managed by this script; left untouched"
                continue
            fi
        elif [ -e "$skill_link" ]; then
            echo "  ! $skill_name already exists as a regular directory; left untouched"
            continue
        fi
        ln -sfn "$skill_src" "$skill_link"
        AGY_SKILL_COUNT=$((AGY_SKILL_COUNT + 1))
        echo "  ✓ $skill_name → $skill_src"
    done < "$MANAGED_SKILLS_FILE"

    # Remove dangling links into the skills directory (skills that were removed).
    for link in "$AGY_SKILLS_DIR"/*; do
        [ -L "$link" ] || continue
        if points_into_skills "$(readlink "$link")" && [ ! -e "$link" ]; then
            rm -f "$link"
            echo "  - removed dangling link: $(basename "$link")"
        fi
    done
    echo "  $AGY_SKILL_COUNT skills linked → $AGY_SKILLS_DIR"
    echo ""
fi

# --- Warp workflows (path depends on the platform) ---
WORKFLOWS_SRC="$REPO_ROOT/.warp/workflows"

echo "=== Workflows ==="
case "$PLATFORM" in
    macos)
        WORKFLOWS_DST="$HOME/.warp/workflows"
        ;;
    linux)
        WORKFLOWS_DST="${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/workflows"
        ;;
    windows)
        if [ -n "${APPDATA:-}" ]; then
            WORKFLOWS_DST="$APPDATA/warp/Warp/data/workflows"
        else
            WORKFLOWS_DST="$HOME/.warp/workflows"
            echo "  Note: APPDATA not set, using $WORKFLOWS_DST"
        fi
        ;;
    *)
        # Includes WSL: there is no known Warp workflow path for it.
        WORKFLOWS_DST="$HOME/.warp/workflows"
        echo "  Note: no known Warp workflow path for $PLATFORM, using $WORKFLOWS_DST"
        ;;
esac

mkdir -p "$WORKFLOWS_DST"
MANAGED_WORKFLOWS_FILE="$WORKFLOWS_DST/.rules-managed-workflows"

# Remove workflows installed earlier by this script that left the repository.
if [ -f "$MANAGED_WORKFLOWS_FILE" ]; then
    while IFS= read -r managed_wf || [ -n "$managed_wf" ]; do
        [ -z "$managed_wf" ] && continue
        case "$managed_wf" in */*) continue ;; esac
        if [ ! -f "$WORKFLOWS_SRC/$managed_wf" ] && [ -f "$WORKFLOWS_DST/$managed_wf" ]; then
            rm -f "${WORKFLOWS_DST:?}/$managed_wf"
            echo "  - removed obsolete workflow: $managed_wf"
        fi
    done < "$MANAGED_WORKFLOWS_FILE"
fi

TMP_MANAGED_WORKFLOWS_FILE="$(mktemp "$WORKFLOWS_DST/.rules-managed-workflows.XXXXXX")"
WF_COUNT=0
for wf in "$WORKFLOWS_SRC"/*.yaml; do
    [ -f "$wf" ] || continue
    wf_name="$(basename "$wf")"
    cp "$wf" "$WORKFLOWS_DST/$wf_name"
    printf '%s\n' "$wf_name" >> "$TMP_MANAGED_WORKFLOWS_FILE"
    WF_COUNT=$((WF_COUNT + 1))
    echo "  ✓ $wf_name"
done
mv "$TMP_MANAGED_WORKFLOWS_FILE" "$MANAGED_WORKFLOWS_FILE"
echo "  $WF_COUNT workflows synchronised → $WORKFLOWS_DST"
echo ""

# --- Rules content (cot, rulesets, templates, scripts/atlassian, .env) ---
echo "=== Rules (cot, rulesets, templates, scripts/atlassian, .env) ==="
RULES_GLOBAL_DST="$HOME/rules"

if [ "$REPO_ROOT" = "$(cd "$RULES_GLOBAL_DST" 2>/dev/null && pwd || echo "$RULES_GLOBAL_DST")" ]; then
    echo "  The clone is $RULES_GLOBAL_DST itself; nothing to copy."
elif [ -e "$RULES_GLOBAL_DST/.git" ]; then
    echo "  ! $RULES_GLOBAL_DST is another git checkout; not copying into it (update it with git pull)."
else
    for part in cot rulesets templates scripts/atlassian; do
        mkdir -p "$RULES_GLOBAL_DST/$part"
        cp -R "$REPO_ROOT/$part/." "$RULES_GLOBAL_DST/$part/"
        echo "  ✓ $part → $RULES_GLOBAL_DST/$part"
    done
    if [ -f "$REPO_ROOT/.env" ]; then
        install -m 600 "$REPO_ROOT/.env" "$RULES_GLOBAL_DST/.env"
        echo "  ✓ .env → $RULES_GLOBAL_DST/.env (mode 600, untracked)"
    fi
fi
if [ ! -f "$RULES_GLOBAL_DST/.env" ]; then
    echo "  ⚠ No $RULES_GLOBAL_DST/.env: copy .env.example to .env and fill in the Atlassian credentials"
fi
echo ""

echo "Synchronisation complete."
