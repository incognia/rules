#!/usr/bin/env bash
set -euo pipefail

# git-init-context.sh
# Asistente interactivo para configurar un repo recién inicializado con SSH (no HTTPS)
# - Configura user.name y user.email
# - Configura core.sshCommand con la clave adecuada
# - Opcionalmente configura origin con URL SSH
# - Define main como rama por defecto si no existe

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Este script debe ejecutarse dentro de un repositorio Git (después de 'git init')." >&2
  exit 1
fi

read -rp "¿Tipo de repositorio? [p] Personal / [l] Laboral (Promad): " REPO_TYPE
REPO_TYPE=${REPO_TYPE:-p}

case "$REPO_TYPE" in
  p|P)
    NAME="Rodrigo Álvarez"
    EMAIL="incognia@gmail.com"
    KEY="${HOME}/.ssh/id_ed25519"
    ORG_GH="incognia"
    ORG_GL="incognia"
    ;;
  l|L)
    NAME="Rodrigo Álvarez"
    EMAIL="ralvarez@promad.com.mx"
    KEY="${HOME}/.ssh/promad_ed25519"
    ORG_GH="incogniadev"
    ORG_GL="incogniadev"
    ;;
  *)
    echo "Opción no válida. Usa 'p' o 'l'." >&2
    exit 1
    ;;
 esac

# Configuración de identidad
git config user.name  "$NAME"
git config user.email "$EMAIL"

# Configurar SSH forzado al repositorio
if [ ! -f "$KEY" ]; then
  echo "ADVERTENCIA: La clave SSH no existe: $KEY" >&2
fi

git config core.sshCommand "ssh -i $KEY -o IdentitiesOnly=yes"

echo "Identidad configurada: $(git config user.name) <$(git config user.email)>"
echo "core.sshCommand configurado a: $(git config core.sshCommand)"

# Rama por defecto main
if ! git symbolic-ref -q HEAD >/dev/null; then
  git checkout -b main >/dev/null 2>&1 || git branch -M main
else
  git branch -M main >/dev/null 2>&1 || true
fi

echo "Rama por defecto: main"

# Configurar remoto opcional
read -rp "¿Configurar 'origin' ahora? [s/N]: " SET_ORIGIN
SET_ORIGIN=${SET_ORIGIN:-N}

if [[ "$SET_ORIGIN" =~ ^[sS]$ ]]; then
  read -rp "Plataforma [1] GitHub / [2] GitLab (1 por defecto): " PLATFORM
  PLATFORM=${PLATFORM:-1}
  read -rp "Nombre del repositorio (sin org): " REPO
  REPO=${REPO:-repo-name}

  case "$PLATFORM" in
    1)
      ORIGIN_URL="git@github.com:${ORG_GH}/${REPO}.git"
      ;;
    2)
      ORIGIN_URL="git@gitlab.com:${ORG_GL}/${REPO}.git"
      ;;
    *)
      echo "Opción inválida, usando GitHub por defecto." >&2
      ORIGIN_URL="git@github.com:${ORG_GH}/${REPO}.git"
      ;;
  esac

  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$ORIGIN_URL"
  else
    git remote add origin "$ORIGIN_URL"
  fi
  echo "Origin configurado: $(git remote get-url origin)"
fi

echo "Listo. Ya puedes usar 'git push' sin HTTPS ni alias SSH."
