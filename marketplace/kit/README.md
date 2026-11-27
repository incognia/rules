# Kit de arranque del *marketplace*

*Última modificación: 27 de noviembre de 2026, 15:32 (CST)*

Esqueleto copiable para levantar un *marketplace* de *plugins* de Claude Code desde cero. Las *specs* de [../openspec/](../openspec/) dicen **qué** debe cumplir el *marketplace*; este kit trae **con qué empezar**: un repositorio mínimo que ya pasa `claude plugin validate`, con un *plugin* de ejemplo, las plantillas y el CI.

Todo `marketplace/` se distribuye bajo la licencia MIT ([../LICENSE](../LICENSE)), aunque el resto del repositorio es GPLv3, para que también sirva de base a una instancia laboral.

## Qué contiene

```text
kit/
├── skeleton/                          # se copia tal cual a la raíz del repositorio nuevo
│   ├── .claude-plugin/marketplace.json    # catálogo con un plugin de ejemplo
│   ├── plugins/example/                   # plugin mínimo: una skill en línea y una en subagente
│   ├── scripts/python_check.py            # comprobación de Python con parches vigentes
│   ├── tests/                             # pruebas de la comprobación, las copias y el script de ejemplo
│   ├── AGENTS.md, CLAUDE.md               # instrucciones para agentes (CLAUDE.md solo importa AGENTS.md)
│   ├── CONTRIBUTING.md, RELEASING.md      # cómo publicar un plugin y la lista de cada release
│   ├── README.md                          # instalación, tabla de plugins y actualizaciones
│   └── .gitignore
├── templates/
│   ├── instance.corporate.json            # los dos gates para una instancia laboral
│   ├── instance.personal.json             # los dos gates para una instancia personal
│   ├── CHANGELOG.multinational.md         # encabezado canónico en UTC e inglés (UK)
│   └── CHANGELOG.regional.md              # encabezado canónico en hora local y español mexicano
└── ci/
    ├── github.yaml                        # CI de ejemplo para GitHub Actions
    └── gitlab-ci.yaml                     # CI de ejemplo para GitLab
```

## Cómo usarlo

1. Copia el esqueleto al repositorio nuevo y el *change* de OpenSpec, como indica [../README.md](../README.md):

   ```bash
   cp -R ~/rules/marketplace/kit/skeleton/. .
   ```

2. Decide los dos *gates* y copia la plantilla que corresponda como `plugins/git/scripts/instance.json` cuando construyas el *plugin* `git`:

   | *Gate* | Opciones | Plantilla de ejemplo |
   |--------|----------|----------------------|
   | Tipo de proyecto | `corporate` (una licencia fija, normalmente MIT) o `personal` (alterna entre las licencias permitidas, por ejemplo GPLv3 y MIT) | `instance.corporate.json`, `instance.personal.json` |
   | Formato | `multinational` (UTC, inglés UK) o `regional` (hora local como cadena POSIX, por ejemplo `CST6`, e idioma de la región) | `CHANGELOG.multinational.md`, `CHANGELOG.regional.md` |

3. Sustituye los valores de ejemplo: `example` y `Example Organisation` en los dos manifiestos, los `<marcadores>` de `AGENTS.md` y `README.md`, y `ENV_PREFIX` en **todas** las copias de `python_check.py`.
4. Copia el CI de tu forja (`ci/github.yaml` a `.github/workflows/ci.yaml`, o `ci/gitlab-ci.yaml` a `.gitlab-ci.yml`) y el encabezado de `CHANGELOG.md` de tu formato.
5. Valida y prueba:

   ```bash
   claude plugin validate .
   ```

   ```bash
   claude plugin validate ./plugins/example
   ```

   ```bash
   python3 -m unittest discover -s tests
   ```

6. Sigue `tasks.md` del *change*: el primer *plugin* real es `git`; cuando exista, borra `plugins/example/` y su entrada del catálogo.

## Convenciones que el esqueleto ya aplica

- **El modelo conversa y decide; los *scripts* actúan y validan.** Cada *script* imprime un solo objeto JSON por la salida estándar, los errores por la salida de error como `ERROR [campo] motivo`, y documenta sus códigos de salida en el encabezado.
- **`${CLAUDE_PLUGIN_ROOT}` se sustituye en `SKILL.md`, pero no existe como variable en Bash.** Cada comando lleva la ruta completa, y los archivos de `references/` se nombran por ruta completa: una liga relativa de Markdown no funciona desde una *skill*.
- **`context: fork` solo para *skills* que no necesitan la conversación** (como un CHANGELOG). Una *skill* de *commits* nunca corre en subagente, porque su *trailer* lee la sesión principal.
- **La versión vive solo en `plugin.json`** y cambia en cada *release*; la entrada del catálogo nunca lleva versión.
- **`python_check.py` es idéntico en todas sus copias**; las pruebas y el CI lo comparan. Sus mínimos son los vigentes a noviembre de 2026: revísalos al instanciar.

## Verificación en este repositorio

`scripts/check-marketplace.sh`, que también corre en el CI, valida las *specs*, su sincronía con el *change* y este kit (copias, JSON y pruebas):

```bash
~/rules/scripts/check-marketplace.sh
```

El CI de ejemplo no se ha ejecutado en un repositorio real: confirma en tu *runner* que `claude plugin validate` corre sin autenticación antes de depender de él.
