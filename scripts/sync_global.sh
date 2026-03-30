#!/bin/bash
#
# sync_global.sh — Sincronizar skills y workflows globales desde la copia local del repo
#
# Uso:
#   ./scripts/sync_global.sh          # desde la raíz del repo clonado
#   ~/rules/scripts/sync_global.sh    # desde cualquier directorio
#
# También se puede ejecutar directo desde el repo público:
#   bash <(curl -sL https://raw.githubusercontent.com/incognia/rules/main/scripts/sync_global.sh)
#
# Autor: Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Licencia: GNU General Public License v3.0 (GPLv3)

set -uo pipefail

# Detectar la raíz del repo
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verificar que estamos en el repo correcto
if [ ! -d "$REPO_ROOT/.agents/skills" ] || [ ! -d "$REPO_ROOT/.warp/workflows" ]; then
    # Si no se encontró localmente, intentar con ~/rules
    if [ -d "$HOME/rules/.agents/skills" ]; then
        REPO_ROOT="$HOME/rules"
    else
        echo "Error: no se encontró el repositorio rules."
        echo "Clona primero: git clone git@github.com:incognia/rules.git ~/rules"
        exit 1
    fi
fi

# Detectar plataforma
OS="$(uname -s)"
case "$OS" in
    Darwin)  PLATFORM="macos" ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
            PLATFORM="wsl"
        else
            PLATFORM="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)  PLATFORM="windows" ;;
    *)       PLATFORM="unknown" ;;
esac

echo "Plataforma detectada: $PLATFORM"
echo "Repo: $REPO_ROOT"
echo ""

# --- Skills ---
SKILLS_SRC="$REPO_ROOT/.agents/skills"

# En WSL los skills deben ir al home de Windows (donde los lee Warp)
if [ "$PLATFORM" = "wsl" ]; then
    WIN_HOME="$(wslpath "$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')")"
    SKILLS_DST="$WIN_HOME/.agents/skills"
else
    SKILLS_DST="$HOME/.agents/skills"
fi

echo "=== Skills ==="
mkdir -p "$SKILLS_DST"
SKILL_COUNT=0
for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$SKILLS_DST/$skill_name"
    cp -r "$skill_dir"* "$SKILLS_DST/$skill_name/"
    SKILL_COUNT=$((SKILL_COUNT + 1))
    echo "  ✓ $skill_name"
done
echo "  $SKILL_COUNT skills sincronizados → $SKILLS_DST"
echo ""

# --- Workflows (ruta varía por plataforma) ---
WORKFLOWS_SRC="$REPO_ROOT/.warp/workflows"

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
            echo "  Nota: APPDATA no detectado, usando $WORKFLOWS_DST"
        fi
        ;;
    *)
        WORKFLOWS_DST="$HOME/.warp/workflows"
        echo "  Nota: plataforma desconocida, usando $WORKFLOWS_DST"
        ;;
esac

echo "=== Workflows ==="
mkdir -p "$WORKFLOWS_DST"
WF_COUNT=0
for wf in "$WORKFLOWS_SRC"/*.yaml; do
    wf_name="$(basename "$wf")"
    cp "$wf" "$WORKFLOWS_DST/$wf_name"
    WF_COUNT=$((WF_COUNT + 1))
    echo "  ✓ $wf_name"
done
echo "  $WF_COUNT workflows sincronizados → $WORKFLOWS_DST"
echo ""

echo "Sincronización completa."
