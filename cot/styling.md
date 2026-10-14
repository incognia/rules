---
domain: writing
task: aplicar correctamente las reglas de STYLING.md en un documento Markdown corporativo según la plataforma
dificultad: media
longitud_objetivo: media
validacion: encabezado y pie correctos para la plataforma, marca de tiempo CST válida, estructura y estilos conformes a STYLING.md
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Usar español mexicano y formato CoT del repositorio (ver «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)) y «~/rules/rulesets/STYLING.md» ([../rulesets/STYLING.md](../rulesets/STYLING.md))).
- La plataforma decide el encabezado y el pie: los logotipos, la firma y el CSS corporativo son exclusivos de HedgeDoc; GitLab y GitHub no los llevan.
- Recorrer de arriba a abajo: plataforma → encabezado → fecha → contenido → separadores → pie → validaciones.
- Asegurar consistencia con CST (Ciudad de México) y Mermaid donde aplique.

Pasos:

1) Acción: identificar la plataforma (`hedgedoc`, `gitlab` o `github`), el archivo y, si es un README.md de GitLab o GitHub, la licencia (`mit` o `gpl`).
   Resultado: plataforma, archivo y licencia definidos; si falta un dato obligatorio, preguntar.

2) Acción: insertar el encabezado estándar según la plataforma (ver «~/rules/rulesets/STYLING.md»).
   Resultado:
   - HedgeDoc: *frontmatter* con `tags`, logotipos de Kabat One para modo claro y oscuro, y H1.
   - GitLab o GitHub, README.md: *frontmatter* con `title` y `description` (valores entre comillas dobles) y H1; sin logotipos.
   - GitLab o GitHub, otros documentos: solo H1, sin *frontmatter* ni logotipos.

3) Acción: detectar y eliminar campos de fecha reportados existentes antes de insertar la marca de tiempo nueva.
   Validación: localizar y limpiar patrones como `Última modificación:`, `Fecha:`, `Fecha de reporte:` y `[time=...]` para evitar duplicidad.
   Resultado: el documento conserva un solo campo de fecha visible.

4) Acción: generar la marca de tiempo de «Última modificación» en CST (24 horas) con el mes en español.
   Resultado: `LC_TIME=es_MX.UTF-8 TZ=America/Mexico_City date '+%-d de %B de %Y, %H:%M (%Z)'` produce, por ejemplo, «31 de julio de 2025, 11:59 (CST)». Si el sistema no tiene el *locale* `es_MX.UTF-8` (`locale -a`), usar `es_ES.UTF-8` o traducir el mes a mano. La salida ya termina en «(CST)»: insertarla tal cual, sin agregar otro sufijo.

   - HedgeDoc: `<div style="text-align: right;"><em>Última modificación: <marca de tiempo></em></div><br>`
   - GitLab o GitHub: `*Última modificación: <marca de tiempo>*`

5) Acción: revisar la estructura del contenido (H2 → H3 → H4) y evitar saltos de nivel.
   Resultado: jerarquía clara; títulos en estilo oración y sin punto final.

6) Acción: aplicar las reglas de LINGUISTICS a términos y comillas.
   Resultado: «IA», «TI», «computadora», comillas «», préstamos en cursiva.

7) Acción: en GitLab o GitHub, quitar o adaptar la sintaxis exclusiva de HedgeDoc.
   Resultado: sin `[TOC]`, `[name=...]`, `[time=...]`, `[color=...]`, bloques `<style>`, logotipos ni firma; los bloques `:::info` y `:::warning` pasan a citas (`> **Nota:**`).

8) Acción: eliminar separadores `---` innecesarios (regla crítica: los documentos generados por IA tienden a abusar de ellos).
   - Ejecutar `grep -n "^---$" <archivo>` para localizar todas las ocurrencias.
   - Conservar únicamente el *frontmatter* (líneas 1 y 3, si existe) y el `---` inmediatamente anterior al pie de página (firma en HedgeDoc o licencia en README.md).
   - Eliminar sin excepción todos los demás `---`.
   Resultado: ningún `---` en el cuerpo; a lo sumo uno justo antes del pie.

9) Acción: insertar el pie de página según la plataforma.
   Resultado:
   - HedgeDoc: separador, firma corporativa y CSS corporativo; nunca licencia.
   - GitLab o GitHub, README.md con `mit` o `gpl`: separador y texto de licencia y *copyright* de STYLING.md, más el *badge* de licencia después de la marca de tiempo; sin firma ni CSS.
   - GitLab o GitHub, otros documentos: sin pie.

10) Acción: validar enlaces e imágenes.
   Resultado: las URL funcionan y las imágenes tienen texto alternativo.

11) Acción: verificar Mermaid cuando se requieran diagramas.
    Resultado: bloques `mermaid` conformes; sin diagramas ASCII.

12) Acción: validar consistencia con linters.
    Resultado: markdownlint (encabezados y longitud de línea) pasa sin errores.

13) Acción: al editar el archivo con la herramienta de buscar y reemplazar del agente, anclar siempre desde el inicio de la línea.
    Regla: si la herramienta recibe un número de línea inicial, el texto a buscar debe comenzar en el primer carácter de esa línea; anclar a mitad de línea falla siempre.
    Resultado: todas las ediciones aplican sin errores de búsqueda.

Conclusión:

- Entregar el documento con encabezado y pie correctos para su plataforma, marca de tiempo válida en CST con el mes en español, contenido jerarquizado y estilo consistente.
- Confirmar la política de fecha única: ninguna fecha redundante permanece después de aplicar el estilo.
- Referencias: «~/rules/rulesets/STYLING.md» ([../rulesets/STYLING.md](../rulesets/STYLING.md)), «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)) y «~/rules/README.md» ([../README.md](../README.md)).
