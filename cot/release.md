---
domain: release
task: validar historial, derivar descriptor/notas y publicar release semántica no interactiva en GitHub o GitLab
dificultad: media
longitud_objetivo: media
validacion: tag remoto único, release alineada y notas en formato oficial
version: "2.1"
last_updated: 2026-10-07
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- La publicación sigue la convención estricta de tags `vX.Y.Z`. El flujo depende del repositorio: con rama `dev`, `dev -> main (ff-only) -> tag -> release -> volver a dev`; sin `dev`, `main -> tag -> release`.
- La plataforma (GitHub o GitLab) y el idioma de las notas se detectan del repositorio; nada se asume de un proyecto concreto.
- Antes de crear una versión nueva, se valida consistencia histórica para evitar arrastrar errores de formato.
- El nombre y las notas se derivan de cambios reales desde el último tag (CHANGELOG y commits), no se inventan.
- Toda la ejecución es no interactiva: sin editores, con `--notes-file`, y con verificaciones explícitas.

Pasos:
0) Acción: validar argumento recibido por la invocación `/release vX.Y.Z`.
   Validación: debe cumplir `^v[0-9]+\.[0-9]+\.[0-9]+$`.
   Resultado: variable `TARGET_VERSION` válida (ej. `v0.5.0`).

1) Acción: cargar reglas y detectar contexto.
   Referencias: `~/rules/rulesets/RELEASING.md`, `~/rules/rulesets/COMMITTING.md`, `~/rules/cot/changelog.md` (paso de idioma) y `AGENTS.md` del repositorio objetivo.
   Detección:
   - Plataforma: `git remote get-url origin`; si contiene `github.com` → `PLATFORM=github` (CLI `gh`); si es GitLab → `PLATFORM=gitlab` (CLI `glab`). Confirmar autenticación con `gh auth status` o `glab auth status`.
   - Proyecto: derivarlo siempre de la URL de `origin` (`git@github.com:dueño/repo.git` o `https://github.com/dueño/repo` → `PROJECT=dueño/repo`; en GitLab, la ruta codificada `grupo%2Fproyecto`). No usar `gh repo view` para esto: en un fork, `gh` resuelve el repositorio por defecto al de origen (upstream) y la release terminaría en el repositorio de otra persona.
   - Flujo de ramas: `git show-ref --verify -q refs/heads/dev || git ls-remote --exit-code --heads origin dev` → `HAS_DEV=true|false`. `SOURCE_BRANCH=dev` si existe; si no, `SOURCE_BRANCH=main`.
   - Idioma de las notas: igual que `/changelogger` (idioma del CHANGELOG si tiene entradas; si no, idioma principal del README y la documentación; si hay varios sin uno principal, inglés internacional UK; sin documentación, español mexicano).
   Resultado: `PLATFORM`, `PROJECT`, `HAS_DEV`, `SOURCE_BRANCH`, `NOTES_LANG`.

2) Acción: validar estado del repositorio.
   Verificaciones:
   - árbol de trabajo limpio (`git status --short` vacío);
   - rama actual `SOURCE_BRANCH`;
   - `git fetch origin --tags` y rama sincronizada: `git rev-list --left-right --count "origin/${SOURCE_BRANCH}...${SOURCE_BRANCH}"` devuelve `0	0`.
   Resultado: contexto listo o lista de problemas a resolver antes de seguir.

3) Acción: validar baseline histórico.
   Verificaciones genéricas:
   - todos los tags que empiezan con `v` cumplen `vX.Y.Z` (`git tag --list 'v*'`);
   - no hay tags de versión sin prefijo (`git tag --list '[0-9]*'` vacío) ni duplicados `X.Y.Z`/`vX.Y.Z`;
   - cada release existente apunta a un tag `vX.Y.Z` (`gh release list --repo "${PROJECT}"` o `glab release list`).
   Baseline específico: si el `AGENTS.md` del repositorio declara tags y nombres de release esperados (por ejemplo, el de `zabbix-k1` en `RELEASING.md`), validarlos también.
   Resultado: consistencia confirmada o lista de discrepancias a corregir antes de continuar.

4) Acción: validar que la versión objetivo no exista ya.
   Comandos guía:
   - `git rev-parse -q --verify "refs/tags/${TARGET_VERSION}"`
   - `git ls-remote --tags origin "${TARGET_VERSION}" "${TARGET_VERSION}^{}"`
   - GitHub: `gh release view "${TARGET_VERSION}" --repo "${PROJECT}"` debe fallar; GitLab: `glab api "projects/${PROJECT}/releases/${TARGET_VERSION}"` debe devolver 404.
   Resultado: confirmación de que no hay colisión de tag/release para `TARGET_VERSION`.

5) Acción: identificar el tag previo y el rango de cambios.
   Comandos guía:
   - `PREV_TAG=$(git --no-pager tag --list 'v*' --sort=version:refname | tail -n 1)`
   - si `PREV_TAG` está vacío: `RANGE="${SOURCE_BRANCH}"` (desde el primer commit); si no, `RANGE="${PREV_TAG}..${SOURCE_BRANCH}"`.
   - `git --no-pager log --pretty=format:'%h %s' "${RANGE}"`
   - en un fork (remoto `upstream`), comprobar si `PREV_TAG` pertenece al repositorio de origen (`git ls-remote --tags upstream "${PREV_TAG}"`); en ese caso es la primera release propia del fork y conviene decirlo en la introducción.
   - entradas de `CHANGELOG.md` posteriores a la fecha del tag previo (`git log -1 --format=%cs "${PREV_TAG}"`).
   Resultado: insumo concreto para versión, descriptor y bullets.

6) Acción: validar que la versión elegida corresponde a los cambios.
   Regla SemVer:
   - algún `BREAKING` (en commits o CHANGELOG) → MAJOR; mientras la versión sea `0.x`, basta MINOR;
   - algún `feat` → al menos MINOR;
   - solo `fix`/`perf`/`docs`/`chore`/`test` → PATCH.
   Si `TARGET_VERSION` sube menos de lo que indican los cambios (o mucho más sin motivo), advertir y pedir confirmación antes de continuar.
   Resultado: versión confirmada.

7) Acción: derivar descriptor corto y nombre final de release.
   Heurística obligatoria:
   - Priorizar `feat` sobre `fix/perf/docs/chore` para el descriptor.
   - Si hay múltiples temas, usar el impacto dominante para quien usa el proyecto.
   - Descriptor breve y específico, en `NOTES_LANG`.
   Formato final: `RELEASE_NAME="${TARGET_VERSION} — ${DESCRIPTOR}"`.
   Resultado: nombre de release consistente con historial.

8) Acción: generar notas de release no interactivas en archivo temporal.
   Ruta sugerida: `/tmp/release-notes-${TARGET_VERSION}.md`.
   Fuente: entradas del CHANGELOG del rango (conservando créditos a PR, autores y forks), complementadas con los commits del rango; cada bullet debe ser rastreable.
   Estructura mínima obligatoria, en `NOTES_LANG`:
   - párrafo introductorio corto;
   - `## Funcionalidades incluidas` (español) o `## What's included` (inglés) con bullets de cambios relevantes y verificables;
   - si hay cambios incompatibles: `## Cambios incompatibles` o `## Breaking changes`, con qué hacer al actualizar;
   - opcional: liga al CHANGELOG completo.
   Resultado: archivo de notas listo para `--notes-file`.

9) Acción: publicar rama y tag.
   Secuencia con `HAS_DEV=true`:
   - `git checkout main`
   - `git merge --ff-only dev`
   - `git push origin main`
   Secuencia común:
   - `git tag -a "${TARGET_VERSION}" -m "release: ${TARGET_VERSION}"`
   - `git push origin "${TARGET_VERSION}"`
   Resultado: `main` publicado y tag anotado visible en remoto.

10) Acción: crear o actualizar la release sin modo interactivo.
    GitHub (siempre con `--repo "${PROJECT}"`, nunca con el repositorio por defecto de `gh`):
    - si no existe: `gh release create "${TARGET_VERSION}" --repo "${PROJECT}" --verify-tag --title "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
    - si existe: `gh release edit "${TARGET_VERSION}" --repo "${PROJECT}" --title "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
    GitLab:
    - si no existe: `glab release create "${TARGET_VERSION}" --name "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
    - si existe: `glab release update "${TARGET_VERSION}" --name "${RELEASE_NAME}" --notes-file "/tmp/release-notes-${TARGET_VERSION}.md"`
    Resultado: release asociada al tag con nombre y notas correctos.

11) Acción: verificar publicación final.
    Validaciones obligatorias:
    - `git ls-remote --tags origin "${TARGET_VERSION}" "${TARGET_VERSION}^{}"` devuelve sólo el tag esperado;
    - GitHub: `gh release view "${TARGET_VERSION}" --repo "${PROJECT}" --json tagName,name,body`; GitLab: `glab api "projects/${PROJECT}/releases/${TARGET_VERSION}"`;
    - nombre y notas cumplen la convención y el idioma;
    - en un fork, confirmar que el repositorio de origen no recibió nada (`gh release list --repo <upstream>` sin la versión nueva).
    Resultado: publicación validada.

12) Acción: volver a la rama de desarrollo.
    Comando: `git checkout dev` si `HAS_DEV=true`; si no, permanecer en `main`.
    Resultado: flujo cerrado y repo listo para continuar trabajo.

Conclusión:

- Una release se considera correcta sólo si pasa validación histórica, evita colisiones de versión, usa una versión acorde a los cambios, deriva descriptor y notas desde cambios reales en el idioma del repositorio y cumple el flujo no interactivo completo.
- Si hay inconsistencias de formato previas, primero se corrigen y luego se publica la nueva versión.
- Referencias: `~/rules/rulesets/RELEASING.md`, `~/rules/rulesets/COMMITTING.md`, `~/rules/cot/changelog.md`, `AGENTS.md` del repo objetivo.
