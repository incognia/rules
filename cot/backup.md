---
domain: backups
task: hacer un respaldo (archivo o carpeta) con checksum y log en CST
dificultad: baja
longitud_objetivo: corta
validacion: respaldo creado, checksum generado y verificado, entrada en log
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Usar siempre CST de la Ciudad de México para los *timestamps* (`TZ=America/Mexico_City`) y registrar las acciones.
- Generar *checksum* (`.sha256`) para verificar la integridad.
- Para directorios, empaquetar y comprimir con zstd para eficiencia.
- Referencia: «~/rules/rulesets/BACKUPS.md» (restauración, verificación, compresión, rsync incrementales).

Pasos:

1) Acción: decidir qué respaldar (archivo o carpeta) y el destino.
   Resultado: variables definidas, por ejemplo, `SRC=./mi_carpeta DEST=backups/daily`.
2) Acción: crear (si aplica) carpeta del día en CST.
   Resultado:
   - `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`
   - `mkdir -p "$DEST/$DATE_CST"`
3) Acción: ejecutar el respaldo básico con el *script*.
   Resultado:
   - Carpeta: `bash ~/rules/scripts/backup_file.sh "$SRC" "$DEST/$DATE_CST"`
   - Archivo: `bash ~/rules/scripts/backup_file.sh ./archivo.txt "$DEST/$DATE_CST"`
4) Acción: verificar el *checksum* (solo si existe `.sha256`; se genera para respaldos de 100 MB o más).
   Resultado: `find "$DEST/$DATE_CST" -maxdepth 1 -name "*.sha256" -exec sha256sum -c {} \;`
5) (Opcional) Acción: *snapshot* incremental de un árbol con rsync.
   Resultado: `bash ~/rules/scripts/backup_rsync_snapshot.sh "/ruta/datos" "backups/daily"`
6) Acción: registrar o consultar el *log* en CST.
   Resultado: revisar `$DEST/backup.log` (o `$BACKUP_LOG_FILE`).

Conclusión:

- Copia creada y verificada; el *log* registra la operación en CST.
- Referencias: «~/rules/rulesets/BACKUPS.md» y *scripts* en «~/rules/scripts/».
