---
domain: backups
task: restaurar respaldo y validar integridad
dificultad: baja
longitud_objetivo: corta
validacion: archivo o carpeta restaurados, checksum verificado y log actualizado
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Verificar la integridad antes de restaurar (`sha256sum -c`) cuando exista `.sha256`.
- Restaurar conservando permisos cuando aplique; validar el resultado.
- Registrar las acciones con *timestamps* en CST.
- Referencia: «~/rules/rulesets/BACKUPS.md» (sección Restauración y Verificación).

Pasos:

1) Acción: localizar el respaldo (`.bkp`, `.tar.zst`) y su `.sha256` (si existe).
   Resultado: rutas definidas, por ejemplo, `BKP=backups/daily/2025-08-18/mi_carpeta_2025-08-18T12-00-00.tar.zst`.
2) Acción: verificación previa.
   Resultado:
   - Si hay `.sha256` (se genera para respaldos de 100 MB o más): `sha256sum -c "$BKP.sha256"`
   - Si no hay: opcionalmente, calcularlo a mano y documentarlo: `sha256sum "$BKP"` (recomendado si se sospecha corrupción)
3) Acción: restaurar.
   Resultado:
   - Archivo `.bkp`: `cp "$BKP" ./archivo_restaurado.ext` (renombrar según corresponda)
   - `.tar.zst`: `unzstd -c "$BKP" | tar -xvf - -C /ruta/destino`
4) Acción: validación posterior.
   Resultado:
   - Si era archivo: `sha256sum ./archivo_restaurado.ext` (comparar)
   - Si era `.tar.zst`: inspección previa con `tar -tvf` y verificación por muestreo, o con *checksums* internos si se generaron.
5) Acción: registro en el *log*.
   Resultado: `echo "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S') | restore | $BKP | ok" >> backups/backup.log`.

Conclusión:

- Restauración completada y validada; registro actualizado con fecha y hora CST.
- Referencias: «~/rules/rulesets/BACKUPS.md» y *scripts* «~/rules/scripts/*».
