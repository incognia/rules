---
domain: writing
task: aplicar correctamente las reglas de STYLING.md en un documento Markdown corporativo
dificultad: media
longitud_objetivo: media
validacion: encabezado/pie correctos, timestamp CST válido, estructura y estilos conformes a STYLING.md
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Usar español mexicano y formato CoT del repo (ver «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)), «~/rules/rulesets/STYLING.md» ([../rulesets/STYLING.md](../rulesets/STYLING.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md))).
- Recorrer de arriba a abajo: encabezado estándar → contenido → pie de página → CSS → validaciones (timestamps, enlaces, accesibilidad).
- Asegurar consistencia con CST (Ciudad de México) y mermaid donde aplique.

Pasos:
1) Acción: insertar encabezado estándar según «~/rules/STYLING.md» (tags + logo + H1 + timestamp alineado a la derecha).
   Resultado: bloque YAML con tags y bloque de encabezado con logo PROMAD y título H1.
2) Acción: generar y validar timestamp de «Última modificación» en CST (24 h).
   Resultado: `TZ=America/Mexico_City date '+%d de %B de %Y, %H:%M (CST)'` produce, p. ej., «31 de julio de 2025, 11:59 (CST)».
3) Acción: revisar estructura de contenido (H2→H3→H4) y evitar saltos de nivel.
   Resultado: jerarquía clara; títulos en estilo oración y sin punto final.
4) Acción: aplicar reglas de LINGUISTICS a términos y comillas.
   Resultado: «IA», «TI», «computadora», comillas «», préstamos en cursiva.
5) Acción: eliminar separadores `---` innecesarios del cuerpo del documento.
   REGLA CRÍTICA: el único `---` permitido en el documento es el que precede inmediatamente a `## Contacto`. Ninguna sección de contenido (H2, tablas, bloques de código, párrafos) debe estar separada con `---`. Eliminar todos los demás antes de continuar.
   Resultado: cero `---` en el cuerpo; uno solo justo antes del pie de página.
6) Acción: insertar pie de página estándar con separador único, sección de contacto y CSS corporativo.
   Resultado: pie con información de contacto, avatar, colores corporativos y estilos coherentes.
7) Acción: validar enlaces e imágenes.
   Resultado: URLs funcionan; agregar texto alternativo a imágenes.
8) Acción: revisar accesibilidad y responsive.
   Resultado: estilos legibles, contraste suficiente, tablas correctas.
9) Acción: verificar mermaid cuando se requieran diagramas.
   Resultado: bloques ```mermaid conformes; sin ASCII.
10) Acción: validar consistencia con linters.
    Resultado: markdownlint (encabezados/longitud de línea) y Vale (estilo/es_MX) pasan sin errores.

Conclusión:
- Entregar el documento con encabezado/pie correctos, timestamp válido en CST, contenido jerarquizado y estilo consistente.
- Referencias: «~/rules/rulesets/STYLING.md» ([../rulesets/STYLING.md](../rulesets/STYLING.md)), «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

