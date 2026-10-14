# Configuración inicial de Git para nuevos repositorios

Este documento describe la configuración inicial necesaria al clonar o inicializar un nuevo repositorio, especificando los ajustes de usuario y las llaves SSH según el contexto del proyecto.

## 1. Identificación del contexto del proyecto

Antes de configurar, determina si el proyecto es:

- **Laboral:** Kabat One
- **Personal:** proyectos independientes o experimentales

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
- **Llave SSH:** `~/.ssh/incognia`

### Proyectos laborales (Kabat One)

```bash
# Configurar usuario para este repositorio
git config user.name "Rodrigo Álvarez"
git config user.email "ralvarez@kabatone.com"

# Verificar configuración
git config --list | grep ^user\.
```

**Credenciales de plataforma:**

- **GitHub:** incogniadev
- **GitLab:** incogniadev
- **Llave SSH:** `~/.ssh/kone`

## 3. Configuración inicial y SSH por contexto

Para que en el uso diario baste con un simple `git push` sin alias SSH y sin HTTPS, configura el repositorio al crearlo con el *script* incluido.

### 3.1. Uso del *script*

```bash
# Desde la raíz del repositorio (o desde la carpeta vacía que vas a inicializar)
bash ~/rules/scripts/git-init-context.sh <personal|laboral> [llave] [url_remota] [rama]

# Ejemplo
bash ~/rules/scripts/git-init-context.sh personal incognia git@github.com:incognia/REPO.git main
```

Recibe los mismos argumentos que el *skill* `/git-init`; sin argumentos, pregunta cada dato de forma interactiva. En el repositorio actual:

- Ejecuta `git init` si la carpeta todavía no es un repositorio.
- Configura `user.name` y `user.email` según el contexto.
- Configura `core.sshCommand` con la llave indicada (predeterminada: `~/.ssh/incognia` en personal y `~/.ssh/kone` en laboral).
- Define la rama predeterminada (`main` si no indicas otra).
- Configura `origin` si pasas una URL SSH (`git@…` o `ssh://…`); rechaza las URL HTTPS.

Al finalizar, podrás usar `git push` directamente.

### 3.2. Pasos manuales (si no usas el *script*)

```bash
# Elegir contexto
# Personal
git config user.name  "Rodrigo Álvarez"
git config user.email "incognia@gmail.com"
git config core.sshCommand "ssh -i ~/.ssh/incognia -o IdentitiesOnly=yes"

# Laboral (Kabat One)
# git config user.name  "Rodrigo Álvarez"
# git config user.email "ralvarez@kabatone.com"
# git config core.sshCommand "ssh -i ~/.ssh/kone -o IdentitiesOnly=yes"

# Configurar remoto SSH (ejemplos)
# GitHub personal:  git@github.com:incognia/REPO.git
# GitHub laboral:   git@github.com:incogniadev/REPO.git
# GitLab personal:  git@gitlab.com:incognia/REPO.git
# GitLab laboral:   git@gitlab.com:incogniadev/REPO.git

git remote add origin git@github.com:ORG/REPO.git

# Rama predeterminada: sin commits todavía usa symbolic-ref; con commits, branch -M
git symbolic-ref HEAD refs/heads/main
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
# Crear la carpeta y configurarla (el script ejecuta git init)
mkdir REPO && cd REPO
bash ~/rules/scripts/git-init-context.sh laboral kone git@gitlab.com:incogniadev/REPO.git main

# Verificar la configuración remota
git remote -v
```

## 5. Primer *commit* y *push*

El primer *commit* sigue el flujo normal de [COMMITTING.md](./COMMITTING.md): crea `CHANGELOG.md` con `/changelogger` y después ejecuta `/commit`, que agrega los cambios y hace el *commit* desde `/tmp/commit-msg.txt`.

```bash
# Primer commit (mensaje en /tmp/commit-msg.txt, nunca con -m)
git add -A
git commit -F /tmp/commit-msg.txt

# Push inicial con upstream
git push -u origin main
```

---

**Próximo paso:** una vez configurado el repositorio, consulta **[COMMITTING.md](./COMMITTING.md)** para el flujo de trabajo diario de *commits* y *push*.

---

*Elaborado por Rodrigo Álvarez (@incognia)*
