---
domain: workflow
task: seguir COMMITTING.md (actualizar CHANGELOG, commit convencional y push con llave personal)
dificultad: baja
longitud_objetivo: corta
validacion: entrada en CHANGELOG con fecha CST y commit/push exitosos
---

Razonamiento:
- Cumplir el flujo obligatorio: primero CHANGELOG, luego add/commit/push (ver «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md))).
- Usar fecha en CST (Ciudad de México) calculada con TZ; no rotular CST a horas UTC.
- Mensaje de commit en inglés con Conventional Commits; documentación en español mexicano.

Pasos:
1) Acción: obtener la fecha CST para el CHANGELOG (sin hora).
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.
2) Acción: editar CHANGELOG.md y agregar la entrada bajo `## [${DATE_CST}]` en la sección correspondiente.
   Resultado: nueva línea tipo `- docs: descripción breve del cambio` en español mexicano (solo fecha, sin hora).
3) Acción: añadir archivos al índice.
   Resultado: `git add -A`.
4) Acción: crear commit no interactivo con mensaje convencional en inglés.
   Resultado: `git commit -m "docs: update CHANGELOG and related docs"` (ajusta tipo/scope según cambio real).
5) Acción: push con llave SSH personal (contexto @incognia).
   Resultado: `GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519" git push origin main`.

Conclusión:
- Verifica que el commit aparece en `git log` y que el CHANGELOG contiene la fecha en CST y el resumen del cambio.
- Referencias: «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md)), «~/rules/README.md» ([../../README.md](../../README.md)) y «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)).

