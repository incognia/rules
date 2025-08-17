---
domain: workflow
task: commit/push en contexto laboral (@incogniadev) con llave ~/.ssh/promad_ed25519
dificultad: baja
longitud_objetivo: corta
validacion: commit/push exitosos y CHANGELOG actualizado
---

Razonamiento:
- Este flujo es para proyectos laborales (Promad). Seguir «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md)).
- Asegurar fecha en CST para CHANGELOG y mensaje convencional en inglés.

Pasos:
1) Acción: calcular fecha CST.
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.
2) Acción: actualizar «CHANGELOG.md» bajo `## [${DATE_CST}]`.
   Resultado: línea de `- docs: ...` (o el tipo que aplique).
3) Acción: preparar commit.
   Resultado: `git add -A [0m&& git commit -m "docs: ..."`.
4) Acción: push con llave laboral.
   Resultado: `GIT_SSH_COMMAND="ssh -i ~/.ssh/promad_ed25519" git push origin main`.

Conclusión:
- Confirmar en `git log` y revisar que el CHANGELOG tenga la entrada del día en CST.
- Referencias: «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

