---
domain: release
task: validar historial, derivar descriptor/notas y publicar release semántica no interactiva
dificultad: media
longitud_objetivo: media
validacion: tag remoto único, release alineada y notas en formato oficial
version: "1.0"
last_updated: 2026-05-05
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- La publicación debe seguir convención estricta de tags `vX.Y.Z` y flujo `dev -> main (ff-only) -> tag -> release -> volver a dev`.
- Antes de crear una versión nueva, se valida consistencia histórica para evitar arrastrar errores de formato.
- El nombre y las notas de release se deben derivar de cambios reales desde el último tag, no inventarse.
- Toda la ejecución debe ser no interactiva: sin editores, con `--notes-file`, y con verificaciones explícitas.

Pasos:
0) Acción: validar argumento recibido por la invocación `/release vX.Y.Z`.
   Validación: debe cumplir `^v[0-9]+\\.[0-9]+\\.[0-9]+$`.
   Resultado: variable `TARGET_VERSION` válida (ej. `v0.5.0`).

1) Acción: cargar reglas y estado inicial.
   Referencias: `~/rules/rulesets/RELEASING.md`, `~/rules/rulesets/COMMITTING.md` y `AGENTS.md` del repositorio objetivo.
   Verificaciones:
   - working tree limpio (`git status --short`);
   - rama actual esperada (`dev`);
   - acceso a remoto y API de releases.
   Resultado: contexto listo para publicar.

2) Acción: validar baseline histórico de `zabbix-k1` antes de la nueva release.
   Tags esperados en remoto:
   - `v0.1.0`
   - `v0.2.0`
   - `v0.3.0`
   - `v0.4.0`
   Releases esperadas:
   - `v0.1.0 — MVP`
   - `v0.2.0 — NOC 16:9`
   - `v0.3.0 — NOC operativo y gobernanza`
   - `v0.4.0 — Collector-first robusto`
   Resultado: consistencia confirmada o lista de discrepancias a corregir antes de continuar.

3) Acción: validar que la versión objetivo no exista ya.
   Comandos guía:
   - `git rev-parse -q --verify "refs/tags/${TARGET_VERSION}"`
   - `git ls-remote --tags origin "${TARGET_VERSION}" "${TARGET_VERSION}^{}"`
   - `glab api "projects/operaciones-ti%2Fzabbix-k1/releases/${TARGET_VERSION}"`
   Resultado: confirmación de que no hay colisión de tag/release para `TARGET_VERSION`.

4) Acción: identificar el tag previo y rango de cambios para la nueva release.
   Comandos guía:
   - `PREV_TAG=$(git --no-pager tag --list 'v*' --sort=version:refname | tail -n 1)`
   - `git --no-pager log --pretty=format:'%s' "${PREV_TAG}..dev"`
   - `git --no-pager log --name-only --pretty=format:'%h %s' "${PREV_TAG}..dev"`
   Resultado: insumo concreto para construir descriptor y bullets relevantes.

5) Acción: derivar descriptor corto y nombre final de release.
   Heurística obligatoria:
   - Priorizar `feat` sobre `fix/perf/docs/chore` para el descriptor.
   - Si hay múltiples temas, usar el impacto dominante para operación/NOC.
   - Descriptor en español, breve y específico.
   Formato final: `RELEASE_NAME="${TARGET_VERSION} — ${DESCRIPTOR}"`.
   Resultado: nombre de release consistente con historial.

6) Acción: generar notas de release no interactivas en archivo temporal.
   Ruta sugerida: `/tmp/release-notes-${TARGET_VERSION}.md`.
   Estructura mínima obligatoria:
   - párrafo introductorio corto;
   - encabezado `## Funcionalidades incluidas`;
   - bullets con cambios relevantes y verificables del rango `${PREV_TAG}..dev`.
   Resultado: archivo de notas listo para `glab release create/update --notes-file`.

7) Acción: promover `dev` a `main` con fast-forward y publicar tag.
   Secuencia:
   - `git checkout main`
   - `git merge --ff-only dev`
   - `git push origin main`
   - `git tag -a "${TARGET_VERSION}" -m "release: ${TARGET_VERSION}"`
   - `git push origin "${TARGET_VERSION}"`
   Resultado: `main` publicado y tag anotado visible en remoto.

8) Acción: crear o actualizar release en GitLab sin modo interactivo.
   Secuencia recomendada:
   - si no existe release:
     `glab release create "${TARGET_VERSION}" --name "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
   - si existe release:
     `glab release update "${TARGET_VERSION}" --name "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
   Resultado: release asociada al tag con nombre/notas correctos.

9) Acción: verificar publicación final.
   Validaciones obligatorias:
   - `git ls-remote --tags origin "${TARGET_VERSION}" "${TARGET_VERSION}^{}"` devuelve sólo el tag esperado;
   - `glab release list` incluye `TARGET_VERSION`;
   - `glab api "projects/operaciones-ti%2Fzabbix-k1/releases/${TARGET_VERSION}"` refleja nombre y notas con convención.
   Resultado: publicación validada.

10) Acción: volver a rama de desarrollo.
    Comando: `git checkout dev`.
    Resultado: flujo cerrado y repo listo para continuar trabajo.

Conclusión:
- Una release se considera correcta sólo si pasa validación histórica, evita colisiones de versión, deriva descriptor/notas desde cambios reales y cumple el flujo no interactivo completo.
- Si hay inconsistencias de formato previas, primero se corrigen y luego se publica la nueva versión.
- Referencias: `~/rules/rulesets/RELEASING.md`, `~/rules/rulesets/COMMITTING.md`, `AGENTS.md` del repo objetivo.

