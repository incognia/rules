---
domain: release
task: preparar y publicar una versión
impacto: alto
validacion: tag creado, changelog actualizado, push realizado
---

Checklist
1) Revisar CHANGELOG y completar entradas pendientes (fecha CST, ver ~/rules/COMMITTING.md).
2) Versionar (si aplica): actualizar archivos de versión.
3) Commit: `git add -A && git commit -m "chore(release): prepare vX.Y.Z"`.
4) Tag: `git tag -a vX.Y.Z -m "release: vX.Y.Z"`.
5) Push: `git push && git push --tags`.
6) Crear release en la forja (si aplica) y adjuntar notas basadas en CHANGELOG.

