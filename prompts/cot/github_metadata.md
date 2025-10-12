---
domain: workflow
task: configurar metadatos de repositorio GitHub (descripción, topics, configuraciones) sin editores
dificultad: baja
longitud_objetivo: corta
validacion: metadatos actualizados correctamente via API, sin interacción con editores
version: "1.0"
last_updated: 2025-10-12
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- **CRÍTICO**: evitar cualquier comando que abra editores interactivos (gh repo edit con ciertos flags, comandos sin especificar completamente).
- Usar API REST de GitHub directamente con curl para operaciones complejas.
- Comandos gh simples solo para operaciones que garantizan no ser interactivas.
- Configurar descripción, topics, homepage, license, y otras propiedades del repositorio.
- Validar cambios sin abrir navegadores o editores.

Pasos:
1) Acción: verificar que gh esté instalado y autenticado correctamente.
   Resultado: 
   - `gh --version` para confirmar instalación
   - `gh auth status` para verificar autenticación
   - `gh auth token` debe devolver token válido (sin mostrarlo en pantalla)
   Si no está autenticado: `gh auth login` siguiendo el flujo no interactivo.

2) Acción: obtener información actual del repositorio.
   Resultado: `curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/OWNER/REPO | jq '{name: .name, description: .description, topics: .topics, homepage: .homepage, license: .license.spdx_id}'`
   Nota: reemplazar OWNER/REPO con valores reales del repositorio.

3) Acción: configurar descripción del repositorio (método seguro).
   Opciones:
   - **Método 1 (gh, verificado no interactivo)**: `gh repo edit --description "descripción del proyecto"`
   - **Método 2 (curl, más seguro)**: `curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"description":"descripción del proyecto"}' https://api.github.com/repos/OWNER/REPO`

4) Acción: configurar topics del repositorio (solo curl para evitar editores).
   **CRÍTICO**: NO usar `gh repo edit --add-topic` ya que puede abrir editor.
   Resultado: `curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PUT -d '{"names":["topic1","topic2","topic3","topic4"]}' https://api.github.com/repos/OWNER/REPO/topics`
   Ejemplo de topics comunes:
   - Documentación: "documentation", "readme", "markdown"
   - Análisis técnico: "technical-analysis", "regression-analysis", "debugging"
   - Proyectos específicos: "warp-terminal", "github-issues", "open-source"
   - Lenguajes/tecnologías: "bash", "shell", "macos", "linux"

5) Acción: configurar homepage del repositorio (opcional).
   Resultado: `curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"homepage":"https://example.com"}' https://api.github.com/repos/OWNER/REPO`

6) Acción: configurar configuraciones adicionales del repositorio.
   Opciones disponibles via API:
   ```bash
   # Habilitar issues
   curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"has_issues":true}' https://api.github.com/repos/OWNER/REPO
   
   # Habilitar wiki
   curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"has_wiki":true}' https://api.github.com/repos/OWNER/REPO
   
   # Habilitar pages
   curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"has_pages":false}' https://api.github.com/repos/OWNER/REPO
   
   # Configurar branch por defecto
   curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"default_branch":"main"}' https://api.github.com/repos/OWNER/REPO
   ```

7) Acción: validar cambios aplicados.
   Resultado: `curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/OWNER/REPO | jq '{description: .description, topics: .topics, homepage: .homepage, has_issues: .has_issues, has_wiki: .has_wiki, default_branch: .default_branch}'`

8) (Opcional) Acción: configurar protección de branch main.
   Resultado:
   ```bash
   curl -s -H "Authorization: token $(gh auth token)" \
        -H "Accept: application/vnd.github.v3+json" \
        -X PUT \
        -d '{"required_status_checks":null,"enforce_admins":false,"required_pull_request_reviews":null,"restrictions":null}' \
        https://api.github.com/repos/OWNER/REPO/branches/main/protection
   ```

Comandos a EVITAR (pueden abrir editores):
- `gh repo edit` sin flags específicos
- `gh repo edit --add-topic` (conocido por abrir editor)
- `gh issue create` sin `-t` y `-b`
- `gh pr create` sin flags completos
- Cualquier comando gh que no especifique completamente todos los parámetros

Comandos SEGUROS (garantizados no interactivos):
- `gh repo edit --description "texto"`
- `gh repo view --json campo`
- `curl` con API REST de GitHub
- `gh auth token` (para usar en curl)

Plantillas de topics comunes:
```bash
# Proyecto de documentación
["documentation","markdown","readme","technical-writing"]

# Análisis de issues/bugs
["technical-analysis","debugging","regression-analysis","github-issues"]

# Proyecto open source
["open-source","community","foss","libre-software"]

# Herramientas específicas
["warp-terminal","terminal","shell","command-line"]

# Tecnologías
["bash","shell-scripting","macos","linux","cross-platform"]
```

Ejemplos de uso completo:
```bash
# Configurar repo de documentación técnica
OWNER="incognia"
REPO="OSS"

# Descripción
curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PATCH -d '{"description":"Technical documentation of issues in open source projects"}' https://api.github.com/repos/$OWNER/$REPO

# Topics
curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" -X PUT -d '{"names":["documentation","open-source","technical-analysis","github-issues","regression-analysis"]}' https://api.github.com/repos/$OWNER/$REPO/topics

# Validar
curl -s -H "Authorization: token $(gh auth token)" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$OWNER/$REPO | jq '{description: .description, topics: .topics}'
```

Conclusión:
- Usar curl + API REST para máximo control y evitar editores.
- Solo usar gh para comandos simples y completamente especificados.
- Siempre validar cambios con consultas GET a la API.
- Mantener tokens seguros usando $(gh auth token) en lugar de variables expuestas.
- Para repos con configuración compleja, usar scripts que combinen múltiples llamadas API.
- Referencias: [GitHub REST API](https://docs.github.com/en/rest), [GitHub CLI Manual](https://cli.github.com/manual/), «~/rules/docs/GIT.md» ([../../docs/GIT.md](../../docs/GIT.md)).