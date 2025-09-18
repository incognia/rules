---
domain: workflow
task: seguir COMMITTING.md (actualizar CHANGELOG, commit convencional y push simple)
dificultad: baja
longitud_objetivo: corta
validacion: entrada en CHANGELOG con fecha CST y commit/push exitosos
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Cumplir el flujo obligatorio: primero CHANGELOG, luego add/commit/push (ver «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md))).
- CRÍTICO: usar `git status` para analizar los cambios antes de proceder y determinar si requieren commits separados.
- Evaluar si los cambios son de tipos mixtos (ej. feat + fix, docs + refactor) que requieran commits atómicos separados.
- CRÍTICO: usar fecha en CST (Ciudad de México) calculada con TZ=America/Mexico_City; NUNCA rotular CST a horas UTC sin cálculo.
- OBLIGATORIO: usar `date` con timezone específica para obtener tiempo correcto; CST = UTC - 6 horas.
- CRÍTICO: Mensaje de commit SIEMPRE en inglés internacional con Conventional Commits; documentación en español mexicano.
- El push debe ser simple (`git push`) siempre que el repo haya sido configurado inicialmente (ver «~/rules/GIT.md» sección de configuración inicial).

Pasos:
0) Acción: validar que el repositorio esté configurado correctamente antes de proceder.
   COMANDOS OBLIGATORIOS: 
   - `git config --list | grep -E "^(user\.(name|email)|core\.sshCommand|remote\.origin)"`
   - `git remote -v` para verificar URLs de remotos
   Validaciones críticas:
   - Confirmar que existen: user.name, user.email, core.sshCommand y remote.origin
   - **CRÍTICO**: verificar que remote.origin usa SSH (git@github.com o git@gitlab.com), NO HTTPS
   - Si usa HTTPS: indica configuración incorrecta, redirigir a git_init
   Si falta cualquier configuración: aplicar «~/rules/prompts/cot/git_init.md» ([./git_init.md](./git_init.md)) antes de continuar
   Resultado: repositorio validado con SSH y listo para commits, o redirigir a inicialización.

1) Acción: analizar el estado actual del repositorio para identificar tipos de cambios.
   Resultado: `git status` - examinar archivos modificados/añadidos/eliminados y sus propósitos.
   Evaluación: determinar si los cambios son de un solo tipo (ej. solo docs) o mixtos (ej. feat + fix).
   Decisión: si son mixtos, planificar commits atómicos separados usando `git add` selectivo por archivo/directorio.

2) Acción: calcular la fecha CST correcta para el CHANGELOG (sin hora).
   OBLIGATORIO: ejecutar `TZ=America/Mexico_City date` para obtener fecha/hora CST real.
   Resultado: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`.
   Verificación: comparar con `date -u` (UTC) para confirmar que el cálculo es correcto (CST = UTC - 6h).

3) Acción: editar CHANGELOG.md y agregar entrada(s) bajo `## [${DATE_CST}]` según tipos de cambios identificados.
   Referencia: aplicar «~/rules/prompts/cot/changelog.md» ([./changelog.md](./changelog.md)) para mantenimiento correcto del *changelog*
   Resultado: nueva(s) línea(s) tipo `- docs: descripción breve del cambio` en español mexicano (solo fecha, sin hora).
   Nota: si hay múltiples tipos, agregar una línea por cada tipo de cambio.

4) Acción: realizar commits atómicos según análisis del paso 1.
   - Si cambios homogéneos (un tipo): `git add -A && git commit -m "tipo: descripción"`
   - Si cambios mixtos: commits separados usando `git add archivo(s)` selectivo por cada tipo:
     * `git add archivo1 archivo2 && git commit -m "feat: descripción funcionalidad"`
     * `git add archivo3 && git commit -m "fix: descripción corrección"`
     * etc.

5) Acción: push simple de todos los commits.
   Resultado: `git push`.

6) Acción: verificación no interactiva de los commits realizados.
   Resultado: `git --no-pager log --oneline -5` (ver últimos commits sin paginador).

Conclusión:
- Verifica que el/los commit(s) aparecen en `git --no-pager log --oneline -5` y que el CHANGELOG contiene la fecha en CST calculada correctamente.
- EJEMPLO de verificación de timezone: si UTC es 14:30, CST debe ser 08:30 (14 - 6 = 8); si UTC es 03:15, CST debe ser 21:15 del día anterior.
- Si fueron commits múltiples, asegurar que cada uno es atómico y tiene mensaje convencional apropiado (feat, fix, docs, etc.).
- Si aparece `quote>` durante el commit: presionar Ctrl+C y revisar escape de comillas en el mensaje.
- **PISTA IMPORTANTE**: si `git remote -v` muestra URLs con https:// en lugar de git@, indica configuración incorrecta y debe aplicarse git_init.
- La atomicidad de commits facilita el mantenimiento: cada commit debe representar un cambio lógico único y funcional.
- Referencias: «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)), «~/rules/prompts/cot/changelog.md» ([./changelog.md](./changelog.md)), «~/rules/prompts/cot/git_init.md» ([./git_init.md](./git_init.md)), «~/rules/docs/GIT.md» ([../../docs/GIT.md](../../docs/GIT.md)), «~/rules/README.md» ([../../README.md](../../README.md)) y «~/rules/docs/LINGUISTICS.md» ([../../docs/LINGUISTICS.md](../../docs/LINGUISTICS.md)).

