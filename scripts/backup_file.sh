#!/usr/bin/env bash
# Backups
# Genera nombre por convención y resguarda archivo o directorio con log en CST.
# Genera checksum solo si el tamaño es >= 100MB (configurable via BACKUP_SHA_THRESHOLD_BYTES)
# Uso: backup_file.sh <ruta_origen> [directorio_respaldo]

set -euo pipefail

SRC=${1:?"Falta ruta de origen"}
DEST=${2:-backups}
TS=$(TZ=America/Mexico_City date +"%Y-%m-%dT%H-%M-%S")
LOGFILE=${BACKUP_LOG_FILE:-$DEST/backup.log}
THRESH=${BACKUP_SHA_THRESHOLD_BYTES:-104857600}
mkdir -p "$DEST"

log() {
  printf "%s | %s\n" "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOGFILE"
}

make_checksum_if_big() {
  local filepath="$1"
  local size
  size=$(stat -c%s "$filepath")
  if [ "$size" -ge "$THRESH" ]; then
    (cd "$(dirname "$filepath")" && sha256sum "$(basename "$filepath")" > "$(basename "$filepath").sha256")
    awk '{print $1}' "${filepath}.sha256"
  else
    echo "SMALL"
  fi
}

if [ -d "$SRC" ]; then
  base=$(basename "$SRC")
  out="$DEST/${base}_${TS}.tar.zst"
  tar -cf - -C "$(dirname "$SRC")" "$base" | zstd -T0 -19 -o "$out"
  sum=$(make_checksum_if_big "$out")
  if [ "$sum" = "SMALL" ]; then
    log "backup | $out | ok | small (no checksum)"
  else
    log "backup | $out | ok | $sum"
  fi
elif [ -f "$SRC" ]; then
  file=$(basename "$SRC")
  name_without_ext="${file%.*}"
  ext="${file##*.}"
  if [ "$file" = "$ext" ]; then
    out="$DEST/${file}_${TS}.bkp"
  else
    out="$DEST/${name_without_ext}_${TS}.${ext}.bkp"
  fi
  cp -a "$SRC" "$out"
  sum=$(make_checksum_if_big "$out")
  if [ "$sum" = "SMALL" ]; then
    log "backup | $out | ok | small (no checksum)"
  else
    log "backup | $out | ok | $sum"
  fi
else
  echo "Origen no encontrado: $SRC" >&2
  exit 1
fi

