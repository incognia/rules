# PROMPTS — Guía de cadena de razonamiento (Chain-of-Thought) en español mexicano

Creado: 17 de agosto de 2025, 02:18 CST (Ciudad de México)

## Propósito
Estandarizar cómo redactar prompts y ejemplos con cadena de razonamiento en este repositorio, alineados con:
- LINGUISTICS.md (español mexicano, comillas «», tiempos verbales)
- PHILOSOPHY.md (marco ético y técnico)
- README.md (entrypoint rápido)

## Cuándo usar Chain-of-Thought (CoT)
- Problemas con varios pasos (aritmética, lógica, diagnóstico técnico, refactorizaciones).
- Tareas con dependencias entre pasos o verificación de unidades/condiciones.
- Casos donde se requiere justificar por qué se elige una acción.

## Convención de formato (CoT)
- Encabezados y bloques fijos:
  - «Razonamiento» (breve marco mental del enfoque)
  - «Pasos» (Paso 1..n, cada uno con Acción y Resultado cuando aplique)
  - «Conclusión» (respuesta final clara y verificable)
- Ejemplo de secciones:

```
Razonamiento:
- Descomponer el problema.
- Verificar unidades.

Pasos:
1) Acción: ...
   Resultado: ...
2) Acción: ...
   Resultado: ...

Conclusión:
- Respuesta final: ... (con unidades si aplica)
```

Reglas de estilo
- Español mexicano en razonamiento y pasos; identificadores/código en inglés internacional cuando corresponda.
- Comillas «» en texto; "" sólo en código/comentarios.
- Siglas sin plural gráfico (3 VM, no 3 VMs); si se requiere claridad: «3 instancias de VM».
- Timestamps: formato 24 h, «CST (Ciudad de México)» y cálculo explícito con TZ=America/Mexico_City.

## Ejemplos mínimos (esqueleto)
- Ver plantilla en [prompts/cot/_template.md](prompts/cot/_template.md). Cada archivo temático (arithmetic.md, devops.md, etc.) debe incluir 3–8 ejemplos con:
  - Frontmatter YAML (domain, task, dificultad, etc.)
  - Secciones «Razonamiento», «Pasos», «Conclusión».

## Índice de prompts

- General: ver [prompts/README.md](prompts/README.md)

### CoT (prompts/cot)
- [arithmetic.md](prompts/cot/arithmetic.md)
- [committing.md](prompts/cot/committing.md)
- [committing_corporate.md](prompts/cot/committing_corporate.md)
- [committing_personal.md](prompts/cot/committing_personal.md)
- [devops.md](prompts/cot/devops.md)
- [git_init.md](prompts/cot/git_init.md)
- [kubernetes.md](prompts/cot/kubernetes.md)
- [linguistics.md](prompts/cot/linguistics.md)
- [repo_context.md](prompts/cot/repo_context.md)
- [styling.md](prompts/cot/styling.md)

### Templates (prompts/templates)
- [issue_template.md](prompts/templates/issue_template.md)

### Guides (prompts/guides)
- [git_workflow_guide.md](prompts/guides/git_workflow_guide.md)

### Actions (prompts/actions)
- [release.md](prompts/actions/release.md)

### Snippets (prompts/snippets)
- [cst_date.sh](prompts/snippets/cst_date.sh)

## Rutas de referencia a este repositorio
- Para que los prompts funcionen como referencia desde otros proyectos, usa rutas relativas al directorio HOME apuntando a este repo clonado en «~/rules».
- Ejemplos de referencia directa en prompts:
  - «~/rules/LINGUISTICS.md»
  - «~/rules/PHILOSOPHY.md»
  - «~/rules/README.md»
  - «~/rules/COMMITTING.md»
- Esta convención funciona en Linux y macOS. En Windows se recomienda WSL; en ese caso «~» también expande a «$HOME» dentro de WSL.

## Auto-consistencia (resumen)
- Para tareas complejas, generar N muestras (p. ej., 5 o 10) variando ligeramente el prompt o la semilla; seleccionar por mayoría o agregación. Detalle en SELF_CONSISTENCY.md (por crear).

## Seguridad y privacidad
- No incluir secretos ni datos sensibles en ejemplos.
- Si se usan tokens ficticios, marcarlos como ejemplos claramente irreales (foo, bar, example.com).

## Referencias
- Wei et al. (2022/2023): Chain-of-Thought Prompting Elicits Reasoning in Large Language Models — https://arxiv.org/abs/2201.11903
- LINGUISTICS.md — reglas lingüísticas del repo
- README.md — convenciones de fechas/horas y navegación

