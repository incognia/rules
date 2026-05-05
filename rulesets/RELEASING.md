# Reglas de tageo y releases

## 1. Objetivo

Definir una política única, reproducible y no interactiva para publicar versiones con tags semánticos y releases consistentes.

## 2. Convención de tags

- Formato obligatorio: `vMAJOR.MINOR.PATCH` (ejemplo: `v0.5.0`).
- Usar SemVer estrictamente.
- No mezclar formatos para una misma versión (`v0.5.0` y `0.5.0` al mismo tiempo está prohibido).
- El tag de release siempre debe apuntar al commit publicado en `main`.
- El tag debe ser anotado (`git tag -a`), no ligero.

## 3. Convención de release

- Tag de release: `vX.Y.Z`.
- Nombre recomendado: `vX.Y.Z — Descriptor corto`.
- Idioma de release: español mexicano.
- Notas mínimas obligatorias:
  - párrafo introductorio breve;
  - sección `## Funcionalidades incluidas`;
  - lista de bullets con cambios principales.

## 4. Flujo obligatorio de publicación

1. Confirmar que `dev` está lista para promoción.
2. Promover `dev` a `main` con fast-forward (`--ff-only`).
3. Crear tag anotado en `main`.
4. Publicar `main` y tag al remoto.
5. Crear o actualizar release asociada al mismo tag.
6. Volver a `dev`.

## 5. Derivación automática de nombre y cambios

Para una invocación como `/release v0.5.0`, el nombre y las notas se generan desde evidencia real:

1. Detectar `PREV_TAG` más reciente.
2. Obtener cambios de `${PREV_TAG}..dev` (commits y archivos).
3. Inferir descriptor:
   - si predominan `feat`, descriptor orientado a funcionalidad;
   - si predominan `fix/perf`, descriptor orientado a estabilidad/robustez;
   - si son cambios de soporte, descriptor orientado a mantenimiento.
4. Construir nombre final `vX.Y.Z — Descriptor`.
5. Generar notas en archivo temporal y publicar con `--notes-file`.

## 6. Reglas operativas críticas

- No usar editores interactivos para publicación/corrección de release.
- Todo el flujo debe ser no interactivo (incluyendo notas de release).
- Antes de publicar una versión nueva, validar que no exista tag/release con esa versión.
- Si hay inconsistencia de formato en tags/releases previas, corregir primero.
- Si se publicó un tag incorrecto sin prefijo `v`, crear la versión correcta y eliminar duplicados incorrectos.

## 7. Baseline validado para `zabbix-k1`

Tags esperados:

- `v0.1.0`
- `v0.2.0`
- `v0.3.0`
- `v0.4.0`

Releases esperadas:

- `v0.1.0 — MVP`
- `v0.2.0 — NOC 16:9`
- `v0.3.0 — NOC operativo y gobernanza`
- `v0.4.0 — Collector-first robusto`

Si este baseline no coincide, detener publicación y corregir el historial antes de continuar.

## 8. Verificación obligatoria post-publicación

Después de publicar, validar siempre:

- que sólo exista el tag correcto en remoto para la versión;
- que exista la release asociada al mismo tag;
- que nombre y notas respeten la convención.

Comandos de referencia:

- `git ls-remote --tags origin vX.Y.Z vX.Y.Z^{}`
- `glab release list`
- `glab api projects/operaciones-ti%2Fzabbix-k1/releases/vX.Y.Z`

---

Estas reglas complementan `COMMITTING.md` y se enfocan exclusivamente en publicación de versiones y releases.
