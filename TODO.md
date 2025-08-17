# TODO — Cadena de razonamiento (Chain-of-Thought) en este repositorio

Creado: 17 de agosto de 2025, 01:52 CST (Ciudad de México)

Contexto
- Este repositorio se usa como “contexto instruccional” para LLM.
- Alineado con «chain-of-thought prompting»: Jason Wei et al., “Chain-of-Thought Prompting Elicits Reasoning in Large Language Models”, arXiv:2201.11903. DOI: https://doi.org/10.48550/arXiv.2201.11903
- Objetivo: mejorar la calidad y consistencia del razonamiento paso a paso en español mexicano, compatible con LINGUISTICS.md y PHILOSOPHY.md.

Tareas
- [ ] Escribir PROMPTS.md (guía CoT en es_MX)
  - Principios: cuándo usar CoT, granularidad de pasos, longitud objetivo.
  - Marcadores estandarizados: «Razonamiento», «Pasos», «Acción», «Resultado», «Conclusión».
  - Ejemplos mínimos y reglas de seguridad (no secretos, no datos sensibles).
  - Enlaces cruzados a PHILOSOPHY.md y LINGUISTICS.md.
- [ ] Crear directorio prompts/cot con ejemplos few-shot
  - prompts/cot/{aritmetica.md, sentido_comun.md, simbolico.md, devops.md, coding.md}
  - 3–8 ejemplos por archivo en es_MX, pasos numerados, «Razonamiento» y «Conclusión».
- [ ] Definir convención de formato CoT
  - Encabezados y numeración Paso 1..n.
  - Delimitadores y consistencia con comillas «», tiempos verbales, terminología es_MX.
- [ ] SELF_CONSISTENCY.md (auto-consistencia)
  - Muestrear N cadenas (p. ej., 5 o 10) y seleccionar por mayoría/agrupación.
  - Recomendaciones para diversidad (semillas y reformulaciones).
- [ ] Linter de prosa (Vale) para CoT
  - Regla: exigir «Razonamiento» y «Conclusión» en prompts de prompts/cot/.
  - Prohibir ‘CST’ sin TZ=America/Mexico_City, detectar verbos “-ear” spanglish, impedir pluralización de siglas.
  - Incluir .vale.ini y estilos.
- [ ] Hook pre-commit para ejemplos CoT
  - Validar que cada ejemplo en prompts/cot/ tenga ≥3 pasos numerados y «Conclusión».
  - Integrar a .githooks y documentar activación (core.hooksPath).
- [ ] EVAL.md (plantilla de evaluación)
  - Criterios: exactitud, coherencia paso a paso, cobertura, ausencia de alucinaciones, terminología es_MX.
  - Formatos CSV/Markdown para registrar resultados y muestras múltiples (auto-consistencia).
- [ ] Política bilingüe para CoT
  - Razonamiento en español mexicano; código/identificadores en inglés cuando aplique.
  - Cómo citar términos del GLOSSARY.md.
- [ ] ERROR_BANK.md (banco de errores y mitigaciones)
  - Fallos comunes: atajos sin justificar, sumarización prematura, confundir unidades, razonamiento circular.
  - Tácticas: descomposición, verificación de unidades, back-of-the-envelope, recordatorios.
- [ ] Añadir sección CoT al README
  - “Cómo usar este repo con CoT”: enlaces a PROMPTS.md, prompts/cot/, SELF_CONSISTENCY.md y EVAL.md.
  - Recordatorios de es_MX y timestamps CST.
- [ ] Metadatos por ejemplo CoT
  - Frontmatter YAML: domain, task, dificultad, longitud esperada, tiempo estimado, fuentes, validación.
  - Plantilla: prompts/cot/_template.md.

Prioridad sugerida (iteraciones cortas)
1) PROMPTS.md + convención de formato
2) prompts/cot/ con 2 archivos iniciales (aritmética y devops)
3) Hook pre-commit (validación mínima) + linter Vale básico
4) EVAL.md + SELF_CONSISTENCY.md
5) ERROR_BANK.md + política bilingüe
6) Ampliar prompts/cot/ y añadir metadatos

Notas
- Seguir LINGUISTICS.md: comillas «», tiempos verbales adecuados, es_MX.
- Timestamps: usar TZ=America/Mexico_City para cualquier fecha/hora generada.

