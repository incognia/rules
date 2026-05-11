---
domain: documentation
task: actualizar CHANGELOG.md correctamente evitando errores comunes de orden cronológico, cálculo de zona horaria, duplicación y mezcla de idiomas
dificultad: media-alta
longitud_objetivo: media
validacion: CHANGELOG.md ordenado inversamente, fechas CST correctas, sin duplicados, idioma consistente español mexicano
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Regla principal: CHANGELOG.md debe seguir orden cronológico inverso (más reciente arriba) con fechas en CST Ciudad de México calculadas correctamente (ver «~/rules/CHANGELOG.md» ([../../CHANGELOG.md](../../CHANGELOG.md)), «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)) y «~/rules/cot/committing.md» ([./committing.md](./committing.md))).
- Errores comunes críticos: (1) orden cronológico incorrecto, (2) cálculo erróneo de CST (etiquetar UTC como CST), (3) duplicar entradas idénticas, (4) mezclar inglés con español mexicano.
- Flujo: verificar zona horaria actual → revisar orden cronológico → detectar duplicados → aplicar reglas lingüísticas → validar estructura.
- Este CoT se ejecuta vía `/changelogger` antes de `/commit`; el flujo `/commit` no edita changelog y solo valida que exista diff en `CHANGELOG.md`.

Pasos:
0) Acción: leer primero las líneas 1-200 de `CHANGELOG.md` antes de cualquier búsqueda o edición.
   HERRAMIENTA OBLIGATORIA: `read_files` sobre `CHANGELOG.md` con rango `1-200`
   Validación: confirmar encabezado del día en turno, separación entre bloques de fecha y primer bullet del bloque objetivo.
   Resultado: contexto base exacto cargado antes de ejecutar `grep`, calcular anclas o intentar parches.
1) Acción: calcular fecha y hora CST correcta.
   COMANDO OBLIGATORIO: `TZ=America/Mexico_City date +"%Y-%m-%d %H:%M:%S"`
   Validación: confirmar cálculo matemático CST = UTC - 6 horas
   Resultado: fecha actual en CST para nueva entrada, nunca etiquetar hora UTC como CST.

2) Acción: revisar estructura y orden cronológico del CHANGELOG.md.
   COMANDO OBLIGATORIO: `grep -n "^## \[" CHANGELOG.md | head -10`
   Validación: confirmar que fechas están ordenadas de más reciente a más antigua
   Resultado: detectar entradas fuera de orden cronológico inverso.

3) Acción: verificar si ya existe una entrada para la fecha CST actual.
   COMANDO OBLIGATORIO: `grep -n "^## \[${DATE_CST}\]" CHANGELOG.md`
   Decisión crítica:
   - Si YA EXISTE entrada para esa fecha: agregar nuevos bullets tipados (`- feat: ...`, `- docs: ...`) DENTRO de la entrada existente. NO crear encabezado nuevo.
   - Si NO existe: crear nuevo encabezado `## [YYYY-MM-DD] - Título descriptivo` en la posición correcta (arriba de todas las entradas).
   Resultado: nunca dos encabezados con la misma fecha en el CHANGELOG.

4) Acción: validar consistencia de idioma en la nueva entrada.
   Validación: aplicar reglas de ~/rules/rulesets/LINGUISTICS.md
   Resultado: español mexicano sin calcos del inglés, comillas angulares «», terminología técnica correcta.

5) Acción: verificar formato de encabezado.
   Formato requerido: `## [YYYY-MM-DD] - Título descriptivo`
   Validación: solo fecha sin hora, título en estilo oración (primera mayúscula + nombres propios)
   Resultado: encabezado conforme al formato establecido.
6) Acción: organizar cambios en bullets tipados dentro de la fecha.
   Formato de cada bullet: `- tipo: descripción` (ej. `- feat: ...`, `- fix: ...`, `- docs: ...`)
   Validación: no usar subencabezados `### tipo`; usar bullets directos con prefijo de tipo
   Resultado: entrada compacta y consistente con formato de repos de operaciones-ti.

6b) Acción: insertar bullets en orden cronológico inverso dentro de la entrada de fecha.
   REGLA CRÍTICA: el nuevo bullet va PRIMERO dentro del bloque de la fecha.
   TÉCNICA DE EDICIÓN OBLIGATORIA para `edit_files`:
   - REGLA DE ORO: el `search` termina en la ÚLTIMA LÍNEA que se desea como ancla. El `replace` reproduce esa línea intacta y AÑADE el nuevo contenido ANTES o DESPUÉS de ella. NUNCA incluir en el `search` una línea que luego se reproduzca truncada o modificada en el `replace`.
   - REGLA OPERATIVA MANDATORIA para fecha existente: edición directa y simple en hunk único; una vez identificado el bloque objetivo, no repetir búsquedas exploratorias.
   - PRIMER INTENTO OBLIGATORIO para fecha existente: usar micro-bloque exacto en un solo hunk con `search` = `## [FECHA] - ...` + línea en blanco inmediata + primer bullet existente.
   - En ese mismo hunk, el `replace` reproduce encabezado y línea en blanco intactos, inserta el bullet nuevo al tope y conserva el bullet previo debajo.
   - Prohibido usar anclas parciales para fecha existente (por ejemplo, `search` con solo encabezado).
   - Prohibido insertar línea en blanco entre bullets del mismo bloque de fecha.
   - Prohibido para fecha existente anclar `search` en `# Registro de cambios` o incluir ese encabezado en el hunk de inserción.
   - Prohibido reemplazar el bloque superior del archivo para insertar bullets en una fecha existente.
   - MODO INSERCIÓN INCREMENTAL (OBLIGATORIO): por defecto solo se permiten adiciones (`+`). Si aparece cualquier línea eliminada (`-`) en `CHANGELOG.md`, abortar el parche y reconstruir ancla; solo se permiten borrados con instrucción explícita del usuario.
   - Para insertar nueva entrada `## [FECHA]` al inicio del archivo: el `search` es SOLO la línea ancla inmediatamente anterior (p. ej. el comentario `<!-- markdownlint-disable -->` o la línea en blanco que lo sigue). El `replace` reproduce esa línea ancla exacta y añade la nueva entrada después. NUNCA incluir la primera `## [FECHA]` existente en el `search` a menos que se reproduzca COMPLETA e INTACTA en el `replace`.
   - FALLBACK OBLIGATORIO (dos hunks) para nueva fecha si falta la línea en blanco antes del siguiente encabezado:
     - Hunk 1: insertar el bloque `## [FECHA]` con sus bullets arriba del siguiente `## [FECHA_ANTERIOR]`.
     - Hunk 2: usar como ancla el siguiente encabezado `## [FECHA_ANTERIOR]` y reemplazarlo por `línea en blanco + el mismo encabezado` para forzar el separador.
   - Prohibido repetir el mismo parche de inserción (`+6`) cuando la previsualización sigue sin separador en blanco.
   - Si el `search` falla, leer el archivo con `read_files` para obtener el contenido exacto antes de reintentar.
   Resultado: bullets tipados ordenados cronológicamente dentro de cada fecha, con nuevo bullet al tope.

6c) Acción: validar diff mínimo inmediatamente después de cada edición.
   COMANDO OBLIGATORIO: `git --no-pager diff -- CHANGELOG.md`
   Criterio de aceptación obligatorio:
   - En modo inserción incremental: solo líneas añadidas (`+`) en el bloque de la fecha objetivo.
   - Cero líneas eliminadas (`-`) en todo `CHANGELOG.md`, salvo instrucción explícita del usuario para borrar.
   - NUNCA editar líneas fuera de `DATE_CST` (día en turno) salvo instrucción explícita del usuario.
   Gestión de fallos:
   - Si falla la validación: releer bloque exacto y corregir una sola vez con edición mínima.
   - Si en una inserción incremental aparece cualquier `-` en el diff: abortar ese intento y reconstruir ancla antes de reintentar.
   - Si `DATE_CST` ya existe y solo se agrega bullet: mantener hunk único con micro-bloque exacto (`encabezado + línea en blanco + primer bullet`); no usar fallback de dos hunks.
   - Si se está creando nueva fecha y la previsualización muestra que falta la línea en blanco antes del siguiente `## [FECHA]`: aplicar de inmediato el fallback de dos hunks; no repetir el mismo parche de inserción.
   - Si el diff muestra cambios históricos fuera de `DATE_CST`: detenerse y pedir confirmación; prohibido autocorregir entradas fuera del día en turno.
   - Si vuelve a fallar: detenerse y pedir confirmación del usuario antes de cualquier nuevo intento.
   - Prohibido encadenar 3 o más intentos seguidos sobre `CHANGELOG.md` sin validación intermedia exitosa.
   Resultado: cambios mínimos, trazables y sin efectos colaterales.
7) Acción: revisar texto del bloque de la fecha objetivo (`DATE_CST`).
   COMANDO OBLIGATORIO: `grep -A 20 '^## \[${DATE_CST}\]' CHANGELOG.md` para revisar la entrada en turno
   Validación: detectar mezcla español-inglés, calcos y regionalismos no mexicanos SOLO en el bloque del día en turno
   Resultado: ajustar únicamente los bullets nuevos de `DATE_CST`; reportar inconsistencias históricas sin editarlas.

8) Acción: aplicar reglas tipográficas.
   Validación: guion medio en títulos, comillas angulares en texto, cursivas en préstamos técnicos
   Resultado: *commit*, *pipeline*, *stack* en cursiva; «código» entre comillas angulares.

9) Acción: verificar estructura final.
   COMANDO OBLIGATORIO: `head -30 CHANGELOG.md` para revisar las primeras entradas
   Validación: orden cronológico inverso, formato consistente, idioma homogéneo
   Resultado: CHANGELOG.md ordenado correctamente con nueva entrada en posición adecuada.

10) Acción: verificar precondición para `/commit` tras actualizar changelog.
    COMANDOS RECOMENDADOS:
    - `git --no-pager diff -- CHANGELOG.md`
    - `git --no-pager diff --cached -- CHANGELOG.md`
    Validación: debe existir al menos un cambio en `CHANGELOG.md` (staged o unstaged) para pasar el gate de `/commit`.
    Resultado: changelog listo para continuar con `/commit` sin edición adicional.

VERIFICACIÓN CRÍTICA (antes de completar):
- Confirmar: `TZ=America/Mexico_City date` ejecutado para fecha CST real
- Validar: orden cronológico inverso con `grep "^## \[" CHANGELOG.md`
- Verificar: sin duplicados con conteo de encabezados idénticos
- Revisar: idioma 100% español mexicano según LINGUISTICS.md
- Comprobar: formato de encabezado `[YYYY-MM-DD] - Título descriptivo`
- Comprobar: bullets con prefijo `tipo:` y ausencia de subencabezados `### tipo`
- Validar: `git --no-pager diff -- CHANGELOG.md` cumple criterio de aceptación (solo adiciones mínimas en fecha objetivo)
- Confirmar: existe diff de `CHANGELOG.md` para pasar gate de `/commit`; si no existe, no continuar a `/commit`

ANTI-PATRONES PROHIBIDOS (detener y pedir confirmación si ocurre cualquiera):
1. Reintentar el mismo parche sobre el encabezado sin cambiar la ancla real del bloque.
2. Escalar a reescritura total de `CHANGELOG.md` para insertar un bullet puntual.
3. Hacer más de un reintento sin releer antes el bloque exacto.
4. Encadenar intentos fallidos sin validar diff en cada intento.
5. NUNCA editar entradas fuera de `DATE_CST` (día en turno), salvo instrucción explícita del usuario.
6. Continuar con `/commit` cuando `CHANGELOG.md` no está listo para el gate (sin cambios o sin cumplir criterio de aceptación).
7. Improvisar flujos alternos fuera de `/changelogger` y `/commit` para forzar edición.
8. Repetir el mismo parche de inserción cuando la previsualización ya mostró que faltó la línea en blanco separadora.
9. Insertar una línea en blanco entre bullets del mismo bloque de fecha.
10. Repetir búsquedas exploratorias cuando el bloque objetivo ya está identificado.
11. Usar anclas parciales para fecha existente (como `search` de solo encabezado) en lugar del micro-bloque exacto del primer intento.
12. Empezar con `grep`, búsquedas exploratorias o intentos de parche sin haber leído `CHANGELOG.md` líneas `1-200` en esa ejecución.
13. Usar `search = encabezado + primer bullet` sin incluir la línea en blanco intermedia obligatoria en fecha existente.
14. Anclar inserciones de fecha existente desde `# Registro de cambios` o reescribir el bloque superior del archivo.
15. Aceptar un parche de “solo inserción” que muestre líneas eliminadas (`-`) en encabezados o separadores en blanco.
16. Borrar cualquier línea existente de `CHANGELOG.md` durante inserciones incrementales sin instrucción explícita del usuario.

Conclusión:
- Entregar: CHANGELOG.md actualizado con nueva entrada en posición cronológica correcta, fecha CST precisa, idioma consistente español mexicano, sin duplicados y bullets tipados organizados semánticamente.
- Evitar: mezclar idiomas, etiquetar UTC como CST, orden cronológico incorrecto, duplicar entradas, micro-cambios sin agrupar.
- Operación esperada: ejecutar este CoT desde `/changelogger` y después invocar `/commit` (que solo valida gate de changelog + idioma del commit).
- Referencias: «~/rules/CHANGELOG.md» ([../../CHANGELOG.md](../../CHANGELOG.md)), «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)), «~/rules/cot/committing.md» ([./committing.md](./committing.md)) para flujo completo.
