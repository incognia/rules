---
name: backup
description: "Backup files or directories following standard naming conventions with CST timestamps and optional checksums. Use this skill before destructive operations."
---

# Backup files and directories

## When to use

Before any destructive operation, or when explicitly asked to create a backup.

## Instructions

1. **Read the full CoT**: Load and follow `cot/backup.md` from line 1 to end
2. **Generate timestamp**: `TS=$(TZ=America/Mexico_City date +"%Y-%m-%dT%H-%M-%S")`
3. **Name the backup**: `[name_without_ext]_[timestamp].[original_ext].bkp`
4. **For files**: `cp source.txt backups/source_${TS}.txt.bkp`
5. **For directories**: `tar --owner=0 --group=0 --numeric-owner -cf - dir/ | zstd -T0 -19 -o "dir_${TS}.tar.zst"`
6. **Checksum** (if >= 100 MB): `sha256sum backup_file > backup_file.sha256`
7. **Verify**: Confirm the backup exists and is readable

## Naming examples

- `archivo.txt` → `archivo_2026-03-27T17-30-00.txt.bkp`
- `config.yaml` → `config_2026-03-27T17-30-00.yaml.bkp`

## Critical rules

- All timestamps use CST (Ciudad de México, UTC-6)
- Never overwrite previous backups
- Checksums (.sha256) required for files >= 100 MB
- Use zstd compression for directories

## References

- Detailed CoT: `cot/backup.md`
- Rules: `rulesets/BACKUPS.md`
- Script: `scripts/backup_file.sh`
