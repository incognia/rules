# Reglas de verificación de *pull requests*

## 1. Propósito

Un *pull request* que no cumple las reglas de `/commit` y de `/changelogger` se rechaza sin revisar el código. Este *ruleset* define las puertas, qué parte verifica `scripts/check-pr.sh` y qué parte exige criterio humano. Las reglas se aplican con el entorno y la identidad de quien contribuye: se revisa el resultado, no la herramienta con que se produjo.

## 2. Puertas

| # | Puerta | Origen | Verificación |
|---|---|---|---|
| G1 | *Commits* atómicos: uno por cambio lógico, sin mezclar tipos | `/commit` | Manual (`git log --stat`) |
| G2 | Asunto con Conventional Commits: `tipo(ámbito): resumen` | `/commit` | `check-pr.sh` |
| G3 | Asunto en inglés internacional (UK) | `/commit` | `check-pr.sh` (heurística de acentos y «ñ») |
| G4 | Línea en blanco tras el asunto y viñetas del cuerpo desde la columna 1 | `/commit` | `check-pr.sh` |
| G5 | El mensaje no reporta el mantenimiento del CHANGELOG («update the CHANGELOG», «CHANGELOG entry», «add … to the changelog»); nombrar el CHANGELOG o `/changelogger`, o hablar de su mantenimiento como tema («changelog upkeep»), sí se permite | `/commit` | `check-pr.sh` (frases de mantenimiento) |
| G6 | `Co-Authored-By` de la herramienta y el modelo usados | `/commit` | Presencia: `check-pr.sh`; autenticidad: manual |
| G7 | Sin *commits* `fixup!`, `squash!` ni `amend!` | `/commit` | `check-pr.sh` |
| G8 | `CHANGELOG.md` cambia solo en el último *commit* de la serie | `/commit` | `check-pr.sh` |
| G9 | El diff de `CHANGELOG.md` solo añade líneas | `/changelogger` | `check-pr.sh` |
| G10 | Formato del CHANGELOG: viñetas `tipo:`, encabezado `## [AAAA-MM-DD] - Título`, fecha en hora de Ciudad de México, un bloque por fecha, orden inverso y sin líneas en blanco entre viñetas. Los defectos que el archivo ya tenía en la rama base solo advierten; fallan los que introduce el PR | `/changelogger` | `check-pr.sh`; texto en español de México y sin emojis: manual |
| G11 | El orden de las viñetas nuevas coincide con el de los *commits* (el último arriba) | `/changelogger` y `/commit` | Manual |
| G12 | Sin archivos ajenos: binarios, registros, archivos del sistema ni reformateos | Criterio del proyecto | `check-pr.sh` con los patrones del proyecto |
| G13 | Título del PR con Conventional Commits en inglés | `/commit` | `check-pr.sh --title` |
| G14 | La descripción conserva todas las secciones de la plantilla | Plantilla del proyecto | `check-pr.sh --body-file` |
| G15 | `openspec validate --all --strict` si el proyecto tiene `openspec/` | OpenSpec | `check-pr.sh` |
| G16 | Identidad de Git propia de quien contribuye | `/commit` | Manual (`git log --format='%an <%ae>'`) |

Todo fallo de una puerta automática rechaza el PR. Las advertencias (`WARN`) no lo rechazan, pero exigen revisión humana.

## 3. Uso

Desde el repositorio que contiene el PR, con `bash`:

```bash
~/rules/scripts/check-pr.sh --base origin/main
```

Opciones: `--head` (por omisión, `HEAD`), `--title`, `--body-file` (el cuerpo del PR en un archivo), `--config` y `--skip-openspec`. En Windows se ejecuta desde WSL o Git Bash; la carpeta `rules` está en `%USERPROFILE%\rules` o en `C:\rules`.

Salida: `0` si nada falló, `1` si alguna puerta falló y `2` por un uso incorrecto.

## 4. Configuración por proyecto

Un proyecto personaliza la verificación con `.github/pr-check.conf`, relativo a la raíz del repositorio, con una línea `clave = valor` por ajuste (`#` inicia un comentario):

```text
# Salida de compilación del paquete de macOS
stray = *.app/Contents/MacOS/*

# Plantilla de PR distinta de .github/PULL_REQUEST_TEMPLATE.md
template = docs/PULL_REQUEST_TEMPLATE.md

# Desactivar la validación de OpenSpec
openspec = off
```

- `stray`: patrón de ruta que no debe aparecer en un PR; se suma a los patrones generales y se puede repetir.
- `template`: plantilla de PR con la que se compara la descripción.
- `openspec`: `auto` (valor predeterminado) valida `openspec/` si existe; `off` lo omite.

Una clave desconocida es un error de uso, para que un error de dedo no desactive una puerta sin avisar.

## 5. Integración en CI

El *script* vive en `rules`, así que el flujo del proyecto lo descarga con una segunda copia del repositorio. Fija `ref` a una etiqueta o a un *commit* para que un cambio en `rules` no rompa ni debilite los PR de un proyecto sin avisar. Los archivos de flujo usan la extensión `.yaml`.

```yaml
name: PR checks

on:
  pull_request:
    types: [opened, synchronize, reopened, edited]

permissions:
  contents: read

jobs:
  conventions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/checkout@v4
        with:
          repository: incognia/rules
          ref: main            # fija una etiqueta o un SHA
          path: .rules
      - uses: actions/setup-node@v4
        with:
          node-version: '22'   # OpenSpec requiere Node.js 20.19 o superior
      - name: Check the pull request
        env:
          PR_TITLE: ${{ github.event.pull_request.title }}
          PR_BODY: ${{ github.event.pull_request.body }}
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}
        run: |
          printf '%s' "$PR_BODY" > "$RUNNER_TEMP/pr-body.md"
          bash .rules/scripts/check-pr.sh --base "$BASE_SHA" --head "$HEAD_SHA" \
            --title "$PR_TITLE" --body-file "$RUNNER_TEMP/pr-body.md"
```

El título y el cuerpo son texto no confiable: se pasan por el entorno y nunca se interpolan en el *script* del paso.

## 6. Límites

- Las puertas automáticas detectan la forma, no el fondo: no saben si los *commits* son atómicos de verdad, si el texto del CHANGELOG está bien redactado ni si el `Co-Authored-By` es el de la herramienta realmente usada.
- La detección del inglés es una heurística de caracteres (acentos, «ñ», signos de apertura): un asunto en español sin acentos no se detecta.
- G5 reconoce frases de mantenimiento en inglés (un verbo como `update`, `edit` o `add` junto a «changelog»): una paráfrasis poco común puede escaparse, y una frase legítima muy parecida a una de ellas puede marcarse. Para hablar de esas frases sin activar la puerta, cítalas entre comillas dobles, comillas invertidas o comillas angulares: el texto citado se ignora (las comillas simples no, porque también son apóstrofos).
- Un PR puede modificar el *script* de su propio proyecto, su configuración o su flujo. El *script* avisa (`WARN`) cuando un PR toca `.github/` o las comprobaciones. Un PR que pasa de verdad es el que corre con el *script* de `rules` fijado a una versión y con la regla de protección de la rama principal activa en GitHub.
- Los patrones de archivos ajenos son generales (`bin/`, `obj/`, `*.log`, `*.exe`…); un directorio legítimo con ese nombre exige quitar o ajustar el patrón.

## 7. Relación con los *hooks*

`.githooks/commit-msg` y `.githooks/pre-commit` aplican en local una parte de estas reglas durante cada *commit*, y el primero solo advierte si falta el `Co-Authored-By`. La verificación del PR es más estricta porque juzga la serie completa y es la que decide si se acepta.

## 8. Referencias

- Procedimiento: «~/rules/cot/pr_check.md» ([../cot/pr_check.md](../cot/pr_check.md))
- *Skill*: `/pr-check` en `.agents/skills/pr-check/`
- *Script*: «~/rules/scripts/check-pr.sh» ([../scripts/check-pr.sh](../scripts/check-pr.sh)) y sus pruebas en `scripts/tests/check-pr.test.sh`
- Reglas de las que depende: «~/rules/rulesets/COMMITTING.md» ([COMMITTING.md](./COMMITTING.md)) y «~/rules/cot/changelog.md» ([../cot/changelog.md](../cot/changelog.md))
