---
name: release
description: "Publica una release semántica no interactiva con validación histórica de tags/releases y notas generadas desde cambios reales. Invocación esperada: /release vX.Y.Z."
---

# Publicación de release

## Cuando usar

Cuando se va a publicar una nueva versión del repositorio, por ejemplo: `/release v0.5.0`.

## Parámetro obligatorio

- Versión objetivo con formato estricto `vX.Y.Z` (SemVer con prefijo `v`).

## Instrucciones

1. **Leer CoT completo**: cargar `~/rules/cot/release.md` de la línea 1 al final.
2. **Validar argumento**: confirmar que el parámetro cumple `^v[0-9]+\\.[0-9]+\\.[0-9]+$`.
3. **Validar baseline histórico**: revisar tags y releases previas para detectar inconsistencias antes de publicar.
4. **Derivar nombre y notas**:
   - Inferir descriptor corto desde el tema dominante de commits/changelog desde el último tag.
   - Construir nombre final: `vX.Y.Z — Descriptor`.
   - Construir notas en español con introducción + `## Funcionalidades incluidas` + bullets relevantes.
5. **Publicar en flujo oficial**:
   - promover `dev` a `main` con fast-forward;
   - crear tag anotado en `main`;
   - publicar tag y crear/actualizar release con `--notes-file`.
6. **Verificar publicación**: confirmar tag remoto único, release existente y convención de nombre/notas.
7. **Cerrar flujo**: regresar a `dev` para continuar desarrollo.

## Reglas críticas

- Prohibido publicar con formato de tag sin prefijo `v`.
- No usar editores interactivos para release/tags; usar comandos no interactivos y archivo de notas.
- Si existe inconsistencia (tag/release duplicada o mal formateada), corregir primero y luego publicar.
- El contenido de release debe quedar en español mexicano.

## Referencias

- CoT detallado: `~/rules/cot/release.md`
- Reglas canónicas: `~/rules/rulesets/RELEASING.md`
- Flujo de commit/changelog: `~/rules/rulesets/COMMITTING.md`
