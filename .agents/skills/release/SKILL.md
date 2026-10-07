---
name: release
description: "Publica una release semántica no interactiva en GitHub o GitLab, con validación de tags/releases previas y notas generadas desde el CHANGELOG y los commits reales. Invocación esperada: /release vX.Y.Z."
---

# Publicación de release

## Cuándo usar

Cuando se va a publicar una nueva versión del repositorio, por ejemplo: `/release v0.5.0`.

## Parámetro obligatorio

- Versión objetivo con formato estricto `vX.Y.Z` (SemVer con prefijo `v`).

## Instrucciones

1. **Leer CoT completo**: cargar `~/rules/cot/release.md` de la línea 1 al final.
2. **Validar argumento**: confirmar que el parámetro cumple `^v[0-9]+\.[0-9]+\.[0-9]+$`.
3. **Detectar contexto del repositorio**:
   - plataforma por la URL de `origin`: `github.com` → `gh`; GitLab (`gitlab.com` o instancia propia) → `glab`;
   - flujo de ramas: si existe `dev` (local o en `origin`), flujo `dev → main`; si no, se publica directo desde `main`;
   - idioma de las notas: el idioma principal del repositorio, con la misma detección que `/changelogger` (español mexicano o inglés internacional UK).
4. **Validar estado y baseline**:
   - árbol de trabajo limpio y rama de publicación sincronizada con `origin` (sin commits pendientes de subir ni de bajar);
   - todos los tags `v*` existentes con formato `vX.Y.Z`, sin duplicados sin prefijo;
   - la versión objetivo no existe como tag (local o remoto) ni como release;
   - si el repositorio declara un baseline propio de tags/releases en su `AGENTS.md`, validarlo también.
5. **Validar la versión elegida**: comparar con los cambios desde el tag previo (`BREAKING` → MAJOR, o MINOR mientras sea `0.x`; `feat` → MINOR; solo `fix`/`docs`/`chore` → PATCH). Si no cuadra, advertir y pedir confirmación antes de seguir.
6. **Derivar nombre y notas**:
   - rango desde el tag previo (o desde el primer commit si no hay ninguno); en un fork, indicar si el tag previo viene del repositorio de origen;
   - fuente principal: las entradas de `CHANGELOG.md` posteriores al tag previo, conservando créditos (PR, autores, forks); complemento: los commits del rango;
   - nombre final: `vX.Y.Z — Descriptor`, con descriptor breve en el idioma de las notas;
   - notas: introducción breve + sección de funcionalidades (`## Funcionalidades incluidas` o `## What's included`) + bullets; añadir `## Cambios incompatibles` / `## Breaking changes` si hay alguno.
7. **Publicar**:
   - con `dev`: promover `dev` a `main` con fast-forward y publicar `main`;
   - crear tag anotado en `main` y publicarlo;
   - crear o actualizar la release con `--notes-file` (`gh release create … --verify-tag` o `glab release create …`).
8. **Verificar publicación**: tag remoto único, release existente, nombre y notas con la convención.
9. **Cerrar flujo**: regresar a `dev` si existe; si no, quedarse en `main`.

## Reglas críticas

- Prohibido publicar con formato de tag sin prefijo `v`.
- No usar editores interactivos para release/tags; usar comandos no interactivos y archivo de notas.
- Si existe inconsistencia (tag/release duplicada o mal formateada), corregir primero y luego publicar.
- Las notas van en el idioma principal del repositorio; nunca mezclar idiomas con el CHANGELOG.
- No inventar cambios: cada bullet debe poder rastrearse a una entrada del CHANGELOG o a un commit del rango.
- Publicar tags y releases es una acción pública: la invocación `/release vX.Y.Z` es la autorización; ante cualquier advertencia (versión dudosa, baseline inconsistente, rama desincronizada), detenerse y preguntar.

## Referencias

- CoT detallado: `~/rules/cot/release.md`
- Reglas canónicas: `~/rules/rulesets/RELEASING.md`
- Flujo de commit/changelog: `~/rules/rulesets/COMMITTING.md`, `~/rules/cot/changelog.md` (detección de idioma)
