# Reglas de mensajes de *commit* y gestión de cambios

## 1. Filosofía principal

Un historial de *commits* bien estructurado es una de las herramientas más valiosas para la facilidad de mantenimiento de un proyecto. Cada *commit* debe tener un propósito claro y un mensaje que lo describa de forma concisa.

## 2. Formato del mensaje de *commit*

Usa la especificación de [Commits Convencionales](https://www.conventionalcommits.org/en/v1.0.0/).

### 2.1. Estructura general

```text
<tipo>[ámbito opcional]: <descripción>

[cuerpo opcional]

[pie opcional]
```

### 2.2. Tipos de *commit*

- **feat:** una nueva funcionalidad para el usuario.
- **fix:** una corrección de un error.
- **docs:** cambios en la documentación.
- **style:** cambios que no afectan el significado del código (espacios, formato, etcétera).
- **refactor:** una reestructuración de código que no corrige un error ni añade una funcionalidad.
- **perf:** una mejora de rendimiento.
- **test:** añadir o corregir pruebas.
- **build:** cambios que afectan al sistema de compilación o a dependencias externas.
- **ci:** cambios en los archivos y *scripts* de configuración de CI.
- **chore:** otros cambios que no modifican el código fuente ni las pruebas (por ejemplo, actualización de dependencias).

**Importante:** los archivos CoT (*Chain of Thought*) como `cot/committing.md` son documentos funcionales que definen flujos automatizados. Se clasifican como **`feat:`** (no `docs:`), ya que representan nueva funcionalidad y automatización del proyecto, no simple documentación.

### 2.3. Reglas del mensaje

- **Idioma:** redacta siempre en **inglés internacional (UK)**; ver la sección 2.6.
- **Emojis:** no uses emojis.
- **Descripción:** concisa, en imperativo y en minúsculas (por ejemplo, `fix: correct user login flow`).
- **Cuerpo:** opcional, para explicar el *qué* y el *porqué* del cambio.
- **Pie:** opcional, para referencias a *issues* (`Refs: #123`) o para marcar cambios incompatibles (`BREAKING CHANGE:`).
- **Formato:** construye siempre el mensaje en `/tmp/commit-msg.txt` y haz el *commit* con `git commit -F /tmp/commit-msg.txt`; no uses `git commit -m`.

### 2.4. Ejemplos

#### Bueno

```text
feat(auth): add password reset functionality

Implement the password reset feature using a token-based system.
Users will receive an email with a secure link to reset their password.

Fixes: #42
```

#### Malo

```text
fix
```

```text
Updated files
```

### 2.5. Plantilla detallada (archivo temporal)

Construye el mensaje en un archivo temporal con la misma estructura de *Commits* Convencionales:

```text
docs: add frontend/backend cross-references

- Document the frontend and backend repositories using canonical URLs
- Replace relative backend references with repository links and
  backend-local startup commands
- Add SSH key alignment notes in README and docs/SERVERS.md

Co-Authored-By: <agente en turno> <identificador>
```

Reglas de formato obligatorias para esta plantilla:

- El marcador de viñeta `-` va alineado a la izquierda (columna 1), sin espacios ni tabuladores al inicio.
- Si una viñeta es larga, parte la línea a mano y continúa abajo.
- La línea de continuación lleva dos espacios de sangría para alinear el texto con el contenido de la viñeta.
- Mantén una línea en blanco entre asunto y cuerpo, y otra entre cuerpo y pie.
- El cuerpo describe solo cambios sustantivos: no incluyas viñetas del tipo «update CHANGELOG.md», porque el CHANGELOG es una precondición que valida la puerta de la sección 3.1, no un detalle del cambio.
- `Co-Authored-By` se resuelve de forma dinámica al momento del *commit*, nunca está fijo en el texto (ver el detalle completo en «~/rules/cot/committing.md»):
  - Formato común para todos los agentes: `Co-Authored-By: [<Herramienta> ]<Modelo> (<esfuerzo>) <correo>`; sin esfuerzo disponible, sin paréntesis.

    | Herramienta | Ejemplo | Correo |
    |-------------|---------|--------|
    | Claude Code | `Claude Opus 5.5 (medium)` | `noreply@anthropic.com` |
    | Codex | `Codex GPT-6.1 Sol (high)` | `noreply@openai.com` |
    | GitHub Copilot CLI | `Copilot GPT-6 Luna (low)` | `223556219+Copilot@users.noreply.github.com` |
    | Antigravity CLI (`agy`) | `Antigravity Gemini 3.8 Flash (high)` | `noreply@antigravity.google` |

  - En esas cuatro herramientas, resuélvelo con `python3 ~/rules/scripts/commit_trailer.py` justo antes de cada *commit*. El *script* detecta la herramienta por el entorno (`--tool codex|claude|copilot|antigravity|agy` la fuerza) y lee **solo** la sesión activa: en Claude Code, el modelo del último turno del hilo principal (descarta subagentes y `<synthetic>`) y el esfuerzo de `CLAUDE_EFFORT`; en Codex, el último `turn_context` del hilo; en Copilot CLI, el último registro de uso del agente raíz; en Antigravity CLI (`agy`), el modelo y esfuerzo del *transcript* o registros de la sesión y el agente del resumen o entorno. Usa su salida solo si termina con código 0.
  - El formato de las sesiones no es una API documentada: si cambia, el *script* falla en vez de adivinar. Entonces usa la línea de atribución que proporcione la herramienta, en el formato común; si tampoco hay, omite el *trailer* y avisa al usuario.
  - Nunca copies nombre, modelo o esfuerzo de un ejemplo, de un *commit* anterior, de otra sesión o de la configuración predeterminada.

Después haz el *commit* con:

```bash
git commit -F /tmp/commit-msg.txt
```

### 2.6. Idioma por contexto

Los mensajes de *commit* van **siempre** en inglés internacional (UK), con ortografía británica (`-ise`, *colour*, *behaviour*, *licence*). Es la regla CRÍTICO de idioma de la sección «Razonamiento» de «~/rules/cot/committing.md».

| Contexto | Idioma |
|----------|--------|
| Mensajes de *commit* | Inglés internacional (UK) |
| Código y comentarios en código | Inglés internacional (UK) |
| `CHANGELOG.md` y *releases* | Idioma principal del repositorio: español mexicano, o inglés internacional (UK) si el repositorio es mixto o en inglés (ver «~/rules/cot/changelog.md») |
| `README.md` y documentación | Español mexicano |
| Confluence (páginas y comentarios) | Inglés internacional (UK) |

```text
# Correcto
feat: add new functionality
fix: resolve authentication issue

# Incorrecto
feat: agregar nueva funcionalidad
fix: resolver problema de autenticación
```

**Declaración obligatoria** antes de `git commit -F`:

> «⚠️ LANGUAGE CHECK: All *commit* messages must be in international English (UK) per the CRÍTICO language rule in ~/rules/cot/committing.md»

Si se hizo un *commit* con el idioma equivocado y todavía no se envió, detén el flujo, corrígelo con `git commit --amend -F /tmp/commit-msg.txt` y vuelve a validar. Si ya se envió, avisa al usuario en vez de reescribir el historial.

## 3. Flujo de trabajo y gestión de cambios

### 3.1. Validación de `CHANGELOG.md` antes del *commit* (CRÍTICO)

**Regla crítica:** el flujo `/commit` NO modifica `CHANGELOG.md`; solo valida que ya se actualizó.

**Proceso obligatorio:**

1. **Primero:** actualizar `CHANGELOG.md` con `/changelogger`.
2. **Segundo:** ejecutar `/commit`, que valida la identidad (una vez por sesión), comprueba la puerta del CHANGELOG, planea *commits* atómicos, prepara cada grupo con `git add` selectivo y construye `/tmp/commit-msg.txt` para cada uno.
3. **Tercero:** hacer cada *commit* desde ese archivo: `git commit -F /tmp/commit-msg.txt`; `CHANGELOG.md` va en el último.
4. **Cuarto:** enviar con `git push`.

**Advertencia:** si `CHANGELOG.md` no tiene cambios, el flujo debe abortar y sugerir `/changelogger`.

**Refuerzo local en este repositorio:** el *hook* `.githooks/pre-commit` rechaza cualquier *commit* cuando `CHANGELOG.md` no está en *staging* ni tiene cambios pendientes (así pasan los *commits* intermedios de una serie atómica), y `.githooks/commit-msg` valida el formato de *Commits* Convencionales. Actívalos una vez por clon con `npm run hooks:install`. La variable `SKIP_CHANGELOG_GATE=1` existe solo para casos excepcionales.

#### 3.1.1. Protocolo anti-errores y anti-patrones (obligatorio, sin excepción)

Antes de continuar a `git add`/`git commit`, cumple este protocolo:

1. Ejecuta la puerta de cambios en `CHANGELOG.md`:

   ```bash
   if git --no-pager diff --quiet -- CHANGELOG.md && git --no-pager diff --cached --quiet -- CHANGELOG.md; then
       echo "ERROR: CHANGELOG.md sin cambios. Ejecuta /changelogger y vuelve a intentar /commit."
       exit 1
   fi
   ```

2. Si la puerta falla (sin cambios), detén la ejecución de inmediato.
3. Si la puerta pasa (hay cambios en *staging* o fuera de él), continúa con los *commits* atómicos (`git add -- <archivos>` y `git commit -F`).
4. Verifica la puerta de idioma: asunto y cuerpo de `/tmp/commit-msg.txt` completamente en inglés internacional (UK). Si falla, corrige el archivo antes de continuar.
5. El mantenimiento de formato e idioma del CHANGELOG se delega a `/changelogger` y «~/rules/cot/changelog.md».

Si cualquiera de las dos puertas falla dos veces seguidas, pide confirmación al usuario antes de otro intento.

Anti-patrones prohibidos:

- Continuar con *commit* o *push* cuando `CHANGELOG.md` no tiene cambios.
- Intentar editar `CHANGELOG.md` desde `/commit` en lugar de usar `/changelogger`.
- Omitir la puerta del CHANGELOG y depender solo de `git status` general.
- Hacer *commit* en español u omitir la declaración de idioma.
- Saltarse `/tmp/commit-msg.txt` y caer en mensajes improvisados con `-m`.

**Ejemplo del flujo correcto:**

```bash
# 1. Actualizar el changelog fuera de /commit
/changelogger

# 2. Validar la puerta del changelog
if git --no-pager diff --quiet -- CHANGELOG.md && git --no-pager diff --cached --quiet -- CHANGELOG.md; then
    echo "ERROR: CHANGELOG.md sin cambios. Ejecuta /changelogger y vuelve a intentar /commit."
    exit 1
fi

# 3. Preparar solo los archivos de este commit atómico (CHANGELOG.md va con el último)
git add -- rulesets/COMMITTING.md CHANGELOG.md

# 4. Preparar el mensaje detallado y hacer commit (no interactivo)
cat > /tmp/commit-msg.txt <<'EOF'
docs: validate changelog gate before commit

- Enforce changelog diff gate before staging and commit
- Abort commit flow when changelog has no repo diff
- Keep commit message workflow in English using temporary file

EOF
python3 ~/rules/scripts/commit_trailer.py >> /tmp/commit-msg.txt
git commit -F /tmp/commit-msg.txt

# 5. Enviar
git push
```

### 3.2. *Commits* atómicos

- **Un cambio lógico por *commit*:** analiza `git status` y separa los cambios de tipos distintos (`feat`, `fix`, `docs`, `refactor`…) en *commits* independientes, con `git add -- <archivos>`. Nunca uses `git add .` ni `git add -A` con cambios mezclados.
- **Orden de la serie:** los *commits* siguen las viñetas nuevas del día en `CHANGELOG.md` de abajo hacia arriba; el primero corresponde a la viñeta nueva de más abajo y el último a la de hasta arriba, que es la más reciente. `/changelogger` las ordena así desde el principio (ver «~/rules/cot/changelog.md», paso 6b) y nunca se reordenan viñetas existentes.
- **`CHANGELOG.md` va con el último *commit* de la serie:** `/changelogger` lo actualiza una vez para todo el trabajo; los *commits* intermedios pasan la puerta porque el archivo sigue con cambios pendientes.
- **Atribución por *commit*:** vuelve a ejecutar `scripts/commit_trailer.py` antes de cada uno.
- **Un solo *push*** al final de la serie.

### 3.3. Asociación con tareas

- **Referencia a *issues*:** siempre que sea posible, asocia los *commits* con su *issue*, *ticket* o tarea correspondiente en el pie del mensaje (`Refs: #123`, `Closes: #123`).

### 3.4. *Push* simplificado

Si el repositorio está configurado correctamente (identidad y SSH), el comando de envío es simplemente:

```bash
git push
```

Para la primera configuración (elegir entre credenciales personales o laborales) consulta [GIT.md](./GIT.md#3-configuración-inicial-y-ssh-por-contexto).

**Validación de identidad:** una vez por sesión, antes del primer *commit*, aplica el paso 0 completo de «~/rules/cot/committing.md» (`user.name`, `user.email`, `core.sshCommand`, `remote.origin` en SSH y bloque de identidad visible).

### 3.5. Comandos git no interactivos

**Importante:** usa siempre comandos no interactivos para evitar paginadores y editores.

**Comandos recomendados:**

```bash
# Ver historial de commits (no interactivo)
git --no-pager log --oneline -10  # últimos 10 commits
git --no-pager log --oneline -5   # últimos 5 commits

# Ver diferencias (no interactivo)
git --no-pager diff
git --no-pager diff --staged

# Ver estado del repositorio
git status  # no usa paginador

# Otros comandos de consulta no interactivos
git --no-pager show HEAD
git --no-pager branch -v
```

**Configuración global opcional:**

```bash
# Deshabilitar el paginador para todos los comandos git (opcional)
git config --global pager.log false
git config --global pager.diff false
```

### 3.6. Solución de problemas comunes

#### Problema: `quote>` en git commit

**Síntoma:** al ejecutar `git commit -m "mensaje"` aparece `quote>` y el comando no termina.

**Causa:** error de escape de comillas en el mensaje de *commit*.

**Solución:** presiona Ctrl+C para cancelar el comando incompleto y usa el archivo temporal, que evita por completo los problemas de escape:

```bash
cat > /tmp/commit-msg.txt <<'EOF'
fix: correct "user" validation

- Validate user payload before persistence
- Keep login flow compatible with existing clients and
  preserve backward compatibility for existing callers
- Add explicit error handling for invalid identifiers

EOF
python3 ~/rules/scripts/commit_trailer.py >> /tmp/commit-msg.txt
git commit -F /tmp/commit-msg.txt
```

---

*Elaborado por Rodrigo Álvarez (@incognia)*
