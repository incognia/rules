---
domain: backups
task: restaurar respaldo y validar integridad
Dificultad: baja
longitud_objetivo: corta
validacion: archivo/directorio restaurado y checksum verificado, log actualizado
---

Razonamiento:
- Verificar integridad antes de restaurar (sha256sum -c) cuando exista .sha256.
- Restaurar conservando permisos cuando aplique; validar resultado.
- Registrar acciones con timestamps en CST.
- Referencia: «~/rules/BACKUPS.md» (sección Restauración y Verificación).

Pasos:
1) Acción: localizar respaldo (.bkp, .tar.zst) y su .sha256 (si existe).
   Resultado: rutas definidas, p. ej. BKP=backups/daily/2025-08-18/mi_carpeta_2025-08-18T12-00-00.tar.zst.
2) Acción: verificación previa.
   Resultado:
   - Si hay .sha256: `sha256sum -c "$BKP.sha256"`
   - Si no hay: calcular manualmente y documentar: `sha256sum "$BKP"`
3) Acción: restaurar.
   Resultado:
   - Archivo .bkp: `cp "$BKP" ./archivo_restaurado.ext` (renombrar según corresponda)
   - Tar.zst: `unzstd -c "$BKP" | tar -xvf - -C /ruta/destino`
4) Acción: validación posterior.
   Resultado:
   - Si era archivo: `sha256sum ./archivo_restaurado.ext` (comparar)
   - Si era tar.zst: inspección `tar -tvf` previa y verificación por muestreo o checksums internos si se generaron.
5) Acción: registro en log.
   Resultado: `echo "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S') | restore | $BKP | ok" >> backups/backup.log`.

Conclusión:
- Restauración completada y validada; registro actualizado con fecha/hora CST.
- Referencias: «~/rules/BACKUPS.md» y scripts «~/rules/scripts/*».

