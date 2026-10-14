---
domain: workflow
task: corregir errores de lint Markdown (markdownlint-cli2) en este repositorio
dificultad: media
longitud_objetivo: media
validacion: errores reducidos significativamente tras aplicar correcciones y re-ejecutar linter
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Priorizar correcciones mecánicas de alto impacto (espacios alrededor de encabezados/listas: MD022/MD032; cercas y lenguajes: MD031/MD040; prefijos de listas ordenadas: MD029).
- Mantener consistencia con la configuración actual: reglas en `.markdownlint.yaml` (MD013 desactivado, MD029 con estilo `ordered`) y opciones de `markdownlint-cli2` (exclusiones) en `.markdownlint-cli2.yaml`; el CHANGELOG tiene sus propias excepciones.
- Evitar cambios semánticos del contenido; limitarse a formato Markdown.
- Usar ejecución no interactiva para medir avance entre iteraciones.

Pasos:

1) Acción: ejecutar el linter para establecer la línea base.
   Resultado:
   - `npm run lint:md`
   - Guardar resumen (errores totales y reglas predominantes) para comparar.

2) Acción: corregir MD022/MD032 (líneas en blanco) en archivos prioritarios.
   Resultado:
   - Objetivo: los archivos que reporte el paso 1, empezando por README.md, AGENTS.md y `rulesets/*.md`.
   - Regla práctica: añadir una línea en blanco después de cada encabezado y antes/después de listas.

3) Acción: corregir MD031/MD040 (cercas de código y lenguaje).
   Resultado:
   - Añadir una línea en blanco antes y después de cada bloque ```.
   - Especificar lenguaje (bash, text, yaml) cuando corresponda.

4) Acción: normalizar listas ordenadas (MD029) al estilo `ordered` que define `.markdownlint.yaml`.
   Resultado:
   - Numerar las listas de forma consecutiva (`1.`, `2.`, `3.`) en pasos y procedimientos.

5) Acción: convertir bare URLs problemáticas (MD034) a enlaces con texto.
   Resultado:
   - Ejemplos: DOI/arXiv → `[arXiv:2201.11903](https://arxiv.org/abs/2201.11903)`; correos → `mailto:` si aplica.

6) Acción (acotada): manejar casos especiales.
   Resultado:
   - CHANGELOG.md ya ignora MD022/MD032/MD013/MD024 (no cambiar contenido, sólo mantener cabecera de excepciones).
   - Documentos con varios H1 (MD025): fusionar en un solo H1 y pasar el resto a H2 o H3; para literales como `backup@.service`, usar código en línea para evitar MD034.
   - «Elaborado por …» (MD036): la regla está desactivada en `.markdownlint.yaml`, así que el pie en cursiva no requiere cambios.

7) Acción: re-ejecutar el linter y medir mejoras.
   Resultado:
   - `npm run lint:md`
   - Comparar errores: esperar reducción notable en MD022/MD032, MD031/MD040, MD029, MD034.

8) Acción (opcional): ejecutar verificador de enlaces.
   Resultado:
   - `npm run check:links`
   - Revisar enlaces quebrados y actualizar referencias internas si fuera necesario.

Conclusión:

- El conjunto de correcciones mecánicas debe reducir sustancialmente los errores del linter y dejar pendientes mínimos.
- Si persisten avisos específicos (p. ej., MD036 en pies de página), decidir si ajustar el contenido o documentar una excepción local por archivo.
- Referencias: «~/rules/.markdownlint.yaml», «~/rules/.markdownlint-cli2.yaml», «~/rules/package.json» (*scripts* `lint:md` y `check:links`) y «~/rules/README.md».
