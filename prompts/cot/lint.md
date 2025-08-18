<!-- markdownlint-disable MD041 -->
---
domain: workflow
task: corregir errores de lint Markdown (markdownlint-cli2) en este repositorio
dificultad: media
longitud_objetivo: media
validacion: errores reducidos significativamente tras aplicar correcciones y re-ejecutar linter
---

Razonamiento:
- Priorizar correcciones mecánicas de alto impacto (espacios alrededor de encabezados/listas: MD022/MD032; cercas y lenguajes: MD031/MD040; prefijos de listas ordenadas: MD029).
- Mantener consistencia con la configuración actual (.markdownlint.yaml con MD013 desactivado y excepciones en CHANGELOG).
- Evitar cambios semánticos del contenido; limitarse a formato Markdown.
- Usar ejecución no interactiva para medir avance entre iteraciones.

Pasos:
1) Acción: ejecutar el linter para establecer la línea base.
   Resultado:
   - `npx markdownlint-cli2 "**/*.md" "#node_modules"`
   - Guardar resumen (errores totales y reglas predominantes) para comparar.

2) Acción: corregir MD022/MD032 (líneas en blanco) en archivos prioritarios.
   Resultado:
   - Objetivo: docs/LINGUISTICS.md, docs/GIT.md, docs/TEACHING.md, PROMPTS.md, docs/ROADMAP.md, README.md.
   - Regla práctica: añadir una línea en blanco después de cada encabezado y antes/después de listas.

3) Acción: corregir MD031/MD040 (cercas de código y lenguaje).
   Resultado:
   - Añadir una línea en blanco antes y después de cada bloque ```.
   - Especificar lenguaje (bash, text, yaml) cuando corresponda.

4) Acción: normalizar listas ordenadas (MD029) al estilo 1/1/1.
   Resultado:
   - Reescribir prefijos de listas numeradas como `1.` de forma consistente en pasos y procedimientos.

5) Acción: convertir bare URLs problemáticas (MD034) a enlaces con texto.
   Resultado:
   - Ejemplos: DOI/arXiv → `[arXiv:2201.11903](https://arxiv.org/abs/2201.11903)`; correos → `mailto:` si aplica.

6) Acción (acotada): manejar casos especiales.
   Resultado:
   - CHANGELOG.md ya ignora MD022/MD032/MD013/MD024 (no cambiar contenido, sólo mantener cabecera de excepciones).
   - systemd/backups/README.md: resolver múltiples H1 (MD025) fusionando en un H1 y el resto como H2/H3; para literales como `backup@.service`, presentarlos dentro de código inline o listas con contexto para evitar MD034.
   - “Elaborado por …” (MD036): o convertir a subtítulo “Créditos” o desactivar MD036 al final con comentario local si se desea mantener el estilo.

7) Acción: re-ejecutar el linter y medir mejoras.
   Resultado:
   - `npx markdownlint-cli2 "**/*.md" "#node_modules"`
   - Comparar errores: esperar reducción notable en MD022/MD032, MD031/MD040, MD029, MD034.

8) Acción (opcional): ejecutar verificador de enlaces.
   Resultado:
   - `npx markdown-link-check -q -c .markdownlinkcheck.json "**/*.md"`
   - Revisar enlaces quebrados y actualizar referencias internas si fuera necesario.

Conclusión:
- El conjunto de correcciones mecánicas debe reducir sustancialmente los errores del linter y dejar pendientes mínimos.
- Si persisten avisos específicos (p. ej., MD036 en pies de página), decidir si ajustar el contenido o documentar una excepción local por archivo.
- Referencias: «~/rules/.markdownlint.yaml», «~/rules/CHANGELOG.md», «~/rules/README.md».

