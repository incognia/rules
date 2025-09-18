# ROADMAP — Desarrollo CoT y automatización de reglas técnicas

**Última actualización**: 2025-09-17 23:21 CST (Ciudad de México)

## Visión

Consolidar este repositorio como **contexto instruccional completo** para LLM que:

- Proporciona cadenas de razonamiento (CoT) para **todos** los documentos técnicos
- Estandariza lenguaje (español mexicano) y estilo técnico
- Facilita evaluación reproducible y auto-consistencia
- Automatiza validaciones para calidad y coherencia

**Fundamento académico**: Jason Wei et al., «Chain-of-Thought Prompting Elicits Reasoning in Large Language Models», arXiv:2201.11903. DOI: [10.48550/arXiv.2201.11903](https://doi.org/10.48550/arXiv.2201.11903)

## Estado actual del proyecto

### Estadísticas de cobertura CoT

```text
Total documentos técnicos (docs/): 14 documentos
├── Con CoT: 6 documentos (43%)
├── Sin CoT: 8 documentos (57%)
└── Cobertura objetivo: 100%

Total CoTs existentes: 14 archivos
├── Vinculados a docs/: 6 (43%)
├── Independientes: 8 (57%)
└── Nuevos CoTs: changelog.md (creado 2025-09-17)
```

### Infraestructura completada ✓

- ✓ Configuración markdownlint (.markdownlint.yaml)
- ✅ Verificación de enlaces (.markdownlinkcheck.json)
- ✅ Scripts npm (lint:md, check:links)
- ✅ Estructura organizada (docs/, prompts/cot/, scripts/)
- ✅ Template base CoT (_template.md)
- ✓ Validation programática en CoTs críticos
- ✅ **NUEVO**: CoT changelog.md con corrección de errores comunes
- ✅ **MEJORADO**: CoT committing.md con validación de configuración SSH/HTTPS

## Objetivos (horizonte 90 días)

### Meta principal: cobertura CoT 100%

Crear CoTs para **todos** los documentos técnicos restantes, priorizando por impacto operativo.

### Metas secundarias

- Mejorar infraestructura de validación automática
- Establecer evaluación con auto-consistencia
- Medir impacto en reducción de errores técnicos

## *Roadmap* por *sprints*

### 🔥 ***Sprint* 1** (próxima semana) - CoTs críticos

**Objetivo**: Cobertura 40% → 60%

#### Prioridad crítica - flujo de trabajo diario

1. **CRITICAL_COT_READING.md** → `prompts/cot/cot_reading_protocol.md`
   - Protocolo obligatorio lectura completa CoTs
   - Evita errores por lectura parcial
   - **Estimación**: 2-3 horas

1. **COMMIT_LANGUAGE_PROTOCOL.md** → `prompts/cot/commit_language_check.md`
   - Checkpoint automático idioma *commits* (inglés)
   - Evita error recurrente *commits* en español
   - **Estimación**: 2-3 horas

1. **LICENSING.md** → `prompts/cot/licensing_decision.md`
   - Decisión GPLv3 vs MIT según contexto (personal/laboral)
   - Automatiza selección de licencias
   - **Estimación**: 3-4 horas

**Entregables *Sprint* 1**:

- 3 CoTs nuevos (críticos)
- Documentación en CHANGELOG.md
- Prueba de funcionamiento de cada CoT

### 📈 ***Sprint* 2** (semana 2) - CoTs de procesos regulares

**Objetivo**: Cobertura 60% → 87%

#### Prioridad media - procesos importantes

1. **ATTRIBUTION.md** → `prompts/cot/attribution.md`
   - Atribución personal correcta en documentos/scripts
   - **Estimación**: 2 horas

1. **CORPORATE.md** → `prompts/cot/corporate_profile.md`
   - Perfil profesional adaptado a contexto
   - **Estimación**: 3-4 horas

1. **TEACHING.md** → `prompts/cot/teaching_profile.md`
   - Perfil educativo y divulgación
   - **Estimación**: 4-5 horas

**Entregables *Sprint* 2**:

- 3 CoTs nuevos (procesos regulares)
- Actualización de referencias cruzadas
- Revisión de CoTs existentes

### 📝 ***Sprint* 3** (semana 3-4) - completar cobertura

**Objetivo**: Cobertura 87% → 100%

#### Prioridad baja - documentos de referencia

1. **GLOSSARY.md** → `prompts/cot/glossary_update.md`
   - Actualizar y mantener glosario técnico
   - **Estimación**: 2-3 horas

1. **TODO.md** → `prompts/cot/todo_management.md`
   - Gestionar lista táctica CoT
   - **Estimación**: 1-2 horas

#### Evaluación pendiente

1. **VAULT.md** - Evaluar relevancia actual
   - Si relevante: crear CoT correspondiente
   - Si obsoleto: eliminar y actualizar referencias

**Entregables *Sprint* 3**:

- CoTs restantes completados
- Cobertura 100% documentada
- Limpieza de archivos obsoletos

## Infraestructura y mejoras (paralelo)

### Validación automática

- **Actualizar CoTs existentes**: alinear con docs/ actualizados
- **Mejorar validación programática**: expandir a más CoTs críticos
- **Establecer convenciones**: metadatos YAML frontmatter

### Auto-consistencia y evaluación

- **SELF_CONSISTENCY.md**: lineamientos para muestrear N cadenas
- **EVAL.md**: plantilla de evaluación (exactitud, coherencia, terminología es_MX)
- **ERROR_BANK.md**: fallas comunes y mitigaciones

### Política bilingüe refinada

- **Reglas claras**: español mexicano (razonamiento) + inglés (código/identificadores)
- **Terminología técnica**: cursivas para préstamos (*stack*, *commit*, *pipeline*)
- **Validación timezone**: CST con TZ=America/Mexico_City obligatorio

## Métricas de éxito

### Cobertura CoT

- ***Sprint* 1**: 60% cobertura (documentos críticos)
- ***Sprint* 2**: 87% cobertura (procesos regulares)  
- ***Sprint* 3**: 100% cobertura (completa)

### Calidad operativa

- **Reducción errores**: *commits* en español, *timestamps* UTC mal rotulados
- **Consistencia**: atribución, licenciamiento, styling
- **Automatización**: validaciones programáticas funcionando

### Documentación

- **Trazabilidad**: cambios en CHANGELOG.md (fechas CST)
- **Referencias**: enlaces cruzados actualizados
- **Mantenibilidad**: CoTs fáciles de usar y actualizar

## Riesgos y mitigaciones

### Sobre-complejidad CoT

- **Riesgo**: CoTs demasiado largos o complicados
- **Mitigación**: Mantener ejemplos concisos, iterar con evaluación

### Mantenimiento

- **Riesgo**: CoTs desactualizados vs docs/ modificados
- **Mitigación**: Revisión periódica, validación programática

### Adopción

- **Riesgo**: CoTs creados pero no utilizados
- **Mitigación**: Documentar casos de uso, ejemplos prácticos

## Cronograma detallado

```text
Semana 1 (*Sprint* 1): CoTs críticos
├── Días 1-2: CRITICAL_COT_READING + COMMIT_LANGUAGE_PROTOCOL  
├── Días 3-4: LICENSING
└── Día 5: Testing y documentación

Semana 2 (*Sprint* 2): CoTs regulares  
├── Día 1: ATTRIBUTION
├── Días 2-3: CORPORATE  
├── Días 4-5: TEACHING

Semana 3-4 (*Sprint* 3): Completar + infraestructura
├── Días 1-2: GLOSSARY + TODO
├── Día 3: Evaluación VAULT
├── Días 4-5: Mejoras infraestructura
└── *Sprint* final: Documentación completa
```

## Enlaces y referencias

- **docs/LINGUISTICS.md** — estilo y español mexicano
- **PROMPTS.md** — guía CoT actual  
- **docs/COMMITTING.md** — flujo y CHANGELOG (fechas CST)
- **prompts/cot/_template.md** — template base para nuevos CoTs
- **Wei et al. (2022)** — Chain-of-Thought Prompting: [arXiv:2201.11903](https://arxiv.org/abs/2201.11903)

---

**Estado**: *Sprint* 0 completado (infraestructura)  
**Siguiente**: *Sprint* 1 (CoTs críticos)
**Responsable**: Rodrigo Álvarez (@incognia)
