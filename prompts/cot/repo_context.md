---
domain: workflow
task: obtener el contexto completo de un proyecto en GitHub/GitLab (estructura, flujo, CI, licencias, prácticas)
dificultad: media
longitud_objetivo: media
validacion: inventario de archivos clave, flujos, dependencias y políticas; fuentes citadas (archivos/enlaces)
---

Razonamiento:
- Empezar por documentos de entrada, luego pasar a estructura, dependencias, CI/CD, despliegue, estilo, pruebas, licencias y contribución.
- Mantener español mexicano y formato CoT; no ejecutar acciones destructivas ni exponer secretos.
- Si hay CLI (gh/glab), usarla solo para listar (no interactivo); de lo contrario, navegar archivos del repo.

Pasos:
1) Acción: identificar documentos base en la raíz.
   Resultado: README.md (propósito/uso), PHILOSOPHY.md o equivalente (marco), CONTRIBUTING.md, CODE_OF_CONDUCT.md.
2) Acción: revisar licenciamiento y atribución.
   Resultado: LICENSE/LICENCE/COPYING/NOTICE; si falta, buscar encabezados de licencia en fuentes.
3) Acción: mapear estructura del repo.
   Resultado: carpetas clave (src/, cmd/, pkg/, apps/, services/, docs/, scripts/, tools/, infra/, deployments/, charts/); Makefile/Taskfile.
4) Acción: detectar lenguaje y dependencias.
   Resultado: package.json/yarn.lock/pnpm-lock.yaml; go.mod; pyproject.toml/requirements*.txt; Cargo.toml; pom.xml/gradle.*; composer.json; Gemfile.
5) Acción: revisar CI/CD.
   Resultado: .github/workflows/*.yaml, .gitlab-ci.yml, Jenkinsfile, .circleci/, .drone.yml; triggers, jobs, artefactos, gates de calidad.
6) Acción: contenedores y despliegue.
   Resultado: Dockerfile(s), docker-compose.yaml/compose.yaml; Helm charts (charts/), manifiestos K8s (k8s/, deploy/, manifests/).
7) Acción: configuración y secretos.
   Resultado: .env.example/.env.sample; docs de variables; políticas de inyección (CI vars/Secret managers). No exponer secretos.
8) Acción: estilo y linters.
   Resultado: .editorconfig; eslint/prettier, golangci-lint, flake8/black, markdownlint, Vale; convenciones (Conventional Commits).
9) Acción: pruebas y cobertura.
   Resultado: tests/__tests__/*_test.go/pytest/jest; comandos (npm test, go test ./..., pytest); fixtures/datos simulados.
10) Acción: versionado e historial.
    Resultado: CHANGELOG.md, tags/releases (GitHub/GitLab Releases), SemVer/Conventional Commits.
11) Acción: contribución y ramas.
    Resultado: CODEOWNERS, plantillas de issues/PR/MR, ramas protegidas, políticas de revisión.
12) Acción (opcional): issues y PR/MR por CLI.
    Resultado: `gh issue list`, `gh pr list` o `glab` equivalente (si disponible y con permisos). No cerrar/merge desde aquí.
13) Acción: sintetizar contexto.
    Resultado: reporte con: propósito, estructura, dependencias, CI/CD, despliegue, config/secrets, estilo, pruebas, versión y contribución. Citar rutas/archivos.

Conclusión:
- Entregar inventario y síntesis reproducibles con referencias a archivos/paths y, si aplica, comandos de lectura (no destructivos). Mantener comillas «» y siglas sin plural gráfico.

