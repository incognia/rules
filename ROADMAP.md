# ROADMAP — Contexto instruccional y cadena de razonamiento (Chain-of-Thought)

Creado: 17 de agosto de 2025, 01:55 CST (Ciudad de México)

## Visión
Consolidar este repositorio como «contexto instruccional» para LLM que:
- Estandariza lenguaje (español mexicano) y estilo (ver «LINGUISTICS.md»)
- Proporciona cadenas de razonamiento paso a paso reutilizables (Chain-of-Thought, CoT)
- Facilita evaluación reproducible y auto-consistencia (self-consistency)
- Automatiza validaciones para «fallar rápido» en PRs

Fundamento académico: Jason Wei et al., «Chain-of-Thought Prompting Elicits Reasoning in Large Language Models», arXiv:2201.11903. DOI: https://doi.org/10.48550/arXiv.2201.11903

## Objetivos (horizonte 90 días)
- Publicar guía PROMPTS.md con convención CoT en español mexicano
- Crear biblioteca de ejemplos few-shot en prompts/cot/ para dominios técnicos y generales
- Establecer linters/hook para validar estructura CoT y convenciones de este repo
- Incorporar evaluación con muestreo y auto-consistencia (SELF_CONSISTENCY.md + EVAL.md)
- Medir impacto: precisión, coherencia y reducción de correcciones editoriales

## Hitos por iteración (semanas)

### Iteración 1 (17–31 ago 2025)
- PROMPTS.md: principios CoT (cuándo, cómo y por qué)
- Convención de formato: «Razonamiento», «Pasos 1..n», «Conclusión»; delimitadores claros
- prompts/cot/: crear aritmetica.md (≥5 ejemplos) y devops.md (≥5 ejemplos)
- Hook pre-commit CoT mínimo: exige ≥3 pasos y «Conclusión» en cada ejemplo
- Configuración de linters: .vale.ini (reglas básicas) y markdownlint (encabezados/longitud de línea)

Entregables
- PROMPTS.md publicado
- prompts/cot/aritmetica.md y prompts/cot/devops.md
- Hook activable con core.hooksPath
- .vale.ini y .markdownlint config inicial

### Iteración 2 (1–14 sep 2025)
- SELF_CONSISTENCY.md: lineamientos para muestrear N cadenas y seleccionar por mayoría/agrupación
- EVAL.md: plantilla de evaluación (exactitud, coherencia, cobertura, alucinaciones, terminología es_MX)
- Linter Vale: reglas ampliadas (secciones obligatorias, ‘-ear’, siglas sin plural, ‘CST’ sin TZ)
- Prueba de aceptación: ejecutar 2 evaluaciones con 5 muestras cada una (auto-consistencia) y registrar resultados en EVAL.md

Entregables
- SELF_CONSISTENCY.md y EVAL.md
- .vale.ini y estilos en .vale/
- Reportes de evaluación inicial

### Iteración 3 (15–30 sep 2025)
- prompts/cot/: sentido_comun.md y simbolico.md (≥5 ejemplos cada uno)
- Política bilingüe CoT: reglas para mezclar español mexicano (razonamiento) e inglés (código/identificadores)
- ERROR_BANK.md: fallas comunes y tácticas de mitigación
- Revisión de coherencia en documentos de perfil (CORPORATE.md/TEACHING.md): enlaces de retorno a PHILOSOPHY y README; aclarar herramienta «Kro» o reemplazar por «Kustomize» si aplica

Entregables
- Dos nuevos archivos de ejemplos
- Política bilingüe publicada
- Banco de errores y mitigaciones
- Perfiles con enlaces de retorno y terminología afinada

### Iteración 4 (1–15 oct 2025)
- Ampliar prompts/cot/coding.md (≥8 ejemplos con pruebas de razonamiento en refactor y depuración)
- Metadatos por ejemplo (frontmatter YAML): domain, task, dificultad, longitud esperada, validación
- Integrar sección CoT al README (si no se hizo) y diagramas con Mermaid donde aplique

Entregables
- coding.md con ejemplos
- Plantilla prompts/cot/_template.md
- README actualizado

## Métricas de éxito
- Calidad: incremento de precisión y coherencia paso a paso en evaluaciones EVAL.md
- Revisión: reducción de correcciones por estilo/es_MX detectadas por Vale
- Cobertura: ≥4 dominios con ≥5 ejemplos CoT cada uno
- Automatización: hooks y linters activados por defecto en este repo
- Trazabilidad: cambios documentados en CHANGELOG.md (fecha CST, sin hora)

## Riesgos y mitigaciones
- Sobre-ingeniería de prompts: mantener ejemplos concisos (longitud objetivo); iterar con EVAL
- Ruido por emojis en contextos profesionales: permitir en docs de trabajo; moderar en docs formales
- Sesgo de dominio: diversificar dominios y estilos de problema
- Timestamps en UTC mal rotulados como CST: validar con hooks y reglas Vale (TZ=America/Mexico_City)

## Enlaces y referencias
- LINGUISTICS.md — estilo y español mexicano
- GLOSSARY.md — términos técnicos estandarizados
- COMMITTING.md — flujo y CHANGELOG (fechas en CST, sin hora)
- STYLING.md — estilo corporativo (si aplica)
- README.md — convenciones de fechas/horas y CoT
- Wei et al. (2022/2023) — Chain-of-Thought Prompting: https://arxiv.org/abs/2201.11903

