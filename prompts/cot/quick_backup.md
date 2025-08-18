---
domain: backups
task: respaldo rápido en el mismo directorio (quick backup)
Dificultad: muy baja
longitud_objetivo: muy corta
validacion: archivo_YYYY-MM-DD.ext.bkp generado junto al original
---

Razonamiento:
- Para archivos pequeños de texto, basta un respaldo local inmediato sin compresión ni checksum.
- Mantener la convención de fecha en CST (YYYY-MM-DD) y el sufijo .bkp.
- Referencia: «~/rules/BACKUPS.md» (sección de respaldo rápido) y script «~/rules/scripts/quick_bkp.sh».

Pasos:
1) Acción: identificar los archivos a respaldar (en el directorio actual).
   Resultado: p. ej., `archivo.txt`.
2) Acción: ejecutar respaldo rápido usando fecha CST.
   Resultado: `bash ~/rules/scripts/quick_bkp.sh archivo.txt` (puede aceptar varios archivos).
3) Acción: validar que existe el backup junto al original.
   Resultado: `ls -1 archivo_$(TZ=America/Mexico_City date +"%Y-%m-%d").txt.bkp`.
4) (Opcional) Acción: repetir para múltiples archivos en un solo comando.
   Resultado: `bash ~/rules/scripts/quick_bkp.sh *.md`.

Conclusión:
- El respaldo queda como `nombre_YYYY-MM-DD.ext.bkp` en el mismo directorio.
- Restauración manual: copiar/renombrar el .bkp al nombre original cuando se requiera.

