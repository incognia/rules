---
domain: workflow
task: configurar metadatos de repositorio GitHub (descripción, topics, configuraciones) sin editores
dificultad: baja
longitud_objetivo: corta
validacion: metadatos actualizados correctamente vía API, sin interacción con editores
version: "2.0"
last_updated: 2026-11-27
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- **CRÍTICO**: evitar cualquier comando que abra editores o haga preguntas (`gh repo edit` sin *flags*, `gh pr create` o `gh issue create` sin título y cuerpo).
- Usar `gh api` para la API REST de GitHub: toma la credencial de `gh` sin exponerla en la línea de comandos ni en la lista de procesos, cosa que sí pasa con `curl -H "Authorization: token $(gh auth token)"`.
- El cuerpo JSON viaja por la entrada estándar (`--input -`), nunca como argumento con datos sensibles.
- Configurar descripción, *topics*, *homepage*, licencia y otras propiedades del repositorio.
- Validar cambios sin abrir navegadores o editores.

Pasos:

1) Acción: verificar que gh esté instalado y autenticado correctamente.
   Resultado:
   - `gh --version` para confirmar instalación
   - `gh auth status` para verificar autenticación
   Si no está autenticado, pedir al usuario que ejecute `gh auth login` por su cuenta: es un flujo interactivo y el *token* nunca se imprime ni se pega en la conversación.

2) Acción: obtener información actual del repositorio.
   Resultado: `gh api repos/OWNER/REPO --jq '{name: .name, description: .description, topics: .topics, homepage: .homepage, license: .license.spdx_id}'`
   Nota: reemplazar OWNER/REPO con valores reales del repositorio.

3) Acción: configurar descripción del repositorio (método seguro).
   Opciones:
   - **Método 1**: `gh repo edit OWNER/REPO --description "descripción del proyecto"`
   - **Método 2 (API)**: `gh api -X PATCH repos/OWNER/REPO --input - <<< '{"description":"descripción del proyecto"}'`

4) Acción: configurar los *topics* del repositorio.
   `gh repo edit OWNER/REPO --add-topic <topic>` agrega uno sin abrir editor; para reemplazar la lista completa de una vez, usar la API:
   Resultado: `gh api -X PUT repos/OWNER/REPO/topics --input - <<< '{"names":["topic1","topic2","topic3","topic4"]}'`
   Ejemplos de *topics* comunes:
   - Documentación: "documentation", "readme", "markdown"
   - Análisis técnico: "technical-analysis", "regression-analysis", "debugging"
   - Proyectos específicos: "warp-terminal", "github-issues", "open-source"
   - Lenguajes/tecnologías: "bash", "shell", "macos", "linux"

5) Acción: configurar la *homepage* del repositorio (opcional).
   Resultado: `gh api -X PATCH repos/OWNER/REPO --input - <<< '{"homepage":"https://example.com"}'`

6) Acción: configurar configuraciones adicionales del repositorio.
   Opciones disponibles vía API:

   ```bash
   # Enable issues
   gh api -X PATCH repos/OWNER/REPO --input - <<< '{"has_issues":true}'
   
   # Enable the wiki
   gh api -X PATCH repos/OWNER/REPO --input - <<< '{"has_wiki":true}'
   
   # Disable Pages
   gh api -X PATCH repos/OWNER/REPO --input - <<< '{"has_pages":false}'
   
   # Set the default branch
   gh api -X PATCH repos/OWNER/REPO --input - <<< '{"default_branch":"main"}'
   ```

7) Acción: validar cambios aplicados.
   Resultado: `gh api repos/OWNER/REPO --jq '{description: .description, topics: .topics, homepage: .homepage, has_issues: .has_issues, has_wiki: .has_wiki, default_branch: .default_branch}'`

8) (Opcional) Acción: configurar la protección de la rama `main`.
   Resultado:

   ```bash
   # Block force pushes and deletion of main; the four null or false fields are mandatory in this API
   gh api -X PUT repos/OWNER/REPO/branches/main/protection --input - <<< \
     '{"required_status_checks":null,"enforce_admins":false,"required_pull_request_reviews":null,"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}'
   ```

Comandos a EVITAR (pueden abrir editores):

- `gh repo edit` sin *flags*
- `gh issue create` sin `--title` y `--body` (o `--body-file`)
- `gh pr create` sin `--title` y `--body` (o `--body-file`)
- `curl` con el *token* en la línea de comandos

Comandos SEGUROS (garantizados no interactivos):

- `gh repo edit OWNER/REPO --description "texto"` y `--add-topic <topic>`
- `gh repo view OWNER/REPO --json campo`
- `gh api` con la API REST de GitHub

Plantillas de *topics* comunes:

```bash
# Documentation project
["documentation","markdown","readme","technical-writing"]

# Issue and bug analysis
["technical-analysis","debugging","regression-analysis","github-issues"]

# Open source project
["open-source","community","foss","libre-software"]

# Specific tools
["warp-terminal","terminal","shell","command-line"]

# Technologies
["bash","shell-scripting","macos","linux","cross-platform"]
```

Ejemplos de uso completo:

```bash
# Set up a technical documentation repository
OWNER="incognia"
REPO="OSS"

# Description
gh api -X PATCH repos/$OWNER/$REPO --input - <<< '{"description":"Technical documentation of issues in open source projects"}'

# Topics
gh api -X PUT repos/$OWNER/$REPO/topics --input - <<< '{"names":["documentation","open-source","technical-analysis","github-issues","regression-analysis"]}'

# Validate
gh api repos/$OWNER/$REPO --jq '{description: .description, topics: .topics}'
```

Conclusión:

- Usar `gh api` para la API REST: no abre editores y no expone el *token*.
- Pasar siempre `OWNER/REPO` explícito: en un *fork*, `gh` resuelve por omisión al repositorio de origen.
- Siempre validar cambios con consultas GET a la API.
- Para repositorios con configuración compleja, usar *scripts* que combinen varias llamadas a la API.
- Referencias: [GitHub REST API](https://docs.github.com/en/rest), [GitHub CLI Manual](https://cli.github.com/manual/), «~/rules/rulesets/GIT.md» ([../rulesets/GIT.md](../rulesets/GIT.md)).
