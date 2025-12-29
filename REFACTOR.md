# Refactorización: simplificación de estructura de directorios

**Fecha**: 2025-12-29
**Objetivo**: simplificar estructura eliminando anidamiento innecesario y renombrando directorios para mayor claridad
**Tiempo estimado**: 45-60 minutos
**Riesgo**: medio (muchas referencias pero cambios predecibles)

## Estructura objetivo

```
rules/
├── README.md
├── PHILOSOPHY.md
├── CHANGELOG.md
├── LICENSE
├── WARP.md
├── rulesets/         # ← docs/ renombrado
├── cot/              # ← prompts/cot/ + contenido de otros subdirectorios
├── scripts/          # ← incluye cst_date.sh
└── templates/        # ← prompts/templates/ (evaluar si mantener)
```

## Preparación (antes de tocar archivos)

- [ ] Crear rama de refactorización
  ```bash
  git checkout -b refactor/simplify-structure
  ```

- [ ] Backup manual del estado actual
  ```bash
  tar -czf ~/backups/rules-pre-refactor-$(date +%Y%m%d-%H%M%S).tar.gz ~/rules
  ```

- [ ] Documentar cantidad de referencias a actualizar
  ```bash
  echo "Referencias a docs/: $(grep -r 'docs/' ~/rules --include='*.md' --exclude-dir=node_modules | wc -l)"
  echo "Referencias a prompts/: $(grep -r 'prompts/' ~/rules --include='*.md' --exclude-dir=node_modules | wc -l)"
  ```

## Fase 1: movimientos de archivos

### 1.1 Renombrar `docs/` → `rulesets/`

- [ ] Renombrar directorio
  ```bash
  git mv docs rulesets
  ```

- [ ] Verificar contenido movido
  ```bash
  ls -la rulesets/
  ```

### 1.2 Crear `cot/` en raíz y mover contenido

- [ ] Crear directorio cot/ en raíz
  ```bash
  mkdir -p cot
  ```

- [ ] Mover CoTs desde prompts/cot/
  ```bash
  git mv prompts/cot/*.md cot/
  ```

- [ ] Mover action a cot/
  ```bash
  git mv prompts/actions/release.md cot/
  ```

- [ ] Mover guide a cot/ (renombrar)
  ```bash
  git mv prompts/guides/git_workflow_guide.md cot/git_workflow.md
  ```

### 1.3 Consolidar `templates/`

- [ ] Crear templates/ en raíz
  ```bash
  mkdir -p templates
  ```

- [ ] Mover template
  ```bash
  git mv prompts/templates/issue_template.md templates/
  ```

### 1.4 Mover *snippet* a `scripts/`

- [ ] Mover cst_date.sh
  ```bash
  git mv prompts/snippets/cst_date.sh scripts/
  ```

- [ ] Hacer ejecutable
  ```bash
  chmod +x scripts/cst_date.sh
  ```

### 1.5 Eliminar estructura `prompts/` vacía

- [ ] Eliminar subdirectorios vacíos
  ```bash
  rm -rf prompts/actions prompts/guides prompts/templates prompts/snippets
  ```

- [ ] Eliminar READMEs de subdirectorios
  ```bash
  rm -f prompts/README.md prompts/cot/README.md 2>/dev/null
  ```

- [ ] Eliminar directorio prompts/ si quedó vacío
  ```bash
  rmdir prompts 2>/dev/null || echo "prompts/ no está vacío, revisar contenido"
  ```

## Fase 2: actualizar referencias internas

### 2.1 Referencias `docs/` → `rulesets/`

- [ ] Actualizar en archivos raíz
  ```bash
  sed -i 's|docs/|rulesets/|g' README.md PHILOSOPHY.md WARP.md ROADMAP.md PROMPTS.md 2>/dev/null
  ```

- [ ] Actualizar en cot/
  ```bash
  find cot/ -name "*.md" -exec sed -i 's|docs/|rulesets/|g' {} +
  ```

- [ ] Actualizar en rulesets/ (auto-referencias)
  ```bash
  find rulesets/ -name "*.md" -exec sed -i 's|docs/|rulesets/|g' {} +
  ```

- [ ] Actualizar en scripts/
  ```bash
  find scripts/ -name "*.sh" -exec sed -i 's|docs/|rulesets/|g' {} +
  ```

### 2.2 Actualizar rutas relativas `docs/` en CoTs

- [ ] Actualizar enlaces Markdown (../../docs/ → ../rulesets/)
  ```bash
  find cot/ -name "*.md" -exec sed -i 's|\.\./\.\./docs/|\.\./rulesets/|g' {} +
  ```

- [ ] Verificar con grep
  ```bash
  grep -r "\.\./\.\./docs/" cot/ || echo "✅ No quedan referencias ../../docs/"
  ```

### 2.3 Referencias `prompts/cot/` → `cot/`

- [ ] Actualizar en archivos raíz
  ```bash
  sed -i 's|prompts/cot/|cot/|g' README.md WARP.md ROADMAP.md PROMPTS.md 2>/dev/null
  ```

- [ ] Actualizar en rulesets/
  ```bash
  find rulesets/ -name "*.md" -exec sed -i 's|prompts/cot/|cot/|g' {} +
  ```

- [ ] Actualizar referencias ~/rules/prompts/cot/ → ~/rules/cot/
  ```bash
  find cot/ rulesets/ -name "*.md" -exec sed -i 's|~/rules/prompts/cot/|~/rules/cot/|g' {} +
  find . -maxdepth 1 -name "*.md" -exec sed -i 's|~/rules/prompts/cot/|~/rules/cot/|g' {} +
  ```

### 2.4 Actualizar rutas relativas dentro de CoTs

- [ ] Actualizar referencias entre CoTs
  ```bash
  # Verificar que referencias internas entre CoTs usan ./ no ../
  grep -r "\.\./cot/" cot/ && echo "⚠️  Hay referencias ../cot/ que corregir" || echo "✅ Referencias internas correctas"
  ```

- [ ] Actualizar rutas relativas a rulesets/ desde cot/
  ```bash
  find cot/ -name "*.md" -exec sed -i 's|\.\./prompts/|./|g' {} +
  ```

### 2.5 Actualizar referencias a `templates/`

- [ ] Actualizar prompts/templates/ → templates/
  ```bash
  find . -name "*.md" -exec sed -i 's|prompts/templates/|templates/|g' {} +
  ```

### 2.6 Actualizar referencias a `scripts/`

- [ ] Actualizar prompts/snippets/cst_date.sh → scripts/cst_date.sh
  ```bash
  find . -name "*.md" -exec sed -i 's|prompts/snippets/cst_date\.sh|scripts/cst_date.sh|g' {} +
  ```

## Fase 3: actualizar documentación estructural

### 3.1 Actualizar `README.md`

- [ ] Revisar sección «Documentos incluidos»
  - Cambiar referencias `docs/` por `rulesets/`

- [ ] Actualizar sección «Prompts (Chain-of-Thought) y estructura»
  - Eliminar referencias a subdirectorios de prompts/
  - Simplificar a: `cot/`, `templates/`, `scripts/`

- [ ] Actualizar diagrama mermaid del flujo CoT
  - Cambiar `~/cot/` referencias (el symlink sigue funcionando)
  - Cambiar referencias a `~/rules/docs/` por `~/rules/rulesets/`

### 3.2 Actualizar `WARP.md`

- [ ] Actualizar sección «Directory Organization»
  ```markdown
  ├── rulesets/       # Core rules and documentation
  ├── cot/            # Chain-of-Thought prompts
  ├── templates/      # Reusable templates
  └── scripts/        # Utility scripts
  ```

- [ ] Actualizar sección «Key Rules to Follow»
  - Referencias a rulesets/ en lugar de docs/

- [ ] Actualizar sección «Integration with Other Repositories»
  - Path convention: `~/rules/rulesets/LINGUISTICS.md`

### 3.3 Actualizar `ROADMAP.md`

- [ ] Actualizar referencias docs/ → rulesets/

- [ ] Actualizar estadísticas CoT Coverage
  - Mencionar nueva estructura simplificada
  - Actualizar conteo si agregaste archivos de actions/guides

### 3.4 Actualizar `PROMPTS.md`

- [ ] Actualizar estructura de directorios

- [ ] Eliminar referencias a actions/, guides/, snippets/

### 3.5 Actualizar `PHILOSOPHY.md`

- [ ] Verificar referencias a docs/
  ```bash
  grep "docs/" PHILOSOPHY.md && echo "⚠️  Actualizar" || echo "✅ Sin referencias"
  ```

## Fase 4: actualizar *symlink* `~/cot`

- [ ] Verificar symlink actual
  ```bash
  ls -la ~/cot
  ```

- [ ] Recrear symlink apuntando a nueva ubicación
  ```bash
  rm -f ~/cot
  ln -s ~/rules/cot ~/cot
  ```

- [ ] Verificar funcionalidad
  ```bash
  ls ~/cot/committing.md && echo "✅ Symlink funcional"
  ```

## Fase 5: validación y pruebas

### 5.1 Validación de enlaces rotos

- [ ] Ejecutar *markdown-link-check*
  ```bash
  npm run check:links
  ```

- [ ] Corregir enlaces rotos reportados

### 5.2 Validación de análisis estático

- [ ] Ejecutar *markdownlint*
  ```bash
  npm run lint:md
  ```

- [ ] Corregir errores de formato

### 5.3 Validación manual de CoTs críticos

- [ ] Verificar committing.md
  ```bash
  grep "rulesets/COMMITTING.md" cot/committing.md && echo "✅"
  grep "\.\./rulesets/" cot/committing.md && echo "✅"
  ```

- [ ] Verificar context.md (no debería tener referencias docs/)
  ```bash
  grep "docs/" cot/context.md && echo "⚠️  Tiene docs/" || echo "✅"
  ```

- [ ] Verificar linguistics.md
  ```bash
  grep "rulesets/LINGUISTICS.md" cot/linguistics.md && echo "✅"
  ```

### 5.4 Verificar archivos movidos

- [ ] Confirmar que cot/ tiene todos los archivos esperados
  ```bash
  ls -1 cot/*.md | wc -l
  # Debe ser: 16 (originales) + 2 (release.md, git_workflow.md) = 18
  ```

- [ ] Confirmar que prompts/ ya no existe
  ```bash
  [ ! -d prompts ] && echo "✅ prompts/ eliminado" || echo "⚠️  prompts/ aún existe"
  ```

## Fase 6: actualizar `CHANGELOG.md`

- [ ] Agregar entrada en CHANGELOG.md
  ```markdown
  ## [2025-12-29]
  
  ### Changed
  - refactor: simplificar estructura de directorios del repositorio
    - Renombrar `docs/` → `rulesets/` (más descriptivo del contenido)
    - Mover `prompts/cot/` → `cot/` (raíz, eliminar anidamiento)
    - Consolidar `prompts/actions/release.md` y `prompts/guides/git_workflow_guide.md` en `cot/`
    - Mover `prompts/snippets/cst_date.sh` → `scripts/`
    - Mover `prompts/templates/` → `templates/` (raíz)
    - Eliminar estructura vacía `prompts/` y subdirectorios
    - Actualizar 82+ referencias internas en documentación y CoTs
    - Actualizar symlink `~/cot` apuntando a nueva ubicación
    - Razón: 95% del uso es CoTs, subdirectorios de prompts/ subutilizados (1 archivo c/u)
  ```

## Fase 7: *commit* y validación final

- [ ] Revisar estado de Git
  ```bash
  git status
  ```

- [ ] Revisar diferencias
  ```bash
  git --no-pager diff --stat
  ```

- [ ] Stage todos los cambios
  ```bash
  git add -A
  ```

- [ ] Commit con mensaje convencional
  ```bash
  git commit -m "refactor: simplify directory structure (docs→rulesets, flatten cot/)"
  ```

- [ ] Verificar commit
  ```bash
  git --no-pager log --oneline -1
  git --no-pager show --stat
  ```

## Fase 8: pruebas posteriores a refactorización

- [ ] Probar CoT crítico
  ```bash
  # Simular uso típico
  cat ~/cot/committing.md | head -30
  ```

- [ ] Verificar que no quedan referencias antiguas
  ```bash
  echo "=== Verificación de referencias antiguas ==="
  grep -r "docs/" --include="*.md" --exclude-dir=node_modules . | grep -v "rulesets" | grep -v "CHANGELOG" | grep -v "markdown" | head -10
  grep -r "prompts/cot" --include="*.md" --exclude-dir=node_modules . | head -10
  ```

- [ ] Confirmar estructura final
  ```bash
  tree -L 2 -I 'node_modules' ~/rules
  ```

## Fase 9: *push* y cierre

- [ ] Push de la rama
  ```bash
  git push -u origin refactor/simplify-structure
  ```

- [ ] Merge a main (local)
  ```bash
  git checkout main
  git merge refactor/simplify-structure
  ```

- [ ] Push de main
  ```bash
  git push
  ```

- [ ] Eliminar rama de refactor
  ```bash
  git branch -d refactor/simplify-structure
  git push origin --delete refactor/simplify-structure
  ```

- [ ] Eliminar este archivo REFACTOR.md
  ```bash
  git rm REFACTOR.md
  git commit -m "chore: remove refactor checklist (completed)"
  git push
  ```

## Resumen de cambios

### Estructura antes

```
rules/
├── docs/ (14 archivos)
├── prompts/
│   ├── cot/ (16 archivos)
│   ├── actions/ (2 archivos)
│   ├── guides/ (2 archivos)
│   ├── templates/ (2 archivos)
│   └── snippets/ (2 archivos)
└── scripts/ (5 archivos)
```

### Estructura después

```
rules/
├── rulesets/ (14 archivos) ← docs/
├── cot/ (18 archivos) ← prompts/cot/ + actions + guides
├── templates/ (1 archivo) ← prompts/templates/
└── scripts/ (6 archivos) ← + cst_date.sh
```

**Archivos a actualizar:** ~82 referencias internas
**Reversibilidad:** alta (backup manual + rama Git)
