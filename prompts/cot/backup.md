---
domain: backups
task: realizar respaldo (archivo o directorio) con checksum y log en CST
Dificultad: baja
longitud_objetivo: corta
validacion: respaldo creado, checksum generado y verificado, entrada en log
---

Razonamiento:
- Usar siempre CST CDMX para timestamps (TZ=America/Mexico_City) y registrar acciones.
- Generar checksum (.sha256) para integridad.
- Para directorios, empaquetar y comprimir con zstd para eficiencia.
- Referencia: «~/rules/BACKUPS.md» (restauración, verificación, compresión, rsync incrementales).

Pasos:
1) Acción: decidir qué respaldar (archivo o directorio) y destino.
   Resultado: variables definidas, p. ej. SRC=./mi_carpeta DEST=backups/daily.
2) Acción: crear (si aplica) carpeta del día en CST.
   Resultado:
   - `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`
   - `mkdir -p "$DEST/$DATE_CST"`
3) Acción: ejecutar respaldo básico con script.
   Resultado:
   - Directorio: `bash ~/rules/scripts/backup_file.sh "$SRC" "$DEST/$DATE_CST"`
   - Archivo: `bash ~/rules/scripts/backup_file.sh ./archivo.txt "$DEST/$DATE_CST"`
4) Acción: verificar checksum.
   Resultado: `find "$DEST/$DATE_CST" -maxdepth 1 -name "*.sha256" -exec sha256sum -c {} \;`
5) (Opcional) Acción: snapshot incremental de un árbol con rsync.
   Resultado: `bash ~/rules/scripts/backup_rsync_snapshot.sh "/ruta/datos" "backups/daily"`
6) Acción: registrar/ver log en CST.
   Resultado: revisar/usar `$DEST/backup.log` (o `$BACKUP_LOG_FILE`).

Conclusión:
- Copia creada y verificada; log registra la operación en CST.
- Referencias: «~/rules/BACKUPS.md» y scripts en «~/rules/scripts/».

