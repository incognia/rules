# Reglas de mensajes de *commit* y gestión de cambios

## 1. Filosofía principal

Un historial de *commits* bien estructurado es una de las herramientas más valiosas para la facilidad de mantenimiento de un proyecto. Cada *commit* debe ser atómico, tener un propósito claro y un mensaje que lo describa de forma concisa.

## 2. Formato del mensaje de *commit*

Utilizar la especificación de [Commits Convencionales](https://www.conventionalcommits.org/en/v1.0.0/).

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
- **style:** cambios que no afectan el significado del código (espacios, formato, etc.).
- **refactor:** una reestructuración de código que no corrige un error ni añade una funcionalidad.
- **perf:** una mejora de rendimiento.
- **test:** añadir o corregir pruebas.
- **build:** cambios que afectan al sistema de *build* o a dependencias externas.
- **ci:** cambios en los archivos y scripts de configuración de CI.
- **chore:** otros cambios que no modifican el código fuente ni las pruebas (ej. actualización de dependencias).

**⚠️ IMPORTANTE:** Los archivos CoT (Chain of Thought) como `cot/committing.md` son documentos funcionales que definen workflows automatizados. Se clasifican como **`feat:`** (no `docs:`), ya que representan nueva funcionalidad y automatización del proyecto, no simple documentación.

### 2.3. Reglas del mensaje

- **Idioma:** redactar siempre en **inglés internacional**.
- **Emojis:** no usar emojis.
- **Descripción:** debe ser concisa, en imperativo y en minúsculas (ej. `fix: correct user login flow`).
- **Cuerpo:** opcional, para explicar el *qué* y el *porqué* del cambio.
- **Pie:** opcional, para referencias a *issues* (`Refs: #123`) o para marcar cambios incompatibles (`BREAKING CHANGE:`).

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

## 3. Flujo de trabajo y gestión de cambios

### 3.1. Actualización del `CHANGELOG.md` (CRÍTICO)

🔥 **REGLA CRÍTICA: SIEMPRE actualizar el archivo `CHANGELOG.md` ANTES de cada *commit*.**

**PROCESO OBLIGATORIO:**
1. **PRIMERO:** Actualizar `CHANGELOG.md` con los cambios realizados
1. **SEGUNDO:** Hacer `git add` de todos los archivos (incluyendo CHANGELOG.md)
1. **TERCERO:** Hacer `git commit`
1. **CUARTO:** Hacer `git push`

**⚠️ ADVERTENCIA:** Nunca hacer commit sin haber actualizado primero el CHANGELOG.md. Esta es una regla fundamental del flujo de trabajo.

**Especificaciones del CHANGELOG.md:**
- **Idioma:** el idioma oficial del proyecto (generalmente español mexicano)
- **Zona horaria:** usar **CST de Ciudad de México (UTC-6)** para todas las fechas. Nunca usar UTC ni la zona horaria local del sistema
- **Formato de fecha:** usar únicamente fecha sin hora en formato `[YYYY-MM-DD]` según CST Ciudad de México. La hora NO debe incluirse
- **Título descriptivo:** usar el formato `## [YYYY-MM-DD] - Título descriptivo del cambio principal` para los encabezados de sección
- **⚠️ IMPORTANTE: NO usar emojis en las entradas del CHANGELOG.md** - mantener el contenido limpio y profesional usando únicamente texto

⚠️ **ADVERTENCIA CRÍTICA:** Para obtener la fecha CST correcta, NO es suficiente añadir "CST" a una fecha UTC. Debes convertir la fecha restando 6 horas a UTC o usar `TZ="America/Mexico_City" date +"%Y-%m-%d"` para la conversión automática.

**Comandos recomendados (siempre correctos):**

```bash
# Fecha en CST (Ciudad de México), independiente de la TZ del sistema
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
echo "$DATE_CST"
```

- **Contenido mínimo:**
  - Fecha del cambio en formato `[YYYY-MM-DD]` según CST Ciudad de México (UTC-6, NO UTC con sufijo CST)
  - Tipo de cambio (coincidente con el prefijo del *commit*)
  - Breve descripción del cambio

**Ejemplo del flujo correcto:**

```bash
# 1. PRIMERO: Actualizar CHANGELOG.md con fecha CST
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
# Opción A (manual): abrir editor
vim CHANGELOG.md
# Opción B (no interactiva): anteponer una línea de ejemplo (ajusta el tipo y descripción)
# Nota: reemplaza "docs" y la descripción según corresponda
printf "[%s] docs: describe el cambio\n" "$DATE_CST" | cat - CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md

# 2. SEGUNDO: Añadir archivos
git add .

# 3. TERCERO: Commit (no interactivo)
git commit -m "docs(changelog): update entry for $DATE_CST"

# 4. CUARTO: Push (una vez configurado el repo, basta con un push simple)
git push

# 5. VERIFICACIÓN: Ver los últimos commits (no interactivo)
git --no-pager log --oneline -5
```

### 3.2. Atomicidad de los *commits*

- **Un propósito por *commit*:** cada *commit* debe reflejar un cambio único y funcional. No mezclar correcciones de errores con nuevas funcionalidades en el mismo *commit*.
- **Cambios pequeños:** dividir los cambios grandes en *commits* más pequeños y lógicos.

### 3.3. Asociación con tareas

- **Referencia a *issues*:** siempre que sea posible, asociar los *commits* con su *issue*, *ticket* o tarea correspondiente en el pie del mensaje (`Refs: #123`, `Closes: #123`).

### 3.4. Push simplificado

Si el repositorio está configurado correctamente (identidad y SSH), el comando de envío es simplemente:

```bash
git push
```

Para la primera configuración (elegir entre credenciales personales o laborales) consulta [GIT.md](./GIT.md#configuración-inicial-y-ssh-por-contexto).

**Nota:** Puedes verificar rápidamente la identidad activa del repositorio:

```bash
git config --list | grep ^user\.
```

### 3.5. Comandos git no interactivos

**⚠️ IMPORTANTE:** Siempre usar comandos no interactivos para evitar paginadores y editores.

**Comandos recomendados:**

```bash
# Ver historial de commits (no interactivo)
git --no-pager log --oneline -10  # últimos 10 commits
git --no-pager log --oneline -5   # últimos 5 commits
git log -n 5                      # alternativa sin pager

# Ver diferencias (no interactivo)
git --no-pager diff
git --no-pager diff --staged

# Ver estado del repositorio
git status  # ya es no interactivo por defecto

# Otros comandos de consulta no interactivos
git --no-pager show HEAD
git --no-pager branch -v
```

**Configuración global opcional:**

```bash
# Deshabilitar pager para todos los comandos git (opcional)
git config --global pager.log false
git config --global pager.diff false
```

### 3.6. Solución de problemas comunes

#### Problema: `quote>` en git commit

**Síntoma:** Al ejecutar `git commit -m "mensaje"` aparece `quote>` y el comando no termina.

**Causa:** Error de escape de comillas en el mensaje de commit.

**Soluciones:**

1. **Escapar comillas correctamente:**
   ```bash
   # MAL: comillas dobles dentro de comillas dobles sin escapar
   git commit -m "fix: correct "user" validation"
   
   # BIEN: escapar comillas internas
   git commit -m "fix: correct \"user\" validation"
   
   # MEJOR: usar comillas simples para el mensaje
   git commit -m 'fix: correct "user" validation'
   ```

2. **Cancelar el prompt `quote>` si aparece:**
   ```bash
   # Presionar Ctrl+C para cancelar el comando incompleto
   # Luego reescribir el mensaje correctamente
   ```

3. **Alternativa segura: usar archivo temporal:**
   ```bash
   echo "fix: correct user validation" > /tmp/commit_msg
   git commit -F /tmp/commit_msg
   rm /tmp/commit_msg
   ```

**Prevención:**
- Evitar comillas dobles dentro de mensajes entre comillas dobles
- Preferir comillas simples para mensajes que contengan comillas dobles
- Verificar balance de comillas antes de ejecutar el comando

---

*Elaborado por Rodrigo Álvarez (@incognia)*

