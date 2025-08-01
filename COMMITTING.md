# Reglas de mensajes de *commit* y gestión de cambios

## 1. Filosofía principal

Un historial de *commits* bien estructurado es una de las herramientas más valiosas para la facilidad de mantenimiento de un proyecto. Cada *commit* debe ser atómico, tener un propósito claro y un mensaje que lo describa de forma concisa.

## 2. Formato del mensaje de *commit*

Utilizar la especificación de [Commits Convencionales](https://www.conventionalcommits.org/en/v1.0.0/).

### 2.1. Estructura general

```
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

### 2.3. Reglas del mensaje

- **Idioma:** redactar siempre en **inglés internacional**.
- **Emojis:** no usar emojis.
- **Descripción:** debe ser concisa, en imperativo y en minúsculas (ej. `fix: correct user login flow`).
- **Cuerpo:** opcional, para explicar el *qué* y el *porqué* del cambio.
- **Pie:** opcional, para referencias a *issues* (`Refs: #123`) o para marcar cambios incompatibles (`BREAKING CHANGE:`).

### 2.4. Ejemplos

#### Bueno

```
feat(auth): add password reset functionality

Implement the password reset feature using a token-based system.
Users will receive an email with a secure link to reset their password.

Fixes: #42
```

#### Malo

```
fix
```

```
Updated files
```

## 3. Flujo de trabajo y gestión de cambios

### 3.1. Actualización del `CHANGELOG.md` (CRÍTICO)

🔥 **REGLA CRÍTICA: SIEMPRE actualizar el archivo `CHANGELOG.md` ANTES de cada *commit*.**

**PROCESO OBLIGATORIO:**
1. **PRIMERO:** Actualizar `CHANGELOG.md` con los cambios realizados
2. **SEGUNDO:** Hacer `git add` de todos los archivos (incluyendo CHANGELOG.md)
3. **TERCERO:** Hacer `git commit`
4. **CUARTO:** Hacer `git push`

**⚠️ ADVERTENCIA:** Nunca hacer commit sin haber actualizado primero el CHANGELOG.md. Esta es una regla fundamental del flujo de trabajo.

**Especificaciones del CHANGELOG.md:**
- **Idioma:** el idioma oficial del proyecto (generalmente español mexicano)
- **Zona horaria:** usar **CST de Ciudad de México (UTC-6)** para todas las fechas. Nunca usar UTC ni la zona horaria local del sistema
- **Formato de fecha:** usar únicamente fecha sin hora en formato `[YYYY-MM-DD]` según CST Ciudad de México. La hora NO debe incluirse
- **Contenido mínimo:**
  - Fecha del cambio en formato `[YYYY-MM-DD]` según CST Ciudad de México
  - Tipo de cambio (coincidente con el prefijo del *commit*)
  - Breve descripción del cambio

**Ejemplo del flujo correcto:**
```bash
# 1. PRIMERO: Editar CHANGELOG.md
vim CHANGELOG.md

# 2. SEGUNDO: Añadir archivos
git add .

# 3. TERCERO: Commit
git commit -m "tipo: descripción del cambio"

# 4. CUARTO: Push
GIT_SSH_COMMAND="ssh -i ~/.ssh/clave" git push origin main
```

### 3.2. Atomicidad de los *commits*

- **Un propósito por *commit*:** cada *commit* debe reflejar un cambio único y funcional. No mezclar correcciones de errores con nuevas funcionalidades en el mismo *commit*.
- **Cambios pequeños:** dividir los cambios grandes en *commits* más pequeños y lógicos.

### 3.3. Asociación con tareas

- **Referencia a *issues*:** siempre que sea posible, asociar los *commits* con su *issue*, *ticket* o tarea correspondiente en el pie del mensaje (`Refs: #123`, `Closes: #123`).

### 3.4. Comandos de push por contexto

El comando de push debe usar la clave SSH correspondiente al contexto del proyecto:

#### Proyectos personales (`@incognia`)
```bash
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519" git push origin main
```

#### Proyectos laborales (`@incogniadev` - Promad)
```bash
GIT_SSH_COMMAND="ssh -i ~/.ssh/promad_ed25519" git push origin main
```

**Nota importante:** Verificar que la configuración de Git del repositorio sea correcta (ver [GIT.md](./GIT.md) para configuración inicial):
```bash
git config --list | grep user
```

---

*Elaborado por Rodrigo Álvarez (@incognia)*

