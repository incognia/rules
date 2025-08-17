---
domain: workflow
task: commit/push en contexto personal (@incognia) con llave ~/.ssh/id_ed25519
dificultad: baja
longitud_objetivo: corta
validacion: commit/push exitosos y CHANGELOG actualizado
---

Razonamiento:
- Este flujo es para proyectos personales. Seguir «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md)) al pie de la letra.
- Asegurar fecha en CST para CHANGELOG y mensaje convencional en inglés.

Pasos:
1) Acción: calcular fecha CST.
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.
2) Acción: actualizar «CHANGELOG.md» bajo `## [${DATE_CST}]`.
   Resultado: línea de `- docs: ...` (o el tipo que aplique).
3) Acción: preparar commit.
   Resultado: `git add -A && git commit -m "docs: ..."`.
4) Acción: push con llave personal.
   Resultado: `GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519" git push origin main`.

Conclusión:
- Confirmar en `git log` y revisar que el CHANGELOG tenga la entrada del día en CST.
- Referencias: «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

