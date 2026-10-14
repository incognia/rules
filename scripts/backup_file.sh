#!/usr/bin/env bash
# Backups
# Builds the backup name by convention and stores a file or directory, logging in CST.
# A SHA-256 checksum is written only when the backup is >= 100 MB
# (configurable via BACKUP_SHA_THRESHOLD_BYTES).
# Usage: backup_file.sh <source_path> [backup_dir]
# Portable: macOS (BSD) and Linux (GNU).

set -euo pipefail

SRC=${1:?"Missing source path. Usage: backup_file.sh <source_path> [backup_dir]"}
DEST=${2:-backups}
TS=$(TZ=America/Mexico_City date +"%Y-%m-%dT%H-%M-%S")
LOGFILE=${BACKUP_LOG_FILE:-$DEST/backup.log}
THRESH=${BACKUP_SHA_THRESHOLD_BYTES:-104857600}
mkdir -p "$DEST"

log() {
  printf "%s | %s\n" "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOGFILE"
}

# sha256sum on GNU, shasum -a 256 on macOS; both write and check the same format.
sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$@"
  else
    shasum -a 256 "$@"
  fi
}

# File size in bytes without GNU-only stat -c.
file_size() {
  wc -c < "$1" | tr -d '[:space:]'
}

make_checksum_if_big() {
  local filepath="$1" size
  size=$(file_size "$filepath")
  if [ "$size" -ge "$THRESH" ]; then
    (cd "$(dirname "$filepath")" && sha256 "$(basename "$filepath")" > "$(basename "$filepath").sha256")
    awk '{print $1}' "${filepath}.sha256"
  else
    echo "SMALL"
  fi
}

if [ -d "$SRC" ]; then
  base=$(basename "$(cd "$SRC" && pwd)")
  out="$DEST/${base}_${TS}.tar.zst"
  tar -cf - -C "$(dirname "$(cd "$SRC" && pwd)")" "$base" | zstd -q -T0 -19 -o "$out"
elif [ -f "$SRC" ]; then
  file=$(basename "$SRC")
  # A leading dot is part of the name (.bashrc has no extension; .config.yaml does).
  if [[ "${file#.}" == *.* ]]; then
    out="$DEST/${file%.*}_${TS}.${file##*.}.bkp"
  else
    out="$DEST/${file}_${TS}.bkp"
  fi
  cp -a -- "$SRC" "$out"
else
  echo "Source not found: $SRC" >&2
  exit 1
fi

sum=$(make_checksum_if_big "$out")
if [ "$sum" = "SMALL" ]; then
  log "backup | $out | ok | small (no checksum)"
else
  log "backup | $out | ok | $sum"
fi
