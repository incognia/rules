# Snapshot incremental por día con rsync --link-dest
# Uso: backup_rsync_snapshot.sh <source_dir> [dest_dir]

set -euo pipefail

SRC=${1:?"Falta source_dir"}
DEST=${2:-backups/daily}
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
SNAP="$DEST/$DATE_CST"
mkdir -p "$SNAP"

LAST=$(ls -1 "$DEST" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort | tail -n1 || true)
if [ -n "${LAST:-}" ] && [ "$LAST" != "$DATE_CST" ]; then
  rsync -a --delete --link-dest="$DEST/$LAST" "$SRC/" "$SNAP/"
else
  rsync -a --delete "$SRC/" "$SNAP/"
fi

echo "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S') | snapshot | $SNAP" >> "${BACKUP_LOG_FILE:-backups/backup.log}"

