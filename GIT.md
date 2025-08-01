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
git config --list | grep user
```

**Credenciales de plataforma:**
- **GitHub:** incognia
- **GitLab:** incognia
- **SSH Key:** `~/.ssh/id_ed25519`

### Proyectos laborales (Promad)
```bash
# Configurar usuario para este repositorio
git config user.name "Rodrigo Álvarez"
git config user.email "ralvarez@promad.com.mx"

# Verificar configuración
git config --list | grep user
```

**Credenciales de plataforma:**
- **GitHub:** incogniadev
- **GitLab:** incogniadev
- **SSH Key:** `~/.ssh/promad_ed25519`

## 3. Configuración de claves SSH (solo si es necesario)

### Verificar claves SSH existentes
```bash
# Listar claves SSH cargadas
ssh-add -l

# Si las claves no están cargadas, añadirlas:
ssh-add ~/.ssh/id_ed25519          # Para proyectos personales
ssh-add ~/.ssh/promad_ed25519      # Para proyectos laborales
```

### Probar conexión SSH
```bash
# Verificar conexión con GitHub
ssh -T git@github.com

# Verificar conexión con GitLab
ssh -T git@gitlab.com
```

## 4. Configuración de repositorio remoto

### Clonar repositorio existente
```bash
# Para proyectos personales
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519" git clone git@github.com:incognia/repo-name.git

# Para proyectos laborales
GIT_SSH_COMMAND="ssh -i ~/.ssh/promad_ed25519" git clone git@github.com:incogniadev/repo-name.git
```

### Inicializar nuevo repositorio
```bash
# Inicializar repositorio local
git init

# Añadir origen remoto (personal)
git remote add origin git@github.com:incognia/repo-name.git

# Añadir origen remoto (laboral)
git remote add origin git@github.com:incogniadev/repo-name.git

# Verificar configuración remota
git remote -v
```

## 5. Primer commit y push

```bash
# Añadir archivos
git add .

# Primer commit
git commit -m "feat: initial project setup"

# Push inicial (ver COMMITTING.md para comandos específicos por contexto)
```

---

**Próximo paso:** Una vez configurado el repositorio, consulta **[COMMITTING.md](./COMMITTING.md)** para el flujo de trabajo diario de commits y push.

---

*Elaborado por Rodrigo Álvarez (@incognia)*
