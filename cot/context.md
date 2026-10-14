---
domain: proyecto
task: obtener rápidamente el contexto del proyecto en la carpeta actual (ubicación, documentación, tecnologías, infraestructura y herramientas)
dificultad: baja
longitud_objetivo: media
validacion: resumen estructurado con propósito, tecnologías, estructura, estado y herramientas, con rutas de archivos citadas
version: "3.0"
last_updated: 2026-10-14
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Usos: nueva sesión de trabajo, exploración de repositorios desconocidos, revisión de progreso, colaboración y diagnóstico.
- Orden: ubicación → documentación de entrada → tecnologías e infraestructura (incluidos Kubernetes y Talos) → configuración y *scripts* → síntesis.
- Solo lectura: no ejecutar acciones destructivas ni imprimir secretos (por ejemplo, el contenido de un `.env`, un *kubeconfig* o un *talosconfig*; basta con reportar que existen).
- Para un inventario más profundo de un repositorio de GitHub o GitLab (licencias, CI/CD, despliegue, pruebas, contribución), usar «~/rules/cot/repo_context.md» ([./repo_context.md](./repo_context.md)).

Pasos:

1) Acción: identificar la ubicación y la estructura.
   Resultado:

   ```bash
   pwd
   tree -L 3 -a -I 'node_modules|.git' 2>/dev/null || find . -maxdepth 3 -not -path './.git*' -not -path './node_modules*' | head -100
   ```

   Si `tree` no está instalado, usar el respaldo con `find` o instalarlo (`brew install tree`, `sudo apt install tree`, `sudo dnf install tree`, `sudo apk add tree` o `sudo pacman -S tree`).

2) Acción: identificar los archivos de documentación.
   Resultado:

   ```bash
   for file in README.md CHANGELOG.md ROADMAP.md CONTRIBUTING.md LICENSE LICENSE.md LICENSE.txt AGENTS.md CLAUDE.md; do
       [ -e "$file" ] && echo "existe: $file" || echo "no encontrado: $file"
   done
   find . -maxdepth 3 -name "README.md" -not -path "./README.md" -not -path "./node_modules/*" 2>/dev/null | head -10
   ```

3) Acción: leer la documentación principal.
   Resultado:

   ```bash
   [ -f README.md ] && { echo "=== README.md ==="; head -50 README.md; }
   [ -f CHANGELOG.md ] && { echo "=== CHANGELOG.md (primeras 30 líneas) ==="; head -30 CHANGELOG.md; }
   [ -f ROADMAP.md ] && { echo "=== ROADMAP.md ==="; head -30 ROADMAP.md; }
   [ -f AGENTS.md ] && { echo "=== AGENTS.md ==="; head -30 AGENTS.md; }
   ```

   Si `CLAUDE.md` es un enlace simbólico a `AGENTS.md`, leer solo uno. Leer también los primeros 20 renglones de los README de subcarpetas encontrados en el paso 2. Extraer propósito, tecnologías, estado actual y próximos pasos.

4) Acción: detectar tecnologías, contenedores, orquestación y CI/CD.
   Resultado:

   ```bash
   for f in package.json requirements.txt Pipfile pyproject.toml go.mod Cargo.toml pom.xml build.gradle Gemfile \
            Dockerfile compose.yaml docker-compose.yaml docker-compose.yml .gitlab-ci.yml Jenkinsfile kubeconfig talosconfig; do
       [ -e "$f" ] && echo "encontrado: $f"
   done
   for d in k8s kubernetes manifests charts .github/workflows; do [ -d "$d" ] && echo "carpeta: $d/"; done
   find . -maxdepth 2 \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | grep -E '(deployment|service|ingress|configmap)' | head -3
   find . \( -name "*kubeconfig*" -o -name "*talosconfig*" \) -not -path "./node_modules/*" 2>/dev/null | head -5
   ```

   Documentar tipo de proyecto, lenguajes, herramientas de compilación, contenedores, orquestación, configuración de clústeres (solo su existencia) y CI/CD.

5) Acción: examinar configuración, *scripts* y control de versiones.
   Resultado:

   ```bash
   ls -la | grep -E '\.(json|yaml|yml|toml|ini|conf|config)$' | head -10
   [ -d scripts ] && ls -la scripts/
   git remote -v 2>/dev/null || echo "No es un repositorio Git"
   git branch --show-current 2>/dev/null
   git --no-pager log --oneline -5 2>/dev/null
   ```

6) Acción: identificar el contexto personal o laboral.
   Resultado: personal (`@incognia`, `incognia@gmail.com`) o laboral (`@incogniadev`, `ralvarez@kabatone.com`, Kabat One), según remotos, identidad de git y documentación; esto define licencia y estilo (ver «~/rules/README.md», flujo de decisión).

7) Acción: validar la comprensión y generar el resumen.
   Resultado: responder si quedaron claros el propósito, las tecnologías, la estructura, las herramientas y el estado actual, y entregar:

   ```text
   ## Contexto del proyecto: [nombre o carpeta]

   ### Ubicación
   - Carpeta: [ruta completa]
   - Tipo: [repositorio Git, proyecto local, etc.] y contexto [personal o laboral]

   ### Propósito
   - [Descripción del proyecto]

   ### Tecnologías
   - [Lenguajes, frameworks y herramientas identificadas]

   ### Estructura
   - [Organización principal de carpetas]

   ### Estado actual
   - [Última actualización, versión, rama Git]

   ### Herramientas disponibles
   - [Scripts, comandos, configuraciones]

   ### Próximos pasos recomendados
   - [Acciones sugeridas basadas en el análisis]
   ```

Conclusión:

- Con este CoT se obtiene contexto suficiente para trabajar en el proyecto, comprender su estructura y tecnologías, identificar herramientas y convenciones, y planear contribuciones alineadas con sus objetivos.
- Referencias: README.md, CHANGELOG.md, ROADMAP.md, CONTRIBUTING.md y AGENTS.md del propio proyecto (si existen), «~/rules/cot/repo_context.md» ([./repo_context.md](./repo_context.md)) y «~/rules/README.md» ([../README.md](../README.md)).
