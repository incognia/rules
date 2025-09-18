# Historial de cambios

**Nota:** Todas las fechas están en zona horaria CST de Ciudad de México (UTC-6).

<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->

## [2025-09-18] - Extensión del CoT de contexto para detectar archivos WARP

### docs
- extender prompts/cot/context.md para buscar archivos WARP.md y .warp.md en el análisis de documentación del proyecto
- incluir ambas variantes (WARP.md estándar y .warp.md como *dotfile*) en verificación de existencia y lectura automática
- agregar referencias específicas para configuración y reglas de proyecto en sección de Referencias del CoT
- crear WARP.md con guía completa para instancias futuras de WARP terminal en este repositorio
- incluir descripción del propósito del repositorio (reglas técnicas, filosofía y CoT para LLM)
- documentar filosofía central: combatir mercenazgo, egoísmo técnico y pérdida de identidad cultural
- especificar comandos de desarrollo común: lint markdown (npm run lint:md), verificación de enlaces, scripts de respaldo
- detallar flujo de commits crítico: actualizar CHANGELOG.md primero, luego add/commit/push
- documentar arquitectura de directorios: docs/ (reglas), prompts/ (CoT y plantillas), scripts/ (herramientas)
- incluir contextos duales: personal (@incognia, GPLv3) vs corporativo (@incogniadev, MIT)
- especificar sistema Chain-of-Thought con formato estructurado (Razonamiento, Pasos, Conclusión)
- documentar manejo crítico de zona horaria CST (UTC - 6 horas, nunca solo agregar sufijo)
- incluir especialización técnica: Kubernetes, GitOps, mallas de servicios, observabilidad
- definir 7 reglas clave incluyendo lectura completa de CoT y flujo obligatorio de CHANGELOG
- establecer integración con otros repositorios mediante rutas ~/rules/

## [2025-09-17] - Mejoras críticas para cálculo preciso de zona horaria CST y reorganización estructural

### feat
- crear prompts/cot/context.md v2.0: CoT genérico portable para cualquier proyecto con detección automática de tecnologías (Node.js, Python, Go, Rust, Java, Docker), análisis de estructura con *tree*, instalación multiplataforma (*dnf*, *apt*, *apk*, *pacman*, *brew*) y identificación de archivos de documentación estándar

### docs
- actualizar README.md: añadir referencia a CoT genérico context.md en sección de uso rápido
- actualizar ROADMAP.md: incrementar estadísticas de CoT (14→15 archivos, 57%→60% independientes), documentar progreso *Sprint* 1 con CoT completado y actualizar infraestructura completada con características del nuevo CoT
- consolidar ROADMAP.md en raíz combinando infraestructura CoT con análisis de cobertura específica
- consolidar ROADMAP.md en raíz combinando infraestructura CoT con análisis de cobertura específica
- corregir systemáticamente errores de lint Markdown en archivos principales (README, ROADMAP, CHANGELOG, PROMPTS, PHILOSOPHY)
- añadir espacios en blanco alrededor de encabezados y listas según MD022/MD032
- corregir enlaces huérfanos tras movimiento de docs/ROADMAP.md a raíz
- especificar lenguajes en bloques de código y corregir prefijos de listas ordenadas
- instalar y configurar npm/nodejs para verificación de enlaces y lint automático
- crear CoT para mantenimiento de *changelog* en prompts/cot/changelog.md con corrección de errores comunes: orden cronológico inverso, cálculo preciso de CST, detección de duplicados y consistencia lingüística en español mexicano
- agregar referencia lógica en prompts/cot/committing.md hacia CoT de *changelog* para flujo coherente de actualización
- agregar validación de configuración de repositorio en CoT de *committing* con referencia a CoT de git_init para repos no configurados
- mejorar validación para detectar remotos HTTPS vs SSH: si `git remote -v` muestra https:// indica configuración incorrecta
- actualizar README.md y ROADMAP.md con menciones de CoT de *changelog* y mejoras a CoT de *committing* con validación SSH
- aplicar reglas lingüísticas a ROADMAP.md: corregir títulos a estilo oración y agregar cursivas a préstamos técnicos (*Sprint*, *commits*, *timestamps*)
- aplicar reglas lingüísticas a CHANGELOG.md: agregar cursivas a préstamos técnicos (*commit*, *git log*, *push*, *hook*, *prompt*, *git status*)

### fix
- corregir enlaces relativos rotos en prompts/cot/changelog.md tras movimiento de ubicación inicial

### refactor
- mover CRITICAL_COT_READING.md de raíz a docs/ para mejor organización
- consolidar CRITICAL_COMMIT_LANGUAGE.md y COMMIT_LANGUAGE_PROTOCOL.md en docs/COMMIT_LANGUAGE_PROTOCOL.md unificado
- limpiar raíz del repositorio eliminando archivos duplicados y moviendo protocolos a docs/
- remover directorio .githooks/ y *hook* pre-*commit* no funcional para simplificar estructura
- actualizar referencia en CHANGELOG.md para reflejar nueva ubicación de archivos
- eliminar sección de *git hooks* del README.md

### docs
- reforzar instrucciones de timezone en prompts/cot/committing.md para evitar error común de rotular CST a horas UTC
- añadir verificación obligatoria con `TZ=America/Mexico_City date` para obtener tiempo CST real
- incluir ejemplos prácticos de conversión: UTC 14:30 → CST 08:30, UTC 03:15 → CST 21:15 (día anterior)
- enfatizar cálculo matemático preciso: CST = UTC - 6 horas con manejo correcto de cambio de día
- actualizar README.md con sección mejorada de fechas/horas CST y ejemplos de verificación
- añadir comando para comparar UTC vs CST y ejemplos matemáticos de conversión

## [2025-09-10] - Mejoras al CoT *linguistics* y corrección crítica de regla de idioma en *commits*

### improve
- mejorar cot/linguistics.md con validación programática obligatoria para evitar aplicación superficial
- agregar comando obligatorio `grep -n "^#" archivo.md` en paso 6 para validación sistemática de títulos
- requerir documentación explícita de cada título encontrado y su corrección aplicada
- añadir sección de verificación obligatoria antes de completar el CoT
- prevenir omisión de corrección de Title Case mediante verificación programática forzada

### fix
- corregir inconsistencia en regla de idioma de *commits*: TODOS los mensajes de *commit* deben estar en inglés internacional
- actualizar prompts/cot/committing.md línea 15: enfatizar «CRÍTICO» para mensajes de *commit* en inglés
- actualizar referencia en docs/COMMIT_LANGUAGE_PROTOCOL.md para mantener consistencia con el texto corregido
- resolver conflicto entre reglas donde algunos documentos sugerían *commits* en español vs inglés
- clarificar distribución de idiomas: *commits* en inglés, documentación en español mexicano

## [2025-08-31] - Reestructuración completa del CHANGELOG

### docs
- reestructurar CHANGELOG.md: corregir estructura invertida (encabezado al inicio), consolidar secciones duplicadas, eliminar redundancias, estandarizar formato y agrupar micro-cambios relacionados

## [2025-08-29] - Corrección de inconsistencias de formato en CHANGELOG

### docs
- corregir inconsistencias de formato en CHANGELOG.md (entrada duplicada, encabezados sin títulos descriptivos y estructura jerárquica)

## [2025-08-28] - Especificación formato título descriptivo CHANGELOG

### docs
- agregar regla de título descriptivo para encabezados CHANGELOG.md usando formato '[YYYY-MM-DD] - Título descriptivo del cambio principal'
- actualizar COMMITTING.md para evitar emojis en CHANGELOG y mejorar *prompt* committing.md con análisis *git status* y *commits* múltiples

## [2025-08-25] - Corrección de editores interactivos y configuración SSH personal

### docs
- corregir COMMITTING.md y prompts/cot/committing.md para eliminar uso de editores interactivos, especialmente con *git log* (usar --no-pager)
- documentar problema común de `quote>` en *git commit* por escape incorrecto de comillas en mensajes

### fix
- configurar repositorio personal para usar identidad personal `incognia@gmail.com` y llave SSH personal (id_ed25519) en lugar de credenciales laborales

## [2025-08-18] - Reorganización de prompts, CoT y mejoras de documentación

### docs
- README.md: actualizar título a «Reglas técnicas: prompts y CoT para acelerar el contexto de los LLM» y añadir definiciones breves de «prompt» y «CoT» al inicio
- LINGUISTICS.md: corregir mayúsculas en «Estados Unidos» y añadir nota de nombres propios geopolíticos («Estado de México», «Estados Unidos»)
- LINGUISTICS.md: añadir «Sutilezas de redacción» (no iniciar oración con cifras; evitar terminar párrafos con símbolos/abreviaturas como % o «etc.»; usar «por ciento» y «etcétera»)
- PHILOSOPHY.md: reemplazar comillas rectas por comillas angulares («Agüelo», «Hagrid») según LINGUISTICS.md
- CORPORATE.md: alinear con LINGUISTICS.md (título en estilo oración y guion medio, comillas angulares, préstamos tipográficos, «nube pública» en lugar de «cloud público»)
- TEACHING.md: alinear con LINGUISTICS.md (minúscula tras dos puntos, traducciones en tabla, «preparación» por «setup»)
- prompts/cot/linguistics.md: ampliar checklist para cubrir todas las reglas de LINGUISTICS.md en orden lógico (calcos, terminología, verbos, préstamos, tipografía, comillas, sutilezas, siglas, tiempos, fechas CST, nomenclatura, odios, expresiones)
- COMMITTING.md: simplificar flujo a *push* simple (`git push`) y enlazar a configuración inicial en GIT.md
- GIT.md: añadir asistente interactivo post `git init` (configura identidad, `core.sshCommand` y remoto SSH opcional)
- prompts/cot/committing*.md: alinear a *push* simple y limpiar artefactos
- prompts/cot/committing_{personal,corporate}.md: consolidar en prompts/cot/committing.md y actualizar referencias
- prompts/cot/git_init.md: nuevo CoT para inicializar repos con SSH siguiendo GIT.md
- prompts/: crear estructura de subdirectorios (templates/, guides/, actions/, snippets/) con ejemplos y README por carpeta
- PROMPTS.md: añadir índice catalogado de prompts por subdirectorio
- BACKUPS.md: ampliar con restauración, verificación, zstd, rsync incrementales, cifrado/offsite, systemd y seguridad/permisos; política de checksums solo para archivos > 100 MB
- prompts/cot/backup.md y prompts/cot/restore.md: nuevos CoT para ejecutar respaldos y restauraciones
- BACKUPS.md: documentar respaldo rápido en el mismo directorio y su uso
- prompts/cot/quick_backup.md: nuevo CoT para respaldo rápido same-dir
- Reorganización: mover documentos temáticos a ./docs/ manteniendo PHILOSOPHY.md en la raíz
- Enlaces: corregir referencias cruzadas a documentos movidos en README.md, PHILOSOPHY.md, PROMPTS.md y prompts/* (cot, guides, actions)
- CHANGELOG.md: registrar actualización diaria sin cambios funcionales
- prompts/cot/committing_personal.md y prompts/cot/committing_corporate.md: eliminados; usar prompts/cot/committing.md
- README.md: añadir nota para desactivar MD041 tras el bloque `---` de front matter en CoT, asegurando renderizado correcto
- prompts/cot/*: auditoría de MD041 en CoT; confirmada colocación correcta de la etiqueta inmediatamente después del cierre del front matter
- style(md): corrección de espacios finales (MD009) en múltiples archivos (docs/*, prompts/cot/*, VAULT.md, LINGUISTICS.md, LICENSING.md)
- style(md): correcciones MD012 (eliminar líneas en blanco consecutivas) en TEACHING.md, BACKUPS.md y prompts/cot/lint.md
- style(md): correcciones MD022 (líneas en blanco alrededor de encabezados) en múltiples documentos (ATTRIBUTION.md, BACKUPS.md, STYLING.md, TEACHING.md, LINGUISTICS.md, LICENSING.md, PHILOSOPHY.md)

### feat
- scripts/git-init-context.sh: asistente interactivo para configurar identidad y SSH (por repo) y remoto SSH opcional
- scripts/backup_file.sh: respaldo de archivo/directorio con compresión zstd y checksums condicionados por tamaño
- scripts/backup_rsync_snapshot.sh: snapshots diarios incrementales con rsync --link-dest
- scripts/verify_backups.sh: verificación masiva de checksums
- scripts/quick_bkp.sh: respaldo rápido en el mismo directorio con fecha CST (YYYY-MM-DD)

### chore
- Añadir configuración de linter de Markdown (.markdownlint.yaml) alineada al estilo del repo
- Añadir verificador de enlaces (.markdownlinkcheck.json) con ajustes de tiempo de espera y cabeceras para shields.io
- Inicializar package.json con scripts: `lint:md`, `lint:md:fix`, `check:links`

### ci
- Limpiar repo: agregar .gitignore para excluir node_modules/ y artefactos; retirar node_modules/ del control con `git rm -r --cached`
- npm install: error E404 al intentar instalar paquete inexistente `markdownlint-cli2-fix@^0.3.0`; se eliminó del package.json
- Actualizar scripts npm: `lint:md` usa markdownlint-cli2 sin globs (se invoca con npx "**/*.md" "#node_modules")
- Ejecutar linter de Markdown: `npx markdownlint-cli2 "**/*.md" "#node_modules"` → 938 errores en 40 archivos
  - Principales reglas: MD013 (line-length), MD022/MD032 (líneas en blanco alrededor de encabezados/listas), MD040/MD031 (bloques de código sin lenguaje y sin líneas en blanco), MD041 (H1 en primera línea en prompts), MD024 (encabezados duplicados en CHANGELOG)
- Corrección rápida: ajustar enlace en README.md a `./docs/STYLING.md` para evitar 404
- Pendientes propuestos: relajar MD013 a 120, desactivar MD041 en `prompts/**`, permitir MD024 en CHANGELOG, añadir lenguaje a bloques de código y líneas en blanco alrededor de encabezados/listas

## [2025-08-17] - Implementación de CoT genérico y roadmap a 90 días

### docs
- prompts/cot/repo_context.md: CoT genérico para obtener contexto completo de repos GitHub/GitLab (estructura, dependencias, CI/CD, despliegue, estilo, pruebas, licencias y contribución)
- PROMPTS.md: guía inicial de CoT (formato, estilo, referencias) en es_MX; añadir sección de rutas de referencia «~/rules..."
- prompts/cot/_template.md: añadir uso de rutas «~/rules...». Ejemplos iniciales: arithmetic (renombrado desde aritmetica), devops, kubernetes, linguistics, styling y committing (personal/corporate) con referencias cruzadas añadidos
- GLOSSARY.md: añadir término «Cadena de razonamiento (Chain-of-Thought, CoT)» con referencias a PROMPTS.md y arXiv
- LINGUISTICS.md: corregir comillas; clarificar tiempos verbales; añadir sección de fechas/horas en CST
- COMMITTING.md: comandos explícitos con TZ=America/Mexico_City; flujo no interactivo para CHANGELOG
- STYLING.md: ejemplos de timestamps en CST (formato corto y largo en es_MX)
- README.md: sección de convenciones de fechas/horas (CST) y enlace a LINGUISTICS; enlaces a ROADMAP y TODO; nota sobre chain-of-thought (Wei et al., arXiv:2201.11903)
- PHILOSOPHY.md: referencias a ROADMAP y TODO en reglas universales
- ROADMAP.md: creado roadmap a 90 días (CoT, evaluación, automatización)
- TODO.md: creado plan táctico CoT (tareas inmediatas)
- TEACHING.md: restablecer énfasis ético en el uso exclusivo de software libre en K-12 y en divulgación; mejoras de redacción y principios transversales (bilingüismo, reproducibilidad, accesibilidad, CST)

### feat
- .githooks/pre-commit: *hook* opcional para bloquear 'CST' sin TZ=America/Mexico_City en líneas añadidas

## [2025-08-01] - Refinamiento de LINGUISTICS.md y desarrollo de TEACHING.md

### fix
- corregir terminología en LICENSING.md: cambiar "desarrollado por" por "elaborado por"
- alinear terminología con perfil de tecnólogo en lugar de desarrollador
- aplicar corrección tanto en proyectos laborales como personales

### docs
- añadir precisión en LINGUISTICS.md para evitar sobre-corrección de títulos de tercer nivel (###)
- agregar regla específica sobre NO corregir mayúsculas en títulos ### ya correctos
- incluir ejemplos claros de títulos de tercer nivel correctos e incorrectos
- extender introducción de PHILOSOPHY.md con dualidad profesional-educativa
- añadir apodos característicos ("Agüelo" en trabajo, "Hagrid" en aula) para reforzar identidad dual
- conectar combate contra males endémicos con democratización del conocimiento técnico
- mantener tono irreverente y español mexicano según LINGUISTICS.md
- mejorar redacción de párrafo de dualidad profesional-educativa con flow más natural
- refinar expresiones mexicanas y conexión directa con combate contra mercenazgo del código
- suavizar transición entre introducción irreverente y sección técnica
- eliminar redundancias entre introducción y sección de intersección profesional-educativa
- integrar mejor dualidad de contextos con el mensaje filosófico general
- extender sección de bilingüismo técnico con realidad del inglés en estudiantes mexicanos
- añadir reflexión sobre distancia cultural vs geográfica con EE.UU. en contexto educativo
- corregir puntuación y gramática en sección de contexto educativo
- añadir cita como epígrafe sobre el progreso tecnológico y científico
- mejorar redacción del epígrafe para incluir desarrollo tecnológico y descubrimientos científicos
- añadir regla de nomenclatura de archivos en inglés internacional en LINGUISTICS.md
- añadir regla específica para archivos Markdown con NOMBRES_EN_MAYUSCULAS.md
- corregir uso incorrecto de mayúsculas después de dos puntos en LINGUISTICS.md
- corregir mayúsculas adicionales en sección de nomenclatura de archivos y odios especiales
- añadir énfasis adicional a regla de mayúsculas después de dos puntos por ser error frecuente
- añadir ejemplos de uso correcto e incorrecto para mayúsculas después de dos puntos
- añadir regla sobre tiempos verbales en documentos: tiempo pasado para reportes, segunda persona para guías
- incluir ejemplos específicos para diferenciar reportes (tiempo pasado) vs guías (segunda persona)
- enfatizar evitar tercera persona impersonal en ambos tipos de documentos
- especificar en COMMITTING.md que el CHANGELOG.md debe usar únicamente fecha sin hora
- agregar GIT.md faltante en la lista de documentos incluidos en README.md
- agregar CHANGELOG.md a las referencias de reglas universales en PHILOSOPHY.md
- cambiar título de README.md para reflejar rol profesional y académico de tecnólogo
- desarrollar TEACHING.md con perfil educativo detallado basado en proyecto Juno
- incluir metodologías pedagógicas innovadoras usando herramientas DevOps
- documentar proyecto Juno como caso de estudio principal en educación STEM
- añadir proyecto Chicxulub como caso de estudio en divulgación científica interdisciplinaria: enfoque programación + geografía + ciencias de la Tierra, métricas de impacto divulgativo y metodología de contextualización histórica
- añadir métricas cuantitativas de impacto educativo (6+ años, 50+ estudiantes, 100+ contenedores) y especificar herramientas técnicas (Docker, JupyterLab, Python)
- incluir filosofía de divulgación científica y contribuciones a la comunidad educativa
- enfatizar actualización obligatoria del CHANGELOG.md en COMMITTING.md con proceso paso a paso
- añadir advertencias y ejemplos de flujo correcto para evitar olvidos en futuras actualizaciones

### docs (continuación)
- añadir filosofía de herramientas libres como parte fundamental de la metodología educativa
- enfatizar uso exclusivo de software libre en entornos educativos
- clarificar compromiso con licenciamiento GPL para todos los contenidos educativos
- documentar principios de libertad de software aplicados a la pedagogía
- añadir filosofía educativa multiplataforma (Linux, Windows, Mac)
- incluir analogía de herramientas para justificar enseñanza en múltiples sistemas operativos
- documentar postura crítica sobre sobreprecio y ética de plataformas cerradas
- enfatizar enseñanza de WSL en Windows como puente hacia entornos Unix
- refinar redacción y estructura de filosofía multiplataforma con secciones claras
- eliminar redundancias en principios fundamentales de competencia técnica

### fix (continuación)
- corregir TEACHING.md para cumplir con reglas de LINGUISTICS.md: cursivas en términos técnicos (*hands-on*), anglicismos (troubleshooting → resolución de problemas, feedback → retroalimentación), formato de préstamos lingüísticos
- corregir experiencia docente en TEACHING.md de 6+ años a 8 años y actualizar métricas de impacto educativo
- corregir terminología en TEACHING.md: "backup" → "respaldo", "debugging" → "depuración", "implementación" → "aplicación", "realizar" → "hacer", "Soporte" → "Compatibilidad"
- reorganizar estructura lógica de TEACHING.md: filosofía → especialización → competencias → proyectos → contexto → divulgación
- ampliar experiencia docente con enfoques Montessori, secundarias activas y programas sociales para poblaciones vulnerables
- añadir sección de intersección profesional-educativa en PHILOSOPHY.md conectando DevOps con pedagogía
- corregir typo en PHILOSOPHY.md: "intersacción" → "intersección"
- corregir especificaciones de zona horaria CST en múltiples documentos (BACKUPS.md, COMMITTING.md, STYLING.md): advertencia sobre conversión correcta UTC-6, uso de TZ="America/Mexico_City", ejemplo práctico 22:21 UTC → 16:21 CST

## [2025-07-31] - Separación GIT/COMMITTING y políticas de respaldo con CST

### docs
- agregar referencia a BACKUPS.md en README.md y PHILOSOPHY.md
- incluir BACKUPS.md en la sección de reglas universales que aplican a ambos contextos
- especificar uso obligatorio de zona horaria CST Ciudad de México en COMMITTING.md para fechas del CHANGELOG.md
- agregar comandos SSH específicos por contexto en COMMITTING.md (personal vs laboral)
- crear GIT.md con configuración inicial de cuentas GitHub y GitLab

### refactor
- separar responsabilidades entre GIT.md (setup inicial) y COMMITTING.md (flujo diario)
- eliminar redundancias entre ambos documentos
- enfocar GIT.md en configuración de repositorios nuevos
- enfocar COMMITTING.md en flujo de trabajo de *commits* y *push*
- diferenciar claramente entre AUTHORING.md y LICENSING.md por sus propósitos específicos
- refactorizar ATTRIBUTION.md para atribución personal en documentos/scripts individuales (solo proyectos personales)
- refactorizar LICENSING.md para generación de LICENSE en proyectos completos (personal y laboral)
- especificar que ATTRIBUTION.md se usa únicamente en contexto personal
- especificar que LICENSING.md aplica para ambos contextos
- renombrar AUTHORING.md a ATTRIBUTION.md para mejor reflejar su propósito
- organizar documentos en README.md y PHILOSOPHY.md según su uso: universal, dual, personal único, laboral único
- clasificar claramente GIT.md como regla universal
- clasificar CORPORATE.md como regla de uso dual
- especificar ATTRIBUTION.md como uso exclusivamente personal
- especificar STYLING.md como uso exclusivamente laboral

### fix
- corregir uso de mayúsculas después de dos puntos en README.md para cumplir con LINGUISTICS.md
- renombrar COMMITING.md a COMMITTING.md para corregir error ortográfico

### feat
- crear BACKUPS.md con políticas de respaldos y operaciones destructivas, zona horaria CST obligatoria y scripts actualizados con TZ="America/Mexico_City"
- añadir badges informativos al README.md (licencia GPLv3, Markdown, español mexicano) y sección de flujo de decisión para reglas duales

### style
- crear STYLING.md con reglas de estilo para documentos Markdown laborales: paleta corporativa (midnight, electric, lavender), estructura estándar para encabezados/pies, timestamp dinámico en español mexicano
- cambiar color de iconos en sección de contacto a --promad para consistencia visual

### docs (continuación)
- actualizar PHILOSOPHY.md para reflejar cambio de nombre de COMMITTING.md y añadir referencia a STYLING.md con alcance laboral
- mejorar documentación de colores CSS con nomenclatura descriptiva
- clarificar que información de licencia y timestamps deben ser dinámicos, no hardcodeados

## [2025-01-30] - Correcciones finales de mayúsculas y alineación con LINGUISTICS

### fix
- corregir uso de mayúsculas después de dos puntos en ATTRIBUTION.md para cumplir con las reglas de LINGUISTICS.md
- corregir uso de mayúsculas después de dos puntos en GLOSSARY.md para cumplir con las reglas de LINGUISTICS.md
- corregir casos restantes de mayúsculas después de dos puntos en ATTRIBUTION.md (sección de especialización profesional)
- corregir capitalización del título en README.md ("Ingeniero" → "ingeniero")

### style
- ajustar README.md para mejor alineación con LINGUISTICS.md (uso de minúsculas en listas y corrección de "acomplejos")
- actualizar formato de enlaces en PHILOSOPHY.md para que coincida con el estilo de README.md

---

<!-- markdownlint-disable MD036 -->
*Elaborado por Rodrigo Álvarez (@incognia)*
