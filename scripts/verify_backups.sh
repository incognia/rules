# Verifica checksums de todos los respaldos
# Uso: verify_backups.sh [directorio_backups]

set -euo pipefail

DIR=${1:-backups}
find "$DIR" -type f -name "*.sha256" -print -exec sha256sum -c {} \;

