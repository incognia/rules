# Configuración inicial de Git para nuevos repositorios

Este documento describe la configuración inicial necesaria al clonar o inicializar un nuevo repositorio, especificando los ajustes de usuario y las llaves SSH según el contexto del proyecto.

## 1. Identificación del contexto del proyecto

Antes de configurar, determina si el proyecto es:

- 💼 **Laboral:** Promad Business Solutions
- 📺 **Personal:** Proyectos independientes o experimentales

## 2. Configuración local del repositorio

### Proyectos personales

```bash
# Configurar usuario para este repositorio
git config user.name "Rodrigo Álvarez"
git config user.email "incognia@gmail.com"

# Verificar configuración
git config --list | grep ^user\.
```

**Credenciales de plataforma:**
- **GitHub:** incognia
- **GitLab:** incognia
- **SSH Key:** `~/.ssh/incognia`

### Proyectos laborales (Promad)

```bash
# Configurar usuario para este repositorio
git config user.name "Rodrigo Álvarez"
git config user.email "ralvarez@promad.com.mx"

# Verificar configuración
git config --list | grep ^user\.
```

**Credenciales de plataforma:**

- **GitHub:** incogniadev
- **GitLab:** incogniadev
- **SSH Key:** `~/.ssh/promad_ed25519`

## 3. Configuración inicial y SSH por contexto

Para que en el uso diario baste con un simple `git push` sin alias SSH y sin HTTPS, configura el repositorio justo después de `git init` usando el script interactivo incluido.

### 3.1. Uso del script interactivo

```bash
# Tras inicializar el repo
git init

# Ejecutar el asistente
bash scripts/git-init-context.sh
```

El asistente te preguntará si el repositorio es Personal o Laboral y hará lo siguiente por ti en el repositorio actual:

- Configurará `user.name` y `user.email`.
- Configurará `core.sshCommand` para usar la clave adecuada con `ssh -i` (SSH, no HTTPS).
- Opcionalmente configurará `origin` con una URL SSH (`git@github.com:ORG/REPO.git` o `git@gitlab.com:ORG/REPO.git`).
- Definirá `main` como rama por defecto si aún no existe.

Al finalizar, podrás usar `git push` directamente.

### 3.2. Pasos manuales (si no usas el script)

```bash
# Elegir contexto
# Personal
git config user.name  "Rodrigo Álvarez"
git config user.email "incognia@gmail.com"
git config core.sshCommand "ssh -i ~/.ssh/incognia -o IdentitiesOnly=yes"

# Laboral (Promad)
# git config user.name  "Rodrigo Álvarez"
# git config user.email "ralvarez@promad.com.mx"
# git config core.sshCommand "ssh -i ~/.ssh/promad_ed25519 -o IdentitiesOnly=yes"

# Configurar remoto SSH (ejemplos)
# GitHub personal:  git@github.com:incognia/REPO.git
# GitHub laboral:   git@github.com:incogniadev/REPO.git
# GitLab personal:  git@gitlab.com:incognia/REPO.git
# GitLab laboral:   git@gitlab.com:incogniadev/REPO.git

git remote add origin git@github.com:ORG/REPO.git

git branch -M main
```

### 3.3. Probar conexión SSH

```bash
ssh -T git@github.com || true
ssh -T git@gitlab.com || true
```

## 4. Clonar o inicializar repositorios

### Clonar repositorio existente (SSH siempre)

```bash
git clone git@github.com:incognia/repo-name.git              # Personal GitHub
git clone git@github.com:incogniadev/repo-name.git           # Laboral GitHub

git clone git@gitlab.com:incognia/repo-name.git              # Personal GitLab
git clone git@gitlab.com:incogniadev/repo-name.git           # Laboral GitLab
```

### Inicializar nuevo repositorio

```bash
# Inicializar repositorio local y ejecutar el asistente
git init
bash scripts/git-init-context.sh

# Verificar configuración remota (si se configuró)
git remote -v || true

# Si deseas tener el script disponible globalmente:
# install -Dm755 scripts/git-init-context.sh ~/.local/bin/git-init-context
# Luego: git init && git-init-context
```

## 5. Primer commit y push

```bash
# Añadir archivos
git add .

# Primer commit
git commit -m "feat: initial project setup"

# Push inicial
git push -u origin main
```

---

**Próximo paso:** Una vez configurado el repositorio, consulta **[COMMITTING.md](./COMMITTING.md)** para el flujo de trabajo diario de commits y push.

---

*Elaborado por Rodrigo Álvarez (@incognia)*
