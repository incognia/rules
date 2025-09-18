---
domain: proyecto
task: obtener_contexto
target: directorio_actual
difficulty: básico
priority: crítico
estimated_time: 10-15 minutos
last_updated: 2025-09-18
version: "2.0"
---
<!-- markdownlint-disable MD041 -->

# CoT: obtener contexto del proyecto actual

## Propósito

Obtener contexto completo del proyecto en el directorio actual mediante:

- Identificación de ubicación y estructura del proyecto
- Análisis de archivos de documentación principales
- Comprensión de propósito, estado actual y planificación
- Detección de herramientas, tecnologías y convenciones

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
# Buscar archivos de documentación principales
ls -la | grep -i -E '(readme|changelog|roadmap|contributing|license|warp)'

# Verificar existencia de archivos específicos
for file in README.md CHANGELOG.md ROADMAP.md CONTRIBUTING.md LICENSE.md LICENSE.txt LICENSE WARP.md .warp.md; do
    [ -f "$file" ] && echo "✅ $file existe" || echo "❌ $file no encontrado"
done
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
[ -f package.json ] && echo "✅ Node.js (package.json)" || echo "❌ No es proyecto Node.js"
[ -f requirements.txt ] && echo "✅ Python (requirements.txt)" || echo "❌ No es proyecto Python (requirements.txt)"
[ -f Pipfile ] && echo "✅ Python (Pipfile)" || echo "❌ No es proyecto Python (Pipfile)"
[ -f go.mod ] && echo "✅ Go (go.mod)" || echo "❌ No es proyecto Go"
[ -f Cargo.toml ] && echo "✅ Rust (Cargo.toml)" || echo "❌ No es proyecto Rust"
[ -f pom.xml ] && echo "✅ Java Maven (pom.xml)" || echo "❌ No es proyecto Java Maven"
[ -f build.gradle ] && echo "✅ Java Gradle (build.gradle)" || echo "❌ No es proyecto Java Gradle"
[ -f docker-compose.yml ] && echo "✅ Docker Compose" || echo "❌ No usa Docker Compose"
[ -f Dockerfile ] && echo "✅ Docker" || echo "❌ No usa Docker"
[ -f .github/workflows ] && echo "✅ GitHub Actions" || echo "❌ No usa GitHub Actions"
```

**Documentar hallazgos**:

- ✅ **Tipo de proyecto**: [web, cli, biblioteca, etc.]
- ✅ **Tecnologías principales**: [lenguajes detectados]
- ✅ **Herramientas de build**: [npm, pip, cargo, etc.]
- ✅ **Containerización**: [Docker, docker-compose]
- ✅ **CI/CD**: [GitHub Actions, GitLab CI, etc.]

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
