# Historial de cambios

**Nota:** Todas las fechas y horas están en zona horaria CST de Ciudad de México (UTC-6).

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
- corregir uso de mayúsculas después de dos puntos en AUTHORING.md para cumplir con las reglas de LINGUISTICS.md
- corregir uso de mayúsculas después de dos puntos en GLOSSARY.md para cumplir con las reglas de LINGUISTICS.md
- corregir casos restantes de mayúsculas después de dos puntos en AUTHORING.md (sección de especialización profesional)
- corregir capitalización del título en README.md ("Ingeniero" → "ingeniero")

### style
- ajustar README.md para mejor alineación con LINGUISTICS.md (uso de minúsculas en listas y corrección de "acomplejos")
- actualizar formato de enlaces en PHILOSOPHY.md para que coincida con el estilo de README.md
