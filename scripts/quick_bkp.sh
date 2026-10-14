#!/usr/bin/env bash
# quick_bkp.sh
# Quick backup in the same directory: file -> file_YYYY-MM-DD.ext.bkp (CST date).
# An existing backup from the same day is never overwritten; use backup_file.sh
# for timestamped backups.
# Usage: quick_bkp.sh <file1> [file2 ...]

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <file1> [file2 ...]" >&2
  exit 1
fi

DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
status=0

for SRC in "$@"; do
  if [ ! -f "$SRC" ]; then
    echo "Not a regular file: $SRC" >&2
    status=1
    continue
  fi
  DIR=$(dirname "$SRC")
  FILE=$(basename "$SRC")

  # A leading dot is part of the name (.bashrc has no extension; .config.yaml does).
  if [[ "${FILE#.}" == *.* ]]; then
    OUT="$DIR/${FILE%.*}_${DATE_CST}.${FILE##*.}.bkp"
  else
    OUT="$DIR/${FILE}_${DATE_CST}.bkp"
  fi

  if [ -e "$OUT" ]; then
    echo "Backup already exists, not overwriting: $OUT" >&2
    status=1
    continue
  fi
  cp -a -- "$SRC" "$OUT"
  echo "Backup: $OUT"
done

exit "$status"
