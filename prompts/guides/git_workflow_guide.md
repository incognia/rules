Guía rápida: flujo Git (SSH, no HTTPS)

Resumen
- Configura el repo con SSH por contexto (ver ~/rules/GIT.md, sección configuración inicial y asistente).
- Usa COMMITTING.md para el flujo diario: actualizar CHANGELOG (fecha CST), commit y push simple.

Pasos clave
1) Inicialización: `git init` y `bash scripts/git-init-context.sh`.
2) Verificación: `git config --list | grep ^user\.` y `git config core.sshCommand`.
3) Remoto: `git remote -v` (SSH), upstream en primer push: `git push -u origin main`.
4) Flujo diario: actualizar CHANGELOG, `git add`, `git commit -m` y `git push`.

