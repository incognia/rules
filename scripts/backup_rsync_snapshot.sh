#!/usr/bin/env bash
# Daily incremental snapshot with rsync --link-dest: unchanged files are
# hard links to the latest previous snapshot, so each day costs only the delta.
# Usage: backup_rsync_snapshot.sh <source_dir> [dest_dir]
# Log: $BACKUP_LOG_FILE, or <dest_dir>/backup.log by default.

set -euo pipefail

SRC=${1:?"Missing source_dir. Usage: backup_rsync_snapshot.sh <source_dir> [dest_dir]"}
DEST=${2:-backups/daily}
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")

[ -d "$SRC" ] || { echo "Source directory not found: $SRC" >&2; exit 1; }
mkdir -p "$DEST"
DEST_ABS=$(cd "$DEST" && pwd)
SNAP="$DEST_ABS/$DATE_CST"
LOG=${BACKUP_LOG_FILE:-$DEST_ABS/backup.log}

# Find the latest previous snapshot BEFORE creating today's, excluding today.
LAST=""
for dir in "$DEST_ABS"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  [ "$name" = "$DATE_CST" ] && continue
  # The glob expands in lexical order, which is chronological for YYYY-MM-DD.
  LAST="$name"
done

mkdir -p "$SNAP"
if [ -n "$LAST" ]; then
  # --link-dest must be absolute: a relative path is resolved from the destination.
  rsync -a --delete --link-dest="$DEST_ABS/$LAST" "$SRC/" "$SNAP/"
  mode="incremental from $LAST"
else
  rsync -a --delete "$SRC/" "$SNAP/"
  mode="full"
fi

mkdir -p "$(dirname "$LOG")"
echo "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S') | snapshot | $SNAP | $mode" | tee -a "$LOG"
