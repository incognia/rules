---
domain: proyecto
task: obtener_contexto
target: directorio_actual
difficulty: básico
priority: crítico
estimated_time: 10-15 minutos
last_updated: 2025-09-18
version: "2.1"
---
<!-- markdownlint-disable MD041 -->

# CoT: obtener contexto del proyecto actual

## Propósito

Obtener contexto completo del proyecto en el directorio actual mediante:

- Identificación de ubicación y estructura del proyecto
- Análisis de archivos de documentación principales y en subdirectorios
- Comprensión de propósito, estado actual y planificación
- Detección de herramientas, tecnologías y convenciones
- Identificación de infraestructura Kubernetes y Talos

## Casos de uso

- **Nueva sesión de trabajo**: establecer contexto rápido en cualquier proyecto
- **Exploración de repositorios**: entender proyectos desconocidos
- **Revisión de progreso**: evaluar estado actual vs objetivos
- **Colaboración**: comprender reglas y convenciones del proyecto
- **Diagnóstico**: identificar estructura y herramientas disponibles

## Razonamiento

1. **`pwd`** identifica ubicación actual del proyecto
2. **`tree`** revela estructura completa de archivos y directorios
3. **Archivos clave** (README, CHANGELOG, etc.) proporcionan documentación principal
4. **Análisis sistemático** permite comprensión rápida de cualquier proyecto
5. **Detección automática** de tecnologías y herramientas utilizadas

## Pasos

### 1. Identificar ubicación y contexto

```bash
# Obtener directorio actual
pwd

# Mostrar estructura del proyecto (instalar tree si es necesario)
tree -L 3 -a
```

**Si tree no está instalado, ejecutar según el sistema**:

```bash
# Fedora/RHEL/CentOS
sudo dnf install tree

# Ubuntu/Debian
sudo apt update && sudo apt install tree

# Alpine
sudo apk add tree

# Arch Linux
sudo pacman -S tree

# macOS (con Homebrew)
brew install tree
```

### 2. Identificar archivos de documentación

```bash
# Buscar archivos de documentación principales en directorio raíz
ls -la | grep -i -E '(readme|changelog|roadmap|contributing|license|warp)'

# Verificar existencia de archivos específicos en raíz
for file in README.md CHANGELOG.md ROADMAP.md CONTRIBUTING.md LICENSE.md LICENSE.txt LICENSE WARP.md .warp.md; do
    [ -f "$file" ] && echo "✅ $file existe" || echo "❌ $file no encontrado"
done

# Buscar READMEs de segundo y tercer nivel (proyectos colaborativos)
echo "\n=== READMEs en subdirectorios ==="
find . -maxdepth 3 -name "README.md" -not -path "./README.md" 2>/dev/null | head -10
```

**Documentar archivos encontrados**:

- ✅ **README**: [existe/no existe]
- ✅ **CHANGELOG**: [existe/no existe]
- ✅ **ROADMAP**: [existe/no existe]
- ✅ **CONTRIBUTING**: [existe/no existe]
- ✅ **LICENSE**: [existe/no existe]
- ✅ **WARP**: [existe/no existe]

### 3. Leer documentación principal

```bash
# Leer archivos de documentación (si existen)
if [ -f README.md ]; then echo "=== README.md ==="; head -50 README.md; fi
if [ -f CHANGELOG.md ]; then echo "\n=== CHANGELOG.md (últimas 20 líneas) ==="; tail -20 CHANGELOG.md; fi
if [ -f ROADMAP.md ]; then echo "\n=== ROADMAP.md ==="; head -30 ROADMAP.md; fi
if [ -f WARP.md ]; then echo "\n=== WARP.md ==="; head -30 WARP.md; fi
if [ -f .warp.md ]; then echo "\n=== .warp.md ==="; head -30 .warp.md; fi

# Leer READMEs de subdirectorios (proyectos colaborativos)
echo "\n=== READMEs de subdirectorios ==="
find . -maxdepth 3 -name "README.md" -not -path "./README.md" 2>/dev/null | while read readme; do
    echo "\n--- $readme ---"
    head -20 "$readme"
done
```

**Extraer información clave**:

- ✅ **Propósito del proyecto**: [descripción principal]
- ✅ **Tecnologías utilizadas**: [lenguajes, frameworks, herramientas]
- ✅ **Estado actual**: [versión, última actualización]
- ✅ **Objetivos futuros**: [roadmap, próximos pasos]

### 4. Analizar estructura técnica

```bash
# Detectar tipo de proyecto y tecnologías
echo "=== Detección de tecnologías ==="

# Lenguajes y frameworks
[ -f package.json ] && echo "✅ Node.js (package.json)" || echo "❌ No es proyecto Node.js"
[ -f requirements.txt ] && echo "✅ Python (requirements.txt)" || echo "❌ No es proyecto Python (requirements.txt)"
[ -f Pipfile ] && echo "✅ Python (Pipfile)" || echo "❌ No es proyecto Python (Pipfile)"
[ -f go.mod ] && echo "✅ Go (go.mod)" || echo "❌ No es proyecto Go"
[ -f Cargo.toml ] && echo "✅ Rust (Cargo.toml)" || echo "❌ No es proyecto Rust"
[ -f pom.xml ] && echo "✅ Java Maven (pom.xml)" || echo "❌ No es proyecto Java Maven"
[ -f build.gradle ] && echo "✅ Java Gradle (build.gradle)" || echo "❌ No es proyecto Java Gradle"

# Contenedores y orquestación
[ -f docker-compose.yml ] && echo "✅ Docker Compose" || echo "❌ No usa Docker Compose"
[ -f docker-compose.yaml ] && echo "✅ Docker Compose (.yaml)" || echo "❌ No usa Docker Compose (.yaml)"
[ -f Dockerfile ] && echo "✅ Docker" || echo "❌ No usa Docker"

# Kubernetes
[ -d k8s ] && echo "✅ Kubernetes (directorio k8s/)" || echo "❌ No tiene directorio k8s/"
[ -d kubernetes ] && echo "✅ Kubernetes (directorio kubernetes/)" || echo "❌ No tiene directorio kubernetes/"
[ -d manifests ] && echo "✅ Kubernetes (directorio manifests/)" || echo "❌ No tiene directorio manifests/"
find . -maxdepth 2 -name "*.yaml" -o -name "*.yml" | grep -E '(deployment|service|ingress|configmap|secret)' | head -3 | while read file; do echo "✅ Kubernetes manifest: $file"; done

# Configuración de clusters (archivos locales para EXPORT)
[ -f kubeconfig ] && echo "✅ Kubeconfig raíz encontrado" || echo "❌ No hay kubeconfig en raíz"
[ -f talosconfig ] && echo "✅ Talosconfig raíz encontrado" || echo "❌ No hay talosconfig en raíz"
echo "Buscando configuraciones Kubernetes..."
find . -name "*kubeconfig*" -o -name "*kube.config*" -o -name "*.kubeconfig" 2>/dev/null | head -5 | while read config; do echo "✅ Config Kubernetes: $config"; done
echo "Buscando configuraciones Talos..."
find . -name "*talosconfig*" -o -name "*talos.config*" -o -name "*.talosconfig" 2>/dev/null | head -5 | while read config; do echo "✅ Config Talos: $config"; done

# CI/CD
[ -d .github/workflows ] && echo "✅ GitHub Actions" || echo "❌ No usa GitHub Actions"
[ -f .gitlab-ci.yml ] && echo "✅ GitLab CI" || echo "❌ No usa GitLab CI"
```

**Documentar hallazgos**:

- ✅ **Tipo de proyecto**: [web, cli, biblioteca, infraestructura, etc.]
- ✅ **Tecnologías principales**: [lenguajes detectados]
- ✅ **Herramientas de build**: [npm, pip, cargo, etc.]
- ✅ **Contenedorización**: [Docker, docker-compose]
- ✅ **Orquestación**: [Kubernetes, manifests, directorios]
- ✅ **Configuración de clusters**: [kubeconfig, talosconfig]
- ✅ **CI/CD**: [GitHub Actions, GitLab CI, etc.]
- ✅ **READMEs adicionales**: [subdirectorios con documentación]

### 5. Examinar configuración y scripts

```bash
# Buscar archivos de configuración importantes
echo "=== Archivos de configuración ==="
ls -la | grep -E '\.(json|yaml|yml|toml|ini|conf|config)$' | head -10

# Buscar scripts ejecutables
echo "\n=== Scripts disponibles ==="
find . -maxdepth 2 -name "scripts" -type d 2>/dev/null && ls -la scripts/ 2>/dev/null
ls -la | grep -E '\.(sh|py|js|rb)$' | head -5

# Verificar git
echo "\n=== Información Git ==="
git remote -v 2>/dev/null || echo "❌ No es repositorio Git"
git branch --show-current 2>/dev/null || echo "❌ No hay rama activa"
```

**Sintetizar información operativa**:

- ✅ **Organización de directorios**: [estructura principal]
- ✅ **Scripts disponibles**: [herramientas encontradas]
- ✅ **Configuración**: [archivos de config importantes]
- ✅ **Control de versiones**: [Git, rama actual, remotos]

### 6. Validar comprensión y generar resumen

**Verificar comprensión**:

- ✅ ¿Está claro el propósito del proyecto?
- ✅ ¿Se identificaron las tecnologías principales?
- ✅ ¿Se comprende la estructura de directorios?
- ✅ ¿Se conocen las herramientas disponibles?
- ✅ ¿Se entiende el estado actual del desarrollo?

## Conclusión

Al completar este CoT tendrás contexto completo para:

- **Trabajar efectivamente** en cualquier proyecto
- **Comprender rápidamente** estructura y tecnologías utilizadas
- **Identificar herramientas** disponibles para desarrollo
- **Entender convenciones** específicas del proyecto
- **Planificar contribuciones** alineadas con objetivos del proyecto

## Salida esperada

Un resumen estructurado que incluya:

```text
## Contexto del proyecto: [nombre/directorio]

### Ubicación
- Directorio: [ruta completa]
- Tipo: [repositorio Git, proyecto local, etc.]

### Propósito
- [Descripción del proyecto]

### Tecnologías
- [Lenguajes, frameworks, herramientas identificadas]

### Estructura
- [Organización principal de directorios]

### Estado actual
- [Última actualización, versión, rama Git]

### Herramientas disponibles
- [Scripts, comandos, configuraciones]

### Próximos pasos recomendados
- [Acciones sugeridas basadas en el análisis]
```

## Referencias

- **./README.md** — documentación principal del proyecto
- **./CHANGELOG.md** — historial de cambios (si existe)
- **./ROADMAP.md** — planificación futura (si existe)
- **./CONTRIBUTING.md** — guías de contribución (si existe)
- **./WARP.md** — configuración y reglas específicas del proyecto (si existe)
- **./.warp.md** — configuración y reglas específicas del proyecto como dotfile (si existe)
- **tree command** — visualización de estructura de directorios
- **pwd command** — identificación de directorio actual
