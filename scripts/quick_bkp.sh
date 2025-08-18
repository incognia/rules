#!/usr/bin/env bash
# quick_bkp.sh
# Respaldo simple y rápido en el mismo directorio: archivo -> archivo_YYYY-MM-DD.ext.bkp
# Uso: quick_bkp.sh <archivo1> [archivo2 ...]

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: $0 <archivo1> [archivo2 ...]" >&2
  exit 1
fi

DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")

for SRC in "$@"; do
  if [ ! -f "$SRC" ]; then
    echo "No es un archivo regular: $SRC" >&2
    continue
  fi
  DIR=$(dirname "$SRC")
  FILE=$(basename "$SRC")
  NAME_NO_EXT="${FILE%.*}"
  EXT="${FILE##*.}"

  if [ "$FILE" = "$EXT" ]; then
    # Sin extensión
    OUT="$DIR/${FILE}_${DATE_CST}.bkp"
  else
    OUT="$DIR/${NAME_NO_EXT}_${DATE_CST}.${EXT}.bkp"
  fi

  cp -a -- "$SRC" "$OUT"
  echo "Backup: $OUT"

done

