---
domain: workflow
task: seguir COMMITTING.md (validar identidad y CHANGELOG preactualizado, commits atómicos convencionales y push simple)
dificultad: baja
longitud_objetivo: corta
validacion: CHANGELOG detectado como modificado, identidad confirmada y commit/push exitosos
version: "1.5"
last_updated: 2026-10-15
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Cumplir el flujo obligatorio: `CHANGELOG.md` debe llegar previamente actualizado; `/commit` SOLO valida ese prerrequisito y luego ejecuta *add*, *commit* y *push* (ver «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md))).
- Si `CHANGELOG.md` no tiene cambios respecto al repositorio, abortar y delegar la actualización a `/changelogger`.
- *Commits* atómicos: cada *commit* representa un solo cambio lógico. Analiza `git status` y, si los cambios son de tipos mezclados (p. ej. `feat` + `fix`, `docs` + `refactor`), divídelos con `git add` selectivo; `CHANGELOG.md` viaja en el último *commit* de la serie.
- `/commit` corre en la sesión principal, nunca en un subagente, para que el *trailer* acredite al modelo que hizo el trabajo.
- CRÍTICO: mensaje de *commit* SIEMPRE en inglés internacional (UK) con Conventional *Commits*; documentación en español mexicano.
- El *push* debe ser simple (`git push`) siempre que el repositorio se haya configurado inicialmente (ver «~/rules/rulesets/GIT.md», sección de configuración inicial).

Pasos:

0) Acción: validar que el repositorio esté configurado correctamente y mostrar la identidad activa antes de proceder.
   CONDICIÓN DE SESIÓN: si ya ejecutaste este paso con éxito en esta misma sesión de conversación, omítelo y continúa en el paso 1. No repitas la validación dentro de la misma sesión.
   Comandos obligatorios:

   - `git config --list | grep -E "^(user\.(name|email)|core\.sshCommand|remote\.origin)"`
   - `git remote -v` para verificar las URL de los remotos
   - Mostrar la identidad activa en pantalla:

     ```bash
     echo "=== IDENTIDAD ACTIVA PARA ESTE COMMIT ==="
     echo "Email: $(git config user.email)"
     echo "Nombre: $(git config user.name)"
     echo "Llave SSH: $(git config core.sshCommand | grep -o '/[^ ]*' || echo 'predeterminada de ssh')"
     echo "Remoto: $(git remote get-url origin)"
     echo "============================================"
     ```

   Validaciones críticas:

   - Confirmar que existen `user.name`, `user.email`, `core.sshCommand` y `remote.origin`.
   - CRÍTICO: verificar que `remote.origin` usa SSH (`git@github.com` o `git@gitlab.com`), NO HTTPS.
   - CRÍTICO: confirmar que la identidad mostrada es la correcta para este repositorio (personal: `incognia@gmail.com` y `~/.ssh/incognia`; laboral: `ralvarez@kabatone.com` y `~/.ssh/kone`).
   - Si usa HTTPS o falta cualquier configuración: aplicar «~/rules/cot/git_init.md» ([./git_init.md](./git_init.md)) antes de continuar.
   - Si la identidad no es la esperada: pausar y revisar la configuración.

   Resultado: repositorio validado con SSH, identidad confirmada y listo para el *commit*.

1) Acción: revisar el estado del repositorio.
   Resultado: `git status --short` y `git --no-pager diff --stat` para entender qué cambió.
   Evaluación: determinar si los cambios son de un solo tipo (p. ej. solo `docs`) o mixtos (p. ej. `feat` + `fix`).
   Decisión: si son mixtos, planear aquí los grupos de archivos de cada *commit* atómico; `CHANGELOG.md` va con el último.

2) Acción: validar la puerta de `CHANGELOG.md` antes del *staging*.
   Comandos obligatorios:

   - `git --no-pager diff --quiet -- CHANGELOG.md`
   - `git --no-pager diff --cached --quiet -- CHANGELOG.md`

   Decisión crítica:

   - Si **ambos comandos retornan 0**: no hay cambios en `CHANGELOG.md` (ni en *staging* ni fuera de él) → **ABORTAR** el flujo y sugerir `/changelogger`.
   - Si **alguno retorna 1**: `CHANGELOG.md` sí tiene cambios → continuar.

   Opcional, para trazabilidad: `git --no-pager diff -- CHANGELOG.md` y `git --no-pager diff --cached -- CHANGELOG.md`.
   Resultado: prerrequisito de CHANGELOG confirmado.

3) Acción: construir el mensaje detallado del *commit* en un archivo temporal reutilizable.
   Resultado: crear `/tmp/commit-msg.txt` con esta plantilla:

   ```text
   <tipo>[scope opcional]: <resumen en inglés>

   - detalle 1 en inglés
   - detalle 2 en inglés con posible continuación
     alineada con el texto de la viñeta
   - detalle 3 en inglés

   Co-Authored-By: <agente en turno> <identificador>
   ```

   Validaciones críticas:

   - Primera línea en inglés internacional (UK) usando Conventional *Commits*.
   - Cuerpo en viñetas con cambios concretos y sustantivos del trabajo.
   - NO incluir viñetas del tipo `update/edit CHANGELOG.md` (o equivalentes), porque `CHANGELOG.md` es una precondición validada por la puerta del paso 2.
   - La viñeta `-` inicia en columna 1 (sin espacios ni tabuladores previos).
   - Si una viñeta es larga, partirla a mano y alinear la continuación con dos espacios.
   - Una línea en blanco entre encabezado y cuerpo, y entre cuerpo y pie.
   - `Co-Authored-By` se resuelve con la sesión activa justo antes de **cada** *commit* (el modelo puede cambiar a media conversación); nunca está fijo en el texto. Formato común: `Co-Authored-By: [<Herramienta> ]<Modelo> (<esfuerzo>) <correo>`, por ejemplo `Claude Opus 5.5 (medium)`, `Codex GPT-6.1 Sol (high)` o `Copilot GPT-6 Luna (low)`:
     1. En Claude Code, Codex o GitHub Copilot CLI, ejecutar `python3 ~/rules/scripts/commit_trailer.py` y usar su salida solo si termina con código 0. Si avisa que no hay esfuerzo disponible, el *trailer* con el modelo solo es válido.
     2. Si el *script* falla, usar la línea de atribución que proporcione la herramienta o el *harness* para la sesión (p. ej. la que inyecta Claude Code), en el formato común.
     3. Otras herramientas: construirlo con la identidad que reporta la propia sesión y el correo documentado (Anthropic `noreply@anthropic.com`, OpenAI `noreply@openai.com`, GitHub Copilot `223556219+Copilot@users.noreply.github.com`, Google Antigravity `antigravity-agent@google.com`, Warp `oz-agent@warp.dev`; otra → `noreply@<dominio-de-la-herramienta>`).
     4. Si no se puede verificar el modelo, omitir el *trailer* y avisar al usuario; nunca adivinar.
     - Prohibido copiar nombre, modelo o esfuerzo de estas reglas, de un *commit* anterior, de otra sesión o de la configuración predeterminada.

4) Acción: punto de control obligatorio de idioma antes de `git commit -F`.
   Declaración obligatoria:

   - `⚠️ LANGUAGE CHECK: All commit messages must be in international English (UK) per the CRÍTICO language rule in ~/rules/cot/committing.md`

   Validación:

   - Mostrar y revisar el contenido de `/tmp/commit-msg.txt` y confirmar inglés en asunto y cuerpo.
   - Confirmar la presencia de `Co-Authored-By` con el nombre real del agente o herramienta que ejecuta el *commit* (resuelto con `scripts/commit_trailer.py` o, si falla, con la atribución de la herramienta), no un ejemplo copiado de otra sesión.

   Resultado: mensaje validado en inglés internacional (UK) y listo para el *commit* no interactivo.

5) Acción: hacer *commits* atómicos según el análisis del paso 1, uno por grupo, con el archivo temporal del paso 3.
   - Cambios homogéneos (un solo tipo): `git add -A && git commit -F /tmp/commit-msg.txt`.
   - Cambios mixtos: por cada grupo, `git add -- <archivos> && git commit -F /tmp/commit-msg.txt`, reescribiendo `/tmp/commit-msg.txt` y volviendo a ejecutar `scripts/commit_trailer.py` antes de cada uno.
   - `CHANGELOG.md` entra en el **último** *commit* de la serie, junto con los archivos de ese grupo. Los anteriores pasan la puerta porque `CHANGELOG.md` sigue con cambios pendientes (el *hook* `pre-commit` acepta ese caso).
   Resultado: un *commit* por cambio lógico y árbol de trabajo limpio.

6) Acción: *push* simple.
   Resultado: `git push`.

7) Acción: verificación no interactiva.
   Resultado: `git --no-pager log --oneline -5` (últimos *commits* sin paginador).

Conclusión:

- Verifica que el *commit* aparece en `git --no-pager log --oneline -5`.
- CRÍTICO: la identidad mostrada en el paso 0 coincide con la esperada para este repositorio (correo y llave SSH correctos).
- Para evitar `quote>` y errores de escape, usa siempre `git commit -F /tmp/commit-msg.txt`.
- Pista: si `git remote -v` muestra URL con `https://` en lugar de `git@`, la configuración es incorrecta y debe aplicarse git_init.
- Pista de cuentas múltiples: si el correo o la llave no coinciden con lo esperado, revisa la configuración del repositorio antes de proceder.
- Anti-patrones prohibidos (detener y pedir confirmación si aparece cualquiera):
  - Continuar a `git add`/`git commit` sin pasar la puerta de cambios de `CHANGELOG.md`.
  - Intentar editar `CHANGELOG.md` desde `/commit` en vez de ejecutar `/changelogger`.
  - Incluir en el cuerpo del *commit* una viñeta de edición o mantenimiento de `CHANGELOG.md` como detalle del cambio.
  - Hacer *commit* con mensaje en español o sin punto de control explícito de idioma.
  - Usar flujo interactivo (editor o paginador) en lugar de `git commit -F /tmp/commit-msg.txt`.
  - Mezclar tipos de cambio sin relación en un mismo *commit*, o usar `git add .`/`git add -A` con cambios mezclados.
  - Incluir `CHANGELOG.md` antes del último *commit* de la serie.
- Referencias: «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md)), «~/rules/cot/changelog.md» ([./changelog.md](./changelog.md)), «~/rules/cot/git_init.md» ([./git_init.md](./git_init.md)), «~/rules/rulesets/GIT.md» ([../rulesets/GIT.md](../rulesets/GIT.md)), «~/rules/README.md» ([../README.md](../README.md)) y «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)).
