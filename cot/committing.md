---
domain: workflow
task: seguir COMMITTING.md (validar CHANGELOG preactualizado, commit convencional y push simple)
dificultad: baja
longitud_objetivo: corta
validacion: CHANGELOG detectado como modificado, identidad visual confirmada y commit/push exitosos
version: "1.3"
last_updated: 2026-05-10
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Cumplir el flujo obligatorio: `CHANGELOG.md` debe llegar previamente actualizado; `/commit` SOLO valida ese prerequisito y luego ejecuta add/commit/push (ver «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md))).
- Si `CHANGELOG.md` no tiene cambios respecto al repositorio, se debe abortar y delegar la actualización a `/changelogger`.
- CRÍTICO: usar `git status` para analizar los cambios antes de proceder y determinar si requieren commits separados.
- Evaluar si los cambios son de tipos mixtos (ej. feat + fix, docs + refactor) que requieran commits atómicos separados.
- CRÍTICO: mensaje de commit SIEMPRE en inglés internacional con Conventional Commits; documentación en español mexicano.
- El push debe ser simple (`git push`) siempre que el repo haya sido configurado inicialmente (ver «~/rules/GIT.md» sección de configuración inicial).

Pasos:
0) Acción: validar que el repositorio esté configurado correctamente y mostrar identidad activa antes de proceder.
   CONDICIÓN DE SESIÓN: Si ya ejecutaste este paso exitosamente en esta misma sesión de conversación, OMITIR este paso y continuar directamente en el paso 1. No repetir la validación dentro de la misma sesión.
   COMANDOS OBLIGATORIOS:
   - `git config --list | grep -E "^(user\.(name|email)|core\.sshCommand|remote\.origin)"`
   - `git remote -v` para verificar URLs de remotos
   - **NUEVO**: mostrar identidad activa en pantalla:
     ```bash
     echo "=== IDENTIDAD ACTIVA PARA ESTE COMMIT ==="
     echo "Email: $(git config user.email)"
     echo "Nombre: $(git config user.name)"
     echo "Llave SSH: $(git config core.sshCommand | grep -o '/[^"]*' || echo 'default ~/.ssh/id_rsa')"
     echo "Remoto: $(git remote get-url origin)"
     echo "============================================"
     ```
   Validaciones críticas:
   - Confirmar que existen: user.name, user.email, core.sshCommand y remote.origin
   - **CRÍTICO**: verificar que remote.origin usa SSH (git@github.com o git@gitlab.com), NO HTTPS
   - **CRÍTICO**: confirmar visualmente que la identidad mostrada es la correcta para este repositorio
   - Si usa HTTPS: indica configuración incorrecta, redirigir a git_init
   - Si la identidad no es la esperada: pausar y revisar configuración
   Si falta cualquier configuración: aplicar «~/rules/cot/git_init.md» ([./git_init.md](./git_init.md)) antes de continuar
   Resultado: repositorio validado con SSH, identidad confirmada visualmente, y listo para commits.

1) Acción: analizar el estado actual del repositorio para identificar tipos de cambios.
   Resultado: `git status` - examinar archivos modificados/añadidos/eliminados y sus propósitos.
   Evaluación: determinar si los cambios son de un solo tipo (ej. solo docs) o mixtos (ej. feat + fix).
   Decisión: si son mixtos, planificar commits atómicos separados usando `git add` selectivo por archivo/directorio.

2) Acción: validar gate de `CHANGELOG.md` antes de staging/commit.
   COMANDOS OBLIGATORIOS:
   - `git --no-pager diff --quiet -- CHANGELOG.md`
   - `git --no-pager diff --cached --quiet -- CHANGELOG.md`
   Decisión crítica:
   - Si **ambos comandos retornan 0**: no hay cambios en `CHANGELOG.md` (ni staged ni unstaged) → **ABORTAR** flujo y sugerir `/changelogger`.
   - Si **alguno retorna 1**: `CHANGELOG.md` sí tiene cambios → continuar.
   Resultado: prerequisito de changelog confirmado para seguir con `/commit`.

2b) Acción: inspeccionar diff de `CHANGELOG.md` (opcional recomendado para trazabilidad).
   COMANDOS:
   - `git --no-pager diff -- CHANGELOG.md`
   - `git --no-pager diff --cached -- CHANGELOG.md`
   Resultado: visibilidad explícita del cambio de changelog antes del commit.

3) Acción: construir mensaje detallado de commit en archivo temporal reutilizable.
   Resultado: crear `/tmp/commit-msg.txt` con esta plantilla:
   ```text
   <tipo>[scope opcional]: <resumen en inglés>
   
   - detalle 1 en inglés
   - detalle 2 en inglés con posible continuación
     alineada con el texto del bullet
   - detalle 3 en inglés

   Co-Authored-By: Oz <oz-agent@warp.dev>
   ```
   Validaciones críticas:
   - Primera línea en inglés internacional usando Conventional Commits.
   - Cuerpo en viñetas con cambios concretos.
   - El bullet `-` inicia en columna 1 (sin espacios o tabs previos).
   - Si una viñeta es larga, partirla manualmente y alinear continuidad con dos espacios.
   - Una línea en blanco entre encabezado/cuerpo y cuerpo/pie.

3b) Acción: checkpoint obligatorio de idioma antes de `git commit -F`.
   Declaración obligatoria:
   - `⚠️ LANGUAGE CHECK: All commit messages must be in English per ~/rules/cot/committing.md line 15`
   Validación:
   - Mostrar/revisar el contenido de `/tmp/commit-msg.txt` y confirmar inglés en subject/body.
   - Confirmar presencia de `Co-Authored-By: Oz <oz-agent@warp.dev>`.
   Resultado: mensaje validado en inglés internacional y listo para commit no interactivo.

4) Acción: realizar commits atómicos según análisis del paso 1 usando el archivo temporal del paso 3.
   - Si cambios homogéneos (un tipo): `git add -A && git commit -F /tmp/commit-msg.txt`
   - Si cambios mixtos: commits separados usando `git add archivo(s)` selectivo por cada tipo, reescribiendo `/tmp/commit-msg.txt` antes de cada commit:
     * `git add archivo1 archivo2 && git commit -F /tmp/commit-msg.txt`
     * `git add archivo3 && git commit -F /tmp/commit-msg.txt`
     * etc.

5) Acción: push simple de todos los commits.
   Resultado: `git push`.

6) Acción: verificación no interactiva de los commits realizados.
   Resultado: `git --no-pager log --oneline -5` (ver últimos commits sin paginador).

Conclusión:
- Verifica que el/los commit(s) aparecen en `git --no-pager log --oneline -5`.
- **CRÍTICO**: confirma que la identidad mostrada en el paso 0 coincide con la esperada para este repositorio (email y llave SSH correctas).
- Si fueron commits múltiples, asegurar que cada uno es atómico y tiene mensaje convencional apropiado (feat, fix, docs, etc.).
- Para evitar `quote>` y errores de escape, preferir siempre `git commit -F /tmp/commit-msg.txt`.
- **PISTA IMPORTANTE**: si `git remote -v` muestra URLs con https:// en lugar de git@, indica configuración incorrecta y debe aplicarse git_init.
- **PISTA CUENTAS MÚTIPLES**: si el email/llave no coincide con lo esperado, revisar configuración del repositorio antes de proceder.
- La atomicidad de commits facilita el mantenimiento: cada commit debe representar un cambio lógico único y funcional.
- Anti-patrones prohibidos (detener y pedir confirmación si aparece cualquiera):
  - Continuar a `git add`/`git commit` sin pasar el gate de cambios de `CHANGELOG.md`.
  - Intentar editar `CHANGELOG.md` desde `/commit` en vez de ejecutar `/changelogger`.
  - Hacer commit con mensaje en español o sin checkpoint explícito de idioma.
  - Usar flujo interactivo (editor/pager) en lugar de `git commit -F /tmp/commit-msg.txt`.
- Referencias: «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md)), «~/rules/cot/changelog.md» ([./changelog.md](./changelog.md)), «~/rules/cot/git_init.md» ([./git_init.md](./git_init.md)), «~/rules/rulesets/GIT.md» ([../rulesets/GIT.md](../rulesets/GIT.md)), «~/rules/README.md» ([../../README.md](../../README.md)) y «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)).

