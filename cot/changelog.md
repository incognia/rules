---
domain: documentation
task: actualizar CHANGELOG.md correctamente evitando errores comunes de orden cronológico, cálculo de zona horaria, duplicación y mezcla de idiomas
dificultad: media-alta
longitud_objetivo: media
validacion: CHANGELOG.md ordenado inversamente, fechas CST correctas, sin duplicados, idioma consistente español mexicano
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Regla principal: CHANGELOG.md debe seguir orden cronológico inverso (más reciente arriba) con fechas en CST Ciudad de México calculadas correctamente (ver «~/rules/CHANGELOG.md», «~/rules/docs/LINGUISTICS.md» y «~/rules/prompts/cot/committing.md»).
- Errores comunes críticos: (1) orden cronológico incorrecto, (2) cálculo erróneo de CST (etiquetar UTC como CST), (3) duplicar entradas idénticas, (4) mezclar inglés con español mexicano.
- Flujo: verificar zona horaria actual → revisar orden cronológico → detectar duplicados → aplicar reglas lingüísticas → validar estructura.

Pasos:
1) Acción: calcular fecha y hora CST correcta.
   COMANDO OBLIGATORIO: `TZ=America/Mexico_City date +"%Y-%m-%d %H:%M:%S"`
   Validación: confirmar cálculo matemático CST = UTC - 6 horas
   Resultado: fecha actual en CST para nueva entrada, nunca etiquetar hora UTC como CST.

2) Acción: revisar estructura y orden cronológico del CHANGELOG.md.
   COMANDO OBLIGATORIO: `grep -n "^## \[" CHANGELOG.md | head -10`
   Validación: confirmar que fechas están ordenadas de más reciente a más antigua
   Resultado: detectar entradas fuera de orden cronológico inverso.

3) Acción: detectar entradas duplicadas.
   COMANDO OBLIGATORIO: `grep "^## \[" CHANGELOG.md | sort | uniq -c | awk '$1 > 1'`
   Validación: identificar encabezados de fecha repetidos exactamente
   Resultado: marcar duplicados para consolidación o eliminación.

4) Acción: validar consistencia de idioma en la nueva entrada.
   Validación: aplicar reglas de ~/rules/docs/LINGUISTICS.md
   Resultado: español mexicano sin calcos del inglés, comillas angulares «», terminología técnica correcta.

5) Acción: verificar formato de encabezado.
   Formato requerido: `## [YYYY-MM-DD] - Título descriptivo del cambio principal`
   Validación: solo fecha sin hora, título en estilo oración (primera mayúscula + nombres propios)
   Resultado: encabezado conforme al formato establecido.

6) Acción: organizar cambios por categorías semánticas.
   Categorías: `### docs`, `### feat`, `### fix`, `### refactor`, `### chore`, `### ci`
   Validación: agrupar cambios relacionados, no micro-entradas por commit individual
   Resultado: secciones organizadas con cambios agrupados lógicamente.

7) Acción: revisar texto de las entradas existentes.
   COMANDO OBLIGATORIO: `grep -A 20 "^## \[" CHANGELOG.md | head -50` para revisar entradas recientes
   Validación: detectar mezcla español-inglés, calcos, regionalismos no mexicanos
   Resultado: corregir inconsistencias lingüísticas en entradas previas si existen.

8) Acción: aplicar reglas tipográficas.
   Validación: guion medio en títulos, comillas angulares en texto, cursivas en préstamos técnicos
   Resultado: *commit*, *pipeline*, *stack* en cursiva; «código» entre comillas angulares.

9) Acción: verificar estructura final.
   COMANDO OBLIGATORIO: `head -30 CHANGELOG.md` para revisar las primeras entradas
   Validación: orden cronológico inverso, formato consistente, idioma homogéneo
   Resultado: CHANGELOG.md ordenado correctamente con nueva entrada en posición adecuada.

10) Acción: confirmar cálculo de zona horaria en commits relacionados.
    Referencia: aplicar ~/rules/prompts/cot/committing.md para commits de actualización
    Validación: mensaje de commit en inglés con fecha CST calculada correctamente
    Resultado: consistencia entre CHANGELOG.md y mensajes de commit.

VERIFICACIÓN CRÍTICA (antes de completar):
- Confirmar: `TZ=America/Mexico_City date` ejecutado para fecha CST real
- Validar: orden cronológico inverso con `grep "^## \[" CHANGELOG.md`
- Verificar: sin duplicados con conteo de encabezados idénticos
- Revisar: idioma 100% español mexicano según LINGUISTICS.md
- Comprobar: formato de encabezado `[YYYY-MM-DD] - Título descriptivo`

Conclusión:
- Entregar: CHANGELOG.md actualizado con nueva entrada en posición cronológica correcta, fecha CST precisa, idioma consistente español mexicano, sin duplicados, categorías organizadas semánticamente.
- Evitar: mezclar idiomas, etiquetar UTC como CST, orden cronológico incorrecto, duplicar entradas, micro-cambios sin agrupar.
- Referencias: «~/rules/CHANGELOG.md», «~/rules/docs/LINGUISTICS.md», «~/rules/prompts/cot/committing.md» para flujo completo.