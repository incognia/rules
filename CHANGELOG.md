# Historial de cambios

**Nota:** Todas las fechas y horas están en zona horaria CST de Ciudad de México (UTC-6).

## [2025-08-01]

### docs
- desarrollar TEACHING.md con perfil educativo detallado basado en proyecto Juno
- incluir metodologías pedagógicas innovadoras usando herramientas DevOps
- documentar proyecto Juno como caso de estudio principal en educación STEM
- añadir proyecto Chicxulub como ejemplo de divulgación científica interdisciplinaria
- añadir métricas cuantitativas de impacto educativo (6+ años, 50+ estudiantes, 100+ contenedores)
- especificar herramientas técnicas utilizadas en el aula (Docker, JupyterLab, Python)
- incluir filosofía de divulgación científica y contribuciones a la comunidad educativa
- añadir proyecto Chicxulub como segundo caso de estudio en divulgación científica
- documentar enfoque interdisciplinario (programación + geografía + ciencias de la Tierra)
- incluir métricas de impacto divulgativo y metodología de contextualización histórica
- enfatizar actualización obligatoria del CHANGELOG.md en COMMITTING.md con proceso paso a paso
- añadir advertencias y ejemplos de flujo correcto para evitar olvidos en futuras actualizaciones

### fix
- corregir TEACHING.md para cumplir con reglas de LINGUISTICS.md
- poner cursivas en términos técnicos sin traducción directa (*hands-on*)
- reemplazar anglicismos (troubleshooting → resolución de problemas, feedback → retroalimentación)
- aplicar formato correcto para préstamos lingüísticos según estándares mexicanos

### fix
- corregir experiencia docente en TEACHING.md de 6+ años a 8 años
- actualizar métricas de impacto educativo para reflejar experiencia real

### docs
- añadir filosofía de herramientas libres como parte fundamental de la metodología educativa
- enfatizar uso exclusivo de software libre en entornos educativos
- clarificar compromiso con licenciamiento GPL para todos los contenidos educativos
- documentar principios de libertad de software aplicados a la pedagogía
- añadir filosofía educativa multiplataforma (Linux, Windows, Mac)
- incluir analogía de herramientas para justificar enseñanza en múltiples sistemas operativos
- documentar postura crítica sobre sobreprecio y ética de plataformas cerradas
- enfatizar enseñanza de WSL en Windows como puente hacia entornos Unix

## [2025-07-31]

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
- enfocar COMMITTING.md en flujo de trabajo de commits y push
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

### feat
- crear BACKUPS.md con políticas de respaldos y operaciones destructivas
- especificar zona horaria CST obligatoria para todos los timestamps
- actualizar scripts de respaldo para usar TZ="America/Mexico_City"

### feat
- añadir badges informativos al README.md (licencia GPLv3, Markdown, español mexicano)
- crear sección de flujo de decisión en README.md para explicar aplicación de reglas duales (personal/laboral)

### style
- cambiar color de iconos en sección de contacto a --promad para mejor consistencia visual
- crear STYLING.md con reglas de estilo para documentos Markdown laborales
- definir paleta de colores corporativa con nombres descriptivos (midnight, electric, lavender)
- establecer estructura estándar para encabezados y pies de página corporativos
- incluir timestamp dinámico con formato legible en español mexicano

### fix
- renombrar COMMITING.md a COMMITTING.md para corregir error ortográfico

### docs
- actualizar PHILOSOPHY.md para reflejar el cambio de nombre de COMMITTING.md
- añadir referencia a STYLING.md en PHILOSOPHY.md con aclaración de alcance laboral
- mejorar documentación de colores CSS con nomenclatura más descriptiva
- clarificar que información de licencia y timestamps deben ser dinámicos, no hardcodeados

## [2025-01-30]

### fix
- corregir uso de mayúsculas después de dos puntos en ATTRIBUTION.md para cumplir con las reglas de LINGUISTICS.md
- corregir uso de mayúsculas después de dos puntos en GLOSSARY.md para cumplir con las reglas de LINGUISTICS.md
- corregir casos restantes de mayúsculas después de dos puntos en ATTRIBUTION.md (sección de especialización profesional)
- corregir capitalización del título en README.md ("Ingeniero" → "ingeniero")

### style
- ajustar README.md para mejor alineación con LINGUISTICS.md (uso de minúsculas en listas y corrección de "acomplejos")
- actualizar formato de enlaces en PHILOSOPHY.md para que coincida con el estilo de README.md

---

*Elaborado por Rodrigo Álvarez (@incognia)*
