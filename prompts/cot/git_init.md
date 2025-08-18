---
domain: workflow
task: inicializar repo con Git y SSH (sin HTTPS) siguiendo GIT.md
Dificultad: baja
longitud_objetivo: corta
validacion: repo inicializado, identidad correcta, SSH forzado, remoto en SSH y primer push exitoso
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Evitar HTTPS y alias SSH; usar SSH con clave adecuada por repo (core.sshCommand).
- Configurar identidad (user.name, user.email) según contexto Personal/Laboral.
- Dejar la rama por defecto como main y remoto origin en formato SSH.
- Referencia principal: «~/rules/docs/GIT.md» (sección “Configuración inicial y SSH por contexto”).

Pasos (Opción recomendada: asistente interactivo):
1) Acción: inicializar el repositorio.
   Resultado: `git init`.
2) Acción: ejecutar el asistente de contexto.
   Resultado: `bash scripts/git-init-context.sh`.
   Nota: el asistente preguntará "Personal" o "Laboral", configurará user.name/user.email, core.sshCommand con la llave correcta y, opcionalmente, el remoto origin en SSH; también define main.
3) Acción: verificar identidad y SSH.
   Resultado:
   - `git config --list | grep ^user\.`
   - `git config core.sshCommand`
4) (Opcional) Acción: configurar origin si no lo hiciste en el asistente.
   Resultado (ejemplos):
   - GitHub personal: `git remote add origin git@github.com:incognia/REPO.git`
   - GitHub laboral: `git remote add origin git@github.com:incogniadev/REPO.git`
   - GitLab personal: `git remote add origin git@gitlab.com:incognia/REPO.git`
   - GitLab laboral: `git remote add origin git@gitlab.com:incogniadev/REPO.git`
   - Verificar: `git remote -v`.
5) Acción: primer commit no interactivo.
   Resultado:
   - `git add .`
   - `git commit -m "feat: initial project setup"`
6) Acción: primer push y upstream.
   Resultado: `git push -u origin main`.

Pasos (Alternativa manual, si no usas el asistente):
1) `git init`
2) Elegir contexto y configurar identidad + SSH:
   - Personal:
     - `git config user.name  "Rodrigo Álvarez"`
     - `git config user.email "incognia@gmail.com"`
     - `git config core.sshCommand "ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes"`
   - Laboral (Promad):
     - `git config user.name  "Rodrigo Álvarez"`
     - `git config user.email "ralvarez@promad.com.mx"`
     - `git config core.sshCommand "ssh -i ~/.ssh/promad_ed25519 -o IdentitiesOnly=yes"`
3) Configurar remoto en SSH (ver ejemplos arriba) y verificar con `git remote -v`.
4) Definir rama por defecto: `git branch -M main`.
5) Commit y primer push como en los pasos 5-6 de la opción recomendada.

Conclusión:
- Tras la configuración inicial, el flujo diario usa push simple: `git push`.
- Referencias: «~/rules/docs/GIT.md» ([../../docs/GIT.md](../../docs/GIT.md)) y «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)).

