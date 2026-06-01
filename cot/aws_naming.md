---
domain: aws
task: normalización de nombres de assets para S3 y CloudFront
dificultad: intermedia
longitud_objetivo: media
validacion: nombres resultantes contienen solo caracteres seguros, extensiones normalizadas y registro .tsv generado
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Normalizar nombres de archivos para que sean 100% seguros como *Object Keys* en Amazon S3 y distribuibles vía Amazon CloudFront.
- Aplicar reglas estrictas de AWS: *case sensitivity*, eliminación de espacios, filtrado de caracteres no seguros, validación de rutas y longitud.
- Normalizar extensiones de imagen y recurso web (.jpeg → .jpg, .png, .svg, .ico) para consistencia en el *bucket*.
- Generar un archivo de registro (.tsv) con la relación nombre original → nombre normalizado para trazabilidad.
- Referencias de estilo y flujo: «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)), «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

Pasos:
1) Acción: convertir todo el nombre de archivo y extensión a minúsculas.
   Resultado: los *Object Keys* en S3 son sensibles a mayúsculas [1] y los patrones de caché de CloudFront también (`*.jpg` no aplica para `LOGO.JPG`) [2].

2) Acción: reemplazar todos los espacios en blanco por guiones medios (`-`).
   Resultado: se evitan problemas con codificación URL (`%20`) y secuencias de espacios múltiples que AWS advierte pueden perderse [3, 4, 5].

3) Acción: eliminar acentos (ñ → n) y conservar únicamente caracteres seguros: `a-z`, `0-9`, `-`, `_` y `.` (solo para extensión).
   Resultado: se eliminan caracteres No-ASCII y símbolos que requieren manejo especial (`&`, `$`, `@`, `~`, etc.) [6, 7, 8, 9, 10].

4) Acción: normalizar extensiones de archivo según la siguiente tabla.
   - `.jpeg` → `.jpg`
   - `.png` → `.png` (sin cambio)
   - `.svg` → `.svg` (sin cambio)
   - `.ico` → `.ico` (sin cambio)
   - Extensiones en mayúsculas ya se resuelven en el paso 1 (`.PNG` → `.png`, `.JPEG` → `.jpeg` → `.jpg`).
   Resultado: extensiones consistentes y predecibles para políticas de caché en CloudFront y reglas de *Content-Type* en S3.

5) Acción: verificar que el nombre no contenga puntos consecutivos ni secuencias de ruta relativa (`../`, `./`).
   Resultado: se evitan comportamientos inesperados por interpretación de directorios [7, 12]. El punto solo aparece antes de la extensión final.

6) Acción: validar que la ruta resultante no exceda 255 caracteres (límite de CloudFront [2]; el límite de S3 es 1,024 bytes [13]).
   Resultado: si excede, truncar el nombre conservando la extensión e indicar advertencia.

7) Acción: registrar cada transformación en un archivo `.tsv` con formato `original\tnormalizado`.
   - Nombre del archivo: `normalizacion_YYYYMMDD.tsv` (fecha CST: `TZ=America/Mexico_City date +"%Y%m%d"`).
   - Primera línea: encabezados `original\tnormalizado`.
   - Una línea por archivo procesado, incluyendo los que no requirieron cambios.
   Resultado: archivo de registro que permite auditoría y reversión de los renombramientos.

Conclusión:
- Los nombres resultantes solo contienen caracteres seguros para S3/CloudFront: minúsculas, dígitos, guiones medios, guiones bajos y un punto antes de la extensión normalizada.
- El archivo `normalizacion_YYYYMMDD.tsv` documenta cada transformación para trazabilidad completa.
