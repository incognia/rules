# Backups

# Genera nombre por convención y resguarda archivo o directorio con checksum y log
# Uso: backup_file.sh <ruta_origen> [directorio_respaldo]

set -euo pipefail

SRC=${1:?"Falta ruta de origen"}
DEST=${2:-backups}
TS=$(TZ=America/Mexico_City date +"%Y-%m-%dT%H-%M-%S")
LOGFILE=${BACKUP_LOG_FILE:-$DEST/backup.log}
mkdir -p "$DEST"

log() { printf "%s | %s\n" "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOGFILE"; }

if [ -d "$SRC" ]; then
  base=$(basename "$SRC")
  tar -cf - -C "$(dirname "$SRC")" "$base" | zstd -T0 -19 -o "$DEST/${base}_${TS}.tar.zst"
  (cd "$DEST" && sha256sum "${base}_${TS}.tar.zst" > "${base}_${TS}.tar.zst.sha256")
  log "backup | $DEST/${base}_${TS}.tar.zst | ok | $(awk '{print $1}' "$DEST/${base}_${TS}.tar.zst.sha256")"
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
  (cd "$DEST" && sha256sum "$(basename "$out")" > "$(basename "$out").sha256")
  log "backup | $out | ok | $(awk '{print $1}' "$DEST/$(basename "$out").sha256")"
else
  echo "Origen no encontrado: $SRC" >&2; exit 1
fi

