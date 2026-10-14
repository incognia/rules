# Reglas de etiquetado y *releases*

## 1. Objetivo

Definir una política única, reproducible y no interactiva para publicar versiones con *tags* semánticos y *releases* consistentes, en GitHub o GitLab.

## 2. Convención de *tags*

- Formato obligatorio: `vMAJOR.MINOR.PATCH` (ejemplo: `v0.5.0`).
- Usar SemVer estrictamente:
  - cambio incompatible (`BREAKING`) → MAJOR; mientras la versión sea `0.x`, basta MINOR;
  - funcionalidad nueva (`feat`) → MINOR;
  - solo correcciones o mantenimiento (`fix`, `perf`, `docs`, `chore`, `test`) → PATCH.
- No mezclar formatos para una misma versión (`v0.5.0` y `0.5.0` al mismo tiempo está prohibido).
- El *tag* de *release* siempre debe apuntar al *commit* publicado en `main`.
- El *tag* debe ser anotado (`git tag -a`), no ligero.

## 3. Convención de *release*

- *Tag* de *release*: `vX.Y.Z`.
- Nombre recomendado: `vX.Y.Z — Descriptor corto`.
- Idioma de la *release*: el idioma principal del repositorio, con la misma detección que el CHANGELOG (`~/rules/cot/changelog.md`): español mexicano o inglés internacional (UK). La *release* nunca mezcla idiomas con el CHANGELOG.
- Notas mínimas obligatorias:
  - párrafo introductorio breve;
  - sección `## Funcionalidades incluidas` (español) o `## What's included` (inglés);
  - lista de viñetas con los cambios principales, rastreables al CHANGELOG o a *commits*;
  - sección `## Cambios incompatibles` o `## Breaking changes` cuando haya alguno.

## 4. Flujo obligatorio de publicación

Con rama `dev`:

1. Confirmar que `dev` está lista para promoción y sincronizada con `origin`.
2. Promover `dev` a `main` con *fast-forward* (`--ff-only`).
3. Crear *tag* anotado en `main`.
4. Publicar `main` y el *tag* en el remoto.
5. Crear o actualizar la *release* asociada al mismo *tag*.
6. Volver a `dev`.

Sin rama `dev` (solo `main`):

1. Confirmar que `main` está limpia y sincronizada con `origin`.
2. Crear *tag* anotado en `main` y publicarlo.
3. Crear o actualizar la *release* asociada al mismo *tag*.

## 5. Derivación automática de nombre y cambios

Para una invocación como `/release v0.5.0`, el nombre y las notas se generan desde evidencia real:

1. Detectar el `PREV_TAG` más reciente; si no existe, tomar desde el primer *commit*. En un *fork*, señalar si el *tag* previo pertenece al repositorio de origen.
2. Obtener cambios de `${PREV_TAG}..<rama de publicación>`: entradas del CHANGELOG (fuente principal, con sus créditos) y *commits* (complemento).
3. Validar que la versión pedida corresponde a los cambios (sección 2); si no, advertir y pedir confirmación.
4. Inferir el descriptor:
   - si predominan `feat`, descriptor orientado a funcionalidad;
   - si predominan `fix/perf`, descriptor orientado a estabilidad y robustez;
   - si son cambios de soporte, descriptor orientado a mantenimiento.
5. Construir el nombre final `vX.Y.Z — Descriptor`.
6. Generar las notas en un archivo temporal y publicar con `--notes-file`.

## 6. Reglas operativas críticas

- No usar editores interactivos para publicar o corregir una *release*.
- Todo el flujo debe ser no interactivo (incluidas las notas de *release*).
- Detectar la plataforma por la URL de `origin` y usar su CLI (`gh` para GitHub, `glab` para GitLab).
- Derivar el proyecto de la URL de `origin` y pasarlo siempre con `--repo` a `gh`: en un *fork*, el repositorio predeterminado de `gh` es el de origen, y una *release* sin `--repo` se publicaría ahí.
- Antes de publicar una versión nueva, validar que no exista un *tag* o una *release* con esa versión.
- Si hay inconsistencia de formato en *tags* o *releases* previas, corregir primero.
- Si se publicó un *tag* incorrecto sin prefijo `v`, crear la versión correcta y eliminar los duplicados incorrectos.

## 7. Líneas base por proyecto (*baselines*)

Un repositorio puede declarar en su `AGENTS.md` los *tags* y nombres de *release* esperados; si los declara, se validan antes de publicar y una discrepancia detiene la publicación. Ejemplo genérico para `<repositorio>`:

*Tags* esperados:

- `v0.1.0`
- `v0.2.0`
- `v0.3.0`

*Releases* esperadas:

- `v0.1.0 — MVP`
- `v0.2.0 — <descriptor>`
- `v0.3.0 — <descriptor>`

Sin línea base declarada, basta la validación genérica: todos los *tags* `v*` con formato `vX.Y.Z`, sin duplicados sin prefijo, y cada *release* asociada a un *tag* válido.

## 8. Verificación obligatoria posterior a la publicación

Después de publicar, validar siempre:

- que sólo exista el *tag* correcto en el remoto para la versión;
- que exista la *release* asociada al mismo *tag*;
- que el nombre y las notas respeten la convención y el idioma del repositorio.

Comandos de referencia:

- `git ls-remote --tags origin vX.Y.Z vX.Y.Z^{}`
- GitHub: `gh release view vX.Y.Z --repo dueño/repo --json tagName,name,body`
- GitLab: `glab release list` y `glab api projects/<grupo%2Fproyecto>/releases/vX.Y.Z`

---

Estas reglas complementan `COMMITTING.md` y se enfocan exclusivamente en la publicación de versiones y *releases*.
