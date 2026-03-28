# Historial de cambios

**Nota:** Todas las fechas están en zona horaria CST de Ciudad de México (UTC-6).

<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->

## [2026-03-27] - Refactorización de estructura y AGENTS.md agnóstico

### refactor
- simplificar estructura de directorios del repositorio
  - renombrar `docs/` → `rulesets/` (más descriptivo del contenido)
  - mover `prompts/cot/` → `cot/` (raíz, eliminar anidamiento)
  - consolidar `prompts/actions/release.md` y `prompts/guides/git_workflow_guide.md` en `cot/`
  - mover `prompts/snippets/cst_date.sh` → `scripts/`
  - mover `prompts/templates/` → `templates/` (raíz)
  - eliminar estructura vacía `prompts/` y subdirectorios
  - actualizar 80+ referencias internas en documentación y CoTs
- renombrar `WARP.md` → `AGENTS.md`: archivo de reglas de proyecto agnóstico (reconocido por Warp, Claude, Cursor, Copilot, Gemini, etc.)
  - eliminar bloque `<citations>` (artefacto de Warp que no pertenece al archivo versionado)
  - reescribir contenido sin referencias específicas a Warp como producto
- eliminar archivos obsoletos: PROMPTS.md (redundante con README y CoTs), ROADMAP.md (6 meses sin actualizar), REFACTOR.md (reemplazado por este cambio)

### feat
- crear 6 *skills* descubribles por agentes IA en `.agents/skills/`
  - **commit**: flujo completo de *commit* con CHANGELOG obligatorio
  - **changelog**: mantenimiento de CHANGELOG.md con fechas CST
  - **linguistics**: aplicar reglas lingüísticas de español mexicano
  - **context**: detección rápida de contexto de proyecto
  - **backup**: respaldo de archivos/directorios con nomenclatura estándar
  - **licensing**: licenciamiento automático según contexto (GPLv3 vs MIT)
- crear 4 *workflows* YAML parametrizados en `.warp/workflows/`
  - **backup_file**: respaldar archivo/directorio individual
  - **lint_markdown**: ejecutar *markdownlint* en todos los archivos
  - **commit_flow**: flujo completo de *commit* con tipo y descripción
  - **cst_date**: obtener fecha/hora en CST (Ciudad de México)

### docs
- actualizar README.md: nueva estructura de directorios, sección de *skills* y *workflows*, corregir comandos de *symlink*
- actualizar PHILOSOPHY.md: reemplazar referencias a ROADMAP.md y TODO.md por AGENTS.md
- actualizar AGENTS.md: rutas a nueva estructura (`rulesets/`, `cot/`)

### fix
- corregir rutas de invocación en README.md: usar `~/rules/cot/` (ruta canónica) en lugar de `~/cot/` (dependiente de *symlink*) en ejemplos y diagrama Mermaid

### feat
- crear `scripts/sync_global.sh`: script multiplataforma para sincronizar *skills* y *workflows* globales
  - detecta automáticamente macOS, Linux y Windows/WSL
  - copia *skills* a `~/.agents/skills/` y *workflows* a la ruta correcta por plataforma
  - se puede ejecutar desde la copia local o directo desde el repo público

### docs
- reescribir sección de configuración inicial en README.md: simplificar a `git clone` + `sync_global.sh`
- eliminar enlace simbólico `~/cot`: no funciona bien en Warp con WSL; usar solo rutas canónicas
- agregar opción de ejecución remota sin clonar previamente
- documentar rutas por plataforma en notas del setup
- documentar acceso a *workflows* YAML vía *Workflow Search* (`Ctrl+Shift+R`) en macOS, Linux y Windows
- marcar como pendiente de validar las rutas de *workflows* en Linux y Windows

### improve
- parametrizar *skill* linguistics con argumento `$0` para archivo objetivo: `/linguistics README.md`

### feat
- crear *skill* git-init parametrizado con 4 argumentos: contexto (personal/laboral), nombre de llave SSH (se busca en `~/.ssh/`), URL remota y rama

### feat
- crear *skill* mail parametrizado para componer correos HTML compatibles con OWA: `/mail <delivery|generic> <asunto>`
- crear `rulesets/MAIL.md`: reglas de composición de correos HTML (restricciones de OWA, `bgcolor` en `<td>`, paleta de colores, *placeholders*)
- crear `cot/mail.md`: CoT de 9 pasos para elaborar correos desde plantillas
- migrar plantillas de correo del repo stab a `templates/mail/` (`delivery_template.html`, `generic_template.html`)
- migrar imagen de firma (`ralvarez_firma.png`) a `templates/mail/assets/` y corregir rutas en plantillas
- agregar paso obligatorio de firma con imagen en *skill* mail

- crear *skill* ssh-import parametrizado para importar llaves SSH a servidores remotos vía GitHub: `/ssh-import <faraday|cad> <user@server>`
  - `faraday` → servidores personales (GitHub: @incognia)
  - `cad` → servidores de clientes (GitHub: @incogniadev)
  - soporta 3 opciones: auto-importación Ubuntu, `ssh-import-id`/`curl` manual y *cloud-init*

### docs
- actualizar llaves SSH en todos los archivos: `id_ed25519` → `incognia` (personal), `promad_ed25519` → `kone` (laboral/repos)
- documentar convención de 4 llaves: `incognia` (repos personales), `kone` (repos laborales + infra), `faraday` (servidores personales), `cad` (servidores de clientes)

### docs
- actualizar README.md: lista completa de 9 *skills* con sintaxis, 4 *workflows*, 4 llaves SSH (repos + servers), MAIL.md en documentos, sync_global.sh en herramientas

### style
- aplicar LINGUISTICS.md a README.md: convertir texto suelto en encabezados (`Definiciones rápidas`, `Ejemplos de comandos`), cursivas en préstamos (*Prompt*, *Chain-of-Thought*), corregir calco «ciclar» → «navegar»

- aplicar LINGUISTICS.md a PHILOSOPHY.md: cursiva en préstamo (`Helm *charts*`), corregir calco «desarrollado» → «elaborado» en footer
- aplicar LINGUISTICS.md a CHANGELOG.md: cursiva en *overview* y *lint*, corregir calco «comprehensiva» → «exhaustiva», corregir errata «systemáticamente» → «sistemáticamente»

### feat
- crear *skill* `styling` parametrizado para aplicar estilo Kabat One a documentos Markdown por plataforma: `/styling <hedgedoc|gitlab|github> [mit|gpl] <archivo>`
  - encabezado con logo Kabat One, timestamp CST y tags YAML (exclusivo HedgeDoc)
  - pie de página con firma corporativa (exclusivo HedgeDoc); *copyright* GPLv3/MIT (solo README.md en GitLab/GitHub)
  - eliminación obligatoria de separadores `---` espurios; badges de licencia obligatorios
- crear plantillas por plataforma en `templates/`: `hedgedoc.md`, `gitlab-readme.md`, `github-readme.md`

### docs
- actualizar `rulesets/STYLING.md`: nuevo branding Kabat One, estructura por plataforma, tabla de diferencias de sintaxis, reglas de badges y plantillas
- actualizar `cot/styling.md`: reforzar regla de eliminación de `---` con paso programático
- actualizar `cot/changelog.md`: agregar validación obligatoria de entrada existente antes de crear encabezado nuevo para la misma fecha
- aplicar *styling* GitHub (GPLv3) a `README.md`: timestamp CST, corregir jerarquía `###` → `##` en «Definiciones rápidas», actualizar badge *Skills* (9 →10), agregar `/styling` a lista de *skills*
- aplicar *styling* GitHub a `PHILOSOPHY.md`: timestamp CST, eliminar 2 separadores `---` espurios (antes de `## Referencias` y antes del *copyright*)
- corregir formato de timestamp en `README.md` y `PHILOSOPHY.md`: sustituir `<div style>` por cursiva Markdown puro (`*Última modificación: ...*`) — GitLab y GitHub eliminan atributos `style`
- agregar frontmatter YAML (`title:`, `description:`) a plantillas y reglas de GitLab/GitHub: GitHub renderiza como tabla horizontal, GitLab como bloque de código; actualizar tabla de compatibilidad en `rulesets/STYLING.md`

## [2026-03-23]

### feat
- crear rulesets/LATEX.md: referencia completa de reglas para generar documentos LaTeX con XeLaTeX en Fedora (fuentes, tablas con `tabularx`+`booktabs`, bloques de código con `tcolorbox`, paleta PROMAD, encabezado/pie estándar, instalación de paquetes con `dnf`)
- crear cot/latex.md: CoT de 8 pasos para generar documentos LaTeX desde cero usando el Markdown como referencia de contenido
- documentar razón crítica para NO usar pandoc directo: tablas inconsistentes, bloques de código con fondo roto y encabezado/pie incontrolables

## [2026-03-23] - Regla de separadores en CoT de *styling*

### docs
- agregar regla crítica en cot/styling.md (paso 5): eliminar todos los `---` del cuerpo del documento; el único permitido es el que precede inmediatamente a `## Contacto`

## [2026-02-26]

### docs
- actualizar STYLING.md: cambiar título profesional de «Ingeniero DevOps» a «Líder DevOps» y correo corporativo de promad.com.mx a kabatone.com en plantilla de firma

## [2026-01-23]

### docs
- actualizar fechas de copyright de 2025 a 2026 en README.md, PHILOSOPHY.md, rulesets/VAULT.md, rulesets/LICENSING.md y cot/licensing.md
- actualizar fechas de ejemplo en rulesets/LICENSING.md de 2025-07-30 a 2026-01-23 en plantillas de encabezados para scripts Bash, Python y manifiestos YAML
- actualizar validación de fecha en cot/licensing.md de 2025 a 2026 para verificación de footer en README.md

## [2025-12-29]

### docs
- crear REFACTOR.md: checklist detallado para refactorización de estructura de directorios (9 fases, 60+ pasos, comandos ejecutables)

### style
- aplicar LINGUISTICS.md a REFACTOR.md: corregir 22 títulos de Title Case a estilo oración, agregar cursivas a préstamos técnicos (*symlink*, *snippet*, *commit*, *push*, *markdown-link-check*, *markdownlint*), corregir calcos del inglés («testing» → «pruebas», «linting» → «análisis estático»)

## [2025-10-15]

### docs
- clarificar COMMITTING.md: los archivos CoT se clasifican como `feat:` (funcionalidad automatizada) no `docs:` (documentación)


## [2025-10-11] - CoT para configuración de metadatos de GitHub sin editores

### feat
- crear cot/github_metadata.md: CoT funcional para configuración de repositorios GitHub evitando editores interactivos

## [2025-09-22] - Automatización de licenciamiento basado en análisis de proyecto

### docs
- crear cot/licensing.md: CoT automatizado que aplica licenciamiento apropiado (MIT para proyectos laborales, GPLv3 para personales) analizando indicadores en README.md
- implementar detección automática de naturaleza del proyecto: buscar menciones de "Promad", correo corporativo vs "@incognia", correo personal
- aplicar plantillas completas de licenciamiento según reglas establecidas en ../../rulesets/LICENSING.md
- generar archivo LICENSE con texto completo de licencia apropiada (MIT License o descargar GPL v3)
- agregar footer de licenciamiento correcto al README.md con información de copyright y distribución
- incluir validación programática para verificar creación correcta de archivos y aplicación de cambios

## [2025-09-19] - Priorización del flujo de trabajo diario con CoT y badge de cobertura

### docs
- actualizar README.md: priorizar flujo de trabajo diario con CoT moviendo sección a posición prominente después del *overview* académico
- documentar configuración inicial completa: clonado en ~/rules y creación de enlace simbólico ~/cot para acceso rápido
- especificar compatibilidad con macOS y Linux para el flujo de enlace simbólico
- agregar ejemplos de uso diario con rutas cortas (~/cot/committing.md, ~/cot/context.md, ~/cot/changelog.md)
- enfatizar principio operativo: documentos rulesets/ para lógica vs CoT cot/ para herramientas de trabajo diarias
- incluir comandos para recrear enlace simbólico y notas de troubleshooting
- agregar badge CoT Coverage (43%) con enlace al ROADMAP para seguimiento visual del progreso
- reorganizar README para mostrar flujo de trabajo como información prioritaria inmediatamente después del contexto académico
- agregar diagramas mermaid para ilustrar visualmente el flujo de configuración inicial y el flujo de uso diario de CoT
- crear diagrama de configuración (flowchart TD) mostrando proceso desde sistema limpio hasta configuración completa
- incluir diagrama de uso diario (flowchart LR) con opciones de CoT más comunes y convergencia hacia ejecución en LLM
- aplicar colores diferenciados: rosa para inicio, verde para éxito, azul para referencias conceptuales
- integrar diagramas orgánicamente con comandos paso a paso y ejemplos de invocación para mejor *onboarding*

### fix
- corregir comando de enlace simbólico en configuración inicial: usar `ln -s ~/rules/prompts/cot cot` (sin ~ en destino) para correcta creación de enlace local
- actualizar comando de recreación de enlace para mantener consistencia con la sintaxis corregida
- aplicar reglas lingüísticas de LINGUISTICS.md al README.md: corregir calco del inglés "desarrollado" por "elaborado" en footer del proyecto
- verificar todos los títulos y encabezados (25 líneas encontradas): confirmar uso correcto de estilo oración sin "Título Con Cada Palabra En Mayúscula"
- validar uso correcto de préstamos técnicos en cursiva (*commit*, *bare-metal*, *CoT*, *pipeline*, etc.) y terminología en español mexicano estándar

## [2025-09-18] - Mejoras integrales a CoT de contexto y committing para infraestructura y cuentas múltiples

### docs
- afinar cot/context.md v2.1: agregar búsqueda de READMEs en subdirectorios de segundo y tercer nivel para proyectos colaborativos con múltiples equipos
- extender detección técnica para incluir archivos de configuración de Kubernetes en todo el repositorio (no solo raíz)
- agregar búsqueda exhaustiva de archivos kubeconfig, kube.config y .kubeconfig en cualquier nivel del repositorio
- incluir búsqueda completa de configuraciones Talos: talosconfig, talos.config y .talosconfig para uso con comandos EXPORT
- ampliar detección de manifests YAML de Kubernetes: buscar deployment, service, ingress, configmap, secret en profundidad
- incluir detección de directorios estándar de Kubernetes: k8s/, kubernetes/, manifests/
- agregar soporte para docker-compose.yaml además de docker-compose.yml
- reorganizar detección por categorías: lenguajes/frameworks, contenedores/orquestación, configuración de clusters, CI/CD
- expandir documentación de hallazgos para incluir orquestación, configuración de clusters y READMEs adicionales
- agregar lectura automática de READMEs encontrados en subdirectorios con primeras 20 líneas
- incluir detección de GitLab CI (.gitlab-ci.yml) además de GitHub Actions
- extender cot/context.md para buscar archivos AGENTS.md y .warp.md en el análisis de documentación del proyecto
- incluir ambas variantes (AGENTS.md estándar y .warp.md como *dotfile*) en verificación de existencia y lectura automática
- agregar referencias específicas para configuración y reglas de proyecto en sección de Referencias del CoT
- crear AGENTS.md con guía completa para instancias futuras de WARP terminal en este repositorio
- incluir descripción del propósito del repositorio (reglas técnicas, filosofía y CoT para LLM)
- documentar filosofía central: combatir mercenazgo, egoísmo técnico y pérdida de identidad cultural
- especificar comandos de desarrollo común: lint markdown (npm run lint:md), verificación de enlaces, scripts de respaldo
- detallar flujo de commits crítico: actualizar CHANGELOG.md primero, luego add/commit/push
- documentar arquitectura de directorios: rulesets/ (reglas), prompts/ (CoT y plantillas), scripts/ (herramientas)
- incluir contextos duales: personal (@incognia, GPLv3) vs corporativo (@incogniadev, MIT)
- especificar sistema Chain-of-Thought con formato estructurado (Razonamiento, Pasos, Conclusión)
- documentar manejo crítico de zona horaria CST (UTC - 6 horas, nunca solo agregar sufijo)
- incluir especialización técnica: Kubernetes, GitOps, mallas de servicios, observabilidad
- definir 7 reglas clave incluyendo lectura completa de CoT y flujo obligatorio de CHANGELOG
- establecer integración con otros repositorios mediante rutas ~/rules/

### improve
- afinar cot/committing.md v1.1: agregar validación visual de identidad activa para usuarios con múltiples cuentas y llaves SSH
- incluir display obligatorio de email, nombre, llave SSH y remoto antes de proceder con commits
- agregar verificación crítica para confirmar que la identidad mostrada coincide con la esperada para el repositorio
- incorporar pistas específicas para usuarios con cuentas múltiples en sección de conclusiones

## [2025-09-17] - Mejoras críticas para cálculo preciso de zona horaria CST y reorganización estructural

### feat
- crear cot/context.md v2.0: CoT genérico portable para cualquier proyecto con detección automática de tecnologías (Node.js, Python, Go, Rust, Java, Docker), análisis de estructura con *tree*, instalación multiplataforma (*dnf*, *apt*, *apk*, *pacman*, *brew*) y identificación de archivos de documentación estándar

### docs
- actualizar README.md: añadir referencia a CoT genérico context.md en sección de uso rápido
- actualizar ROADMAP.md: incrementar estadísticas de CoT (14→15 archivos, 57%→60% independientes), documentar progreso *Sprint* 1 con CoT completado y actualizar infraestructura completada con características del nuevo CoT
- consolidar ROADMAP.md en raíz combinando infraestructura CoT con análisis de cobertura específica
- consolidar ROADMAP.md en raíz combinando infraestructura CoT con análisis de cobertura específica
- corregir sistemáticamente errores de *lint* Markdown en archivos principales (README, ROADMAP, CHANGELOG, PROMPTS, PHILOSOPHY)
- añadir espacios en blanco alrededor de encabezados y listas según MD022/MD032
- corregir enlaces huérfanos tras movimiento de rulesets/ROADMAP.md a raíz
- especificar lenguajes en bloques de código y corregir prefijos de listas ordenadas
- instalar y configurar npm/nodejs para verificación de enlaces y lint automático
- crear CoT para mantenimiento de *changelog* en cot/changelog.md con corrección de errores comunes: orden cronológico inverso, cálculo preciso de CST, detección de duplicados y consistencia lingüística en español mexicano
- agregar referencia lógica en cot/committing.md hacia CoT de *changelog* para flujo coherente de actualización
- agregar validación de configuración de repositorio en CoT de *committing* con referencia a CoT de git_init para repos no configurados
- mejorar validación para detectar remotos HTTPS vs SSH: si `git remote -v` muestra https:// indica configuración incorrecta
- actualizar README.md y ROADMAP.md con menciones de CoT de *changelog* y mejoras a CoT de *committing* con validación SSH
- aplicar reglas lingüísticas a ROADMAP.md: corregir títulos a estilo oración y agregar cursivas a préstamos técnicos (*Sprint*, *commits*, *timestamps*)
- aplicar reglas lingüísticas a CHANGELOG.md: agregar cursivas a préstamos técnicos (*commit*, *git log*, *push*, *hook*, *prompt*, *git status*)

### fix
- corregir enlaces relativos rotos en cot/changelog.md tras movimiento de ubicación inicial

### refactor
- mover CRITICAL_COT_READING.md de raíz a rulesets/ para mejor organización
- consolidar CRITICAL_COMMIT_LANGUAGE.md y COMMIT_LANGUAGE_PROTOCOL.md en rulesets/COMMIT_LANGUAGE_PROTOCOL.md unificado
- limpiar raíz del repositorio eliminando archivos duplicados y moviendo protocolos a rulesets/
- remover directorio .githooks/ y *hook* pre-*commit* no funcional para simplificar estructura
- actualizar referencia en CHANGELOG.md para reflejar nueva ubicación de archivos
- eliminar sección de *git hooks* del README.md

### docs
- reforzar instrucciones de timezone en cot/committing.md para evitar error común de rotular CST a horas UTC
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
- actualizar cot/committing.md línea 15: enfatizar «CRÍTICO» para mensajes de *commit* en inglés
- actualizar referencia en rulesets/COMMIT_LANGUAGE_PROTOCOL.md para mantener consistencia con el texto corregido
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
- corregir COMMITTING.md y cot/committing.md para eliminar uso de editores interactivos, especialmente con *git log* (usar --no-pager)
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
- cot/linguistics.md: ampliar checklist para cubrir todas las reglas de LINGUISTICS.md en orden lógico (calcos, terminología, verbos, préstamos, tipografía, comillas, sutilezas, siglas, tiempos, fechas CST, nomenclatura, odios, expresiones)
- COMMITTING.md: simplificar flujo a *push* simple (`git push`) y enlazar a configuración inicial en GIT.md
- GIT.md: añadir asistente interactivo post `git init` (configura identidad, `core.sshCommand` y remoto SSH opcional)
- cot/committing*.md: alinear a *push* simple y limpiar artefactos
- cot/committing_{personal,corporate}.md: consolidar en cot/committing.md y actualizar referencias
- cot/git_init.md: nuevo CoT para inicializar repos con SSH siguiendo GIT.md
- prompts/: crear estructura de subdirectorios (templates/, guides/, actions/, snippets/) con ejemplos y README por carpeta
- PROMPTS.md: añadir índice catalogado de prompts por subdirectorio
- BACKUPS.md: ampliar con restauración, verificación, zstd, rsync incrementales, cifrado/offsite, systemd y seguridad/permisos; política de checksums solo para archivos > 100 MB
- cot/backup.md y cot/restore.md: nuevos CoT para ejecutar respaldos y restauraciones
- BACKUPS.md: documentar respaldo rápido en el mismo directorio y su uso
- cot/quick_backup.md: nuevo CoT para respaldo rápido same-dir
- Reorganización: mover documentos temáticos a ./rulesets/ manteniendo PHILOSOPHY.md en la raíz
- Enlaces: corregir referencias cruzadas a documentos movidos en README.md, PHILOSOPHY.md, PROMPTS.md y prompts/* (cot, guides, actions)
- CHANGELOG.md: registrar actualización diaria sin cambios funcionales
- cot/committing_personal.md y cot/committing_corporate.md: eliminados; usar cot/committing.md
- README.md: añadir nota para desactivar MD041 tras el bloque `---` de front matter en CoT, asegurando renderizado correcto
- cot/*: auditoría de MD041 en CoT; confirmada colocación correcta de la etiqueta inmediatamente después del cierre del front matter
- style(md): corrección de espacios finales (MD009) en múltiples archivos (rulesets/*, cot/*, VAULT.md, LINGUISTICS.md, LICENSING.md)
- style(md): correcciones MD012 (eliminar líneas en blanco consecutivas) en TEACHING.md, BACKUPS.md y cot/lint.md
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
- Corrección rápida: ajustar enlace en README.md a `./rulesets/STYLING.md` para evitar 404
- Pendientes propuestos: relajar MD013 a 120, desactivar MD041 en `prompts/**`, permitir MD024 en CHANGELOG, añadir lenguaje a bloques de código y líneas en blanco alrededor de encabezados/listas

## [2025-08-17] - Implementación de CoT genérico y roadmap a 90 días

### docs
- cot/repo_context.md: CoT genérico para obtener contexto completo de repos GitHub/GitLab (estructura, dependencias, CI/CD, despliegue, estilo, pruebas, licencias y contribución)
- PROMPTS.md: guía inicial de CoT (formato, estilo, referencias) en es_MX; añadir sección de rutas de referencia «~/rules..."
- cot/_template.md: añadir uso de rutas «~/rules...». Ejemplos iniciales: arithmetic (renombrado desde aritmetica), devops, kubernetes, linguistics, styling y committing (personal/corporate) con referencias cruzadas añadidos
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

### feat
- crear *skill* git-init parametrizado con 4 argumentos: contexto (personal/laboral), llave SSH, URL remota y rama

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

### feat
- crear *skill* git-init parametrizado con 4 argumentos: contexto (personal/laboral), llave SSH, URL remota y rama

### style
- ajustar README.md para mejor alineación con LINGUISTICS.md (uso de minúsculas en listas y corrección de "acomplejos")
- actualizar formato de enlaces en PHILOSOPHY.md para que coincida con el estilo de README.md

---

<!-- markdownlint-disable MD036 -->
*Elaborado por Rodrigo Álvarez (@incognia)*
