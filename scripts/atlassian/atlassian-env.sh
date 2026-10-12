#!/bin/bash

# =============================================================================
# ATLASSIAN ENV - Carga segura de credenciales locales (Jira y Confluence)
# =============================================================================
# Busca el .env no versionado en este orden:
#   1. $ATLASSIAN_ENV_FILE (si está definido)
#   2. <raíz del repositorio>/.env
#   3. ~/rules/.env (copia sincronizada por scripts/sync_global.sh)
# =============================================================================

ATLASSIAN_ENV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATLASSIAN_REPO_ROOT="$(cd "$ATLASSIAN_ENV_SCRIPT_DIR/../.." && pwd)"

for candidate in "${ATLASSIAN_ENV_FILE:-}" "$ATLASSIAN_REPO_ROOT/.env" "$HOME/rules/.env"; do
    if [[ -n "$candidate" && -f "$candidate" ]]; then
        # shellcheck disable=SC1090
        source "$candidate"
        break
    fi
done
