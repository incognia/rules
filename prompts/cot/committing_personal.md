---
domain: workflow
task: commit/push en contexto personal (@incognia) con push simple
dificultad: baja
longitud_objetivo: corta
validacion: commit/push exitosos y CHANGELOG actualizado
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Este flujo es para proyectos personales. Seguir «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)) al pie de la letra.
- Asegurar fecha en CST para CHANGELOG y mensaje convencional en inglés.
- El push debe ser simple (`git push`) si el repo fue configurado inicialmente según «~/rules/GIT.md».

Pasos:
1) Acción: calcular fecha CST.
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.
2) Acción: actualizar «CHANGELOG.md» bajo `## [${DATE_CST}]`.
   Resultado: línea de `- docs: ...` (o el tipo que aplique).
3) Acción: preparar commit.
   Resultado: `git add -A && git commit -m "docs: ..."`.
4) Acción: push simple.
   Resultado: `git push`.

Conclusión:
- Confirmar en `git log` y revisar que el CHANGELOG tenga la entrada del día en CST.
- Referencias: «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)), «~/rules/docs/GIT.md» ([../../docs/GIT.md](../../docs/GIT.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

