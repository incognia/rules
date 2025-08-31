---
domain: workflow
task: seguir COMMITTING.md (actualizar CHANGELOG, commit convencional y push simple)
dificultad: baja
longitud_objetivo: corta
validacion: entrada en CHANGELOG con fecha CST y commit/push exitosos
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Cumplir el flujo obligatorio: primero CHANGELOG, luego add/commit/push (ver «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md))).
- CRÍTICO: usar `git status` para analizar los cambios antes de proceder y determinar si requieren commits separados.
- Evaluar si los cambios son de tipos mixtos (ej. feat + fix, docs + refactor) que requieran commits atómicos separados.
- Usar fecha en CST (Ciudad de México) calculada con TZ; no rotular CST a horas UTC.
- Mensaje de commit en inglés con Conventional Commits; documentación en español mexicano.
- El push debe ser simple (`git push`) siempre que el repo haya sido configurado inicialmente (ver «~/rules/GIT.md» sección de configuración inicial).

Pasos:
0) Acción: analizar el estado actual del repositorio para identificar tipos de cambios.
   Resultado: `git status` - examinar archivos modificados/añadidos/eliminados y sus propósitos.
   Evaluación: determinar si los cambios son de un solo tipo (ej. solo docs) o mixtos (ej. feat + fix).
   Decisión: si son mixtos, planificar commits atómicos separados usando `git add` selectivo por archivo/directorio.

1) Acción: obtener la fecha CST para el CHANGELOG (sin hora).
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.

2) Acción: editar CHANGELOG.md y agregar entrada(s) bajo `## [${DATE_CST}]` según tipos de cambios identificados.
   Resultado: nueva(s) línea(s) tipo `- docs: descripción breve del cambio` en español mexicano (solo fecha, sin hora).
   Nota: si hay múltiples tipos, agregar una línea por cada tipo de cambio.

3) Acción: realizar commits atómicos según análisis del paso 0.
   - Si cambios homogéneos (un tipo): `git add -A && git commit -m "tipo: descripción"`
   - Si cambios mixtos: commits separados usando `git add archivo(s)` selectivo por cada tipo:
     * `git add archivo1 archivo2 && git commit -m "feat: descripción funcionalidad"`
     * `git add archivo3 && git commit -m "fix: descripción corrección"`
     * etc.

4) Acción: push simple de todos los commits.
   Resultado: `git push`.

5) Acción: verificación no interactiva de los commits realizados.
   Resultado: `git --no-pager log --oneline -5` (ver últimos commits sin paginador).

Conclusión:
- Verifica que el/los commit(s) aparecen en `git --no-pager log --oneline -5` y que el CHANGELOG contiene la fecha en CST y el resumen de todos los cambios.
- Si fueron commits múltiples, asegurar que cada uno es atómico y tiene mensaje convencional apropiado (feat, fix, docs, etc.).
- Si aparece `quote>` durante el commit: presionar Ctrl+C y revisar escape de comillas en el mensaje.
- La atomicidad de commits facilita el mantenimiento: cada commit debe representar un cambio lógico único y funcional.
- Referencias: «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)), «~/rules/docs/GIT.md" ([../../docs/GIT.md](../../docs/GIT.md)), «~/rules/README.md" ([../../README.md](../../README.md)) y «~/rules/docs/LINGUISTICS.md" ([../../docs/LINGUISTICS.md](../../docs/LINGUISTICS.md)).

