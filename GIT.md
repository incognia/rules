# Configuración Inicial de Git para Github y GitLab

Este documento describe los pasos necesarios para configurar tus cuentas de GitHub y GitLab para proyectos personales y laborales, especificando los ajustes de usuario y las llaves SSH a utilizar.

## 1. Configuración de Usuario

### Proyectos Personales
- **User Name:** Rodrigo Álvarez
- **Email:** incognia@gmail.com
- **GitHub Username:** incognia
- **GitLab Username:** incognia
- **Clave SSH:** `~/.ssh/id_ed25519`

#### Comandos:
```bash
git config --global user.name "Rodrigo Álvarez"
git config --global user.email "incognia@gmail.com"
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519"
```

### Proyectos Laborales (Promad)
- **User Name:** Rodrigo Álvarez
- **Email:** ralvarez@promad.com.mx
- **GitHub Username:** incogniadev
- **GitLab Username:** incogniadev
- **Clave SSH:** `~/.ssh/promad_ed25519`

#### Comandos:
```bash
git config --global user.name "Rodrigo Álvarez"
git config --global user.email "ralvarez@promad.com.mx"
GIT_SSH_COMMAND="ssh -i ~/.ssh/promad_ed25519"
```

## 2. Uso de las Claves SSH

Configura tus claves SSH para autenticación en ambas plataformas (GitHub y GitLab):

### Añadir claves SSH
- **Personal:**
```bash
ssh-add ~/.ssh/id_ed25519
```
- **Laboral:**
```bash
ssh-add ~/.ssh/promad_ed25519
```

Confirma que las claves SSH están correctamente añadidas:
```bash
ssh-add -l
```

### Verificar la configuración de las claves SSH
Realiza un `ssh -T` para verificar la conexión a GitHub y GitLab:
- **Personal:**
```bash
ssh -T git@github.com
ssh -T git@gitlab.com
```
- **Laboral:**
```bash
ssh -T git@github.com
ssh -T git@gitlab.com
```

Este documento asegura que estén configuradas correctamente tus cuentas y claves para el trabajo diario, evitando problemas de autenticación y facilitando el uso correcto de las políticas definidas en COMMITTING.md.
