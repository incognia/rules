---
domain: workflow
task: inicializar repo con Git y SSH (sin HTTPS) siguiendo GIT.md
dificultad: baja
longitud_objetivo: corta
validacion: repo inicializado, identidad correcta, SSH forzado, remoto en SSH y primer push exitoso
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Evitar HTTPS y alias SSH; usar SSH con la llave adecuada por repositorio (`core.sshCommand`).
- Configurar identidad (`user.name`, `user.email`) según el contexto personal o laboral.
- Dejar la rama predeterminada como `main` (o la indicada) y el remoto `origin` en formato SSH.
- El *script* `~/rules/scripts/git-init-context.sh` hace todo esto y recibe los mismos argumentos que el *skill* `/git-init`: `<personal|laboral> [llave] [url_remota] [rama]`.
- Referencia principal: «~/rules/rulesets/GIT.md» (sección «Configuración inicial y SSH por contexto»).

Pasos (opción recomendada: *script* no interactivo):

1) Acción: ubicarse en la raíz del repositorio, o en la carpeta vacía que se va a inicializar.
   Resultado: el *script* ejecuta `git init` si la carpeta todavía no es un repositorio, y se niega a correr desde una subcarpeta.
2) Acción: ejecutar el *script* con argumentos.
   Resultado:
   - Personal: `bash ~/rules/scripts/git-init-context.sh personal incognia git@github.com:incognia/REPO.git main`
   - Laboral: `bash ~/rules/scripts/git-init-context.sh laboral kone git@gitlab.com:incogniadev/REPO.git main`
   - Llave predeterminada: `incognia` (personal) o `kone` (laboral); rama predeterminada: `main`; la URL remota es opcional y debe ser SSH (`git@…` o `ssh://…`).
   Nota: sin argumentos el *script* es interactivo; un agente siempre debe pasarle al menos el contexto.
3) Acción: revisar el bloque `=== CONFIGURATION ===` que imprime el *script*.
   Resultado: identidad, `core.sshCommand`, remoto y rama correctos. Si avisa que la llave no existe, revisar `ls ~/.ssh/` y repetir con la llave correcta.
4) Acción: primer *commit* no interactivo, siguiendo el flujo normal.
   Resultado: crear `CHANGELOG.md` con `/changelogger` y después aplicar `/commit` (o «~/rules/cot/committing.md»), que construye `/tmp/commit-msg.txt` y hace `git commit -F /tmp/commit-msg.txt`.
5) Acción: primer *push* con *upstream*.
   Resultado: `git push -u origin main` (o la rama elegida).

Pasos (alternativa manual, si no usas el *script*):

1) `git init`
2) Elegir contexto y configurar identidad y SSH:
   - Personal:
     - `git config user.name  "Rodrigo Álvarez"`
     - `git config user.email "incognia@gmail.com"`
     - `git config core.sshCommand "ssh -i ~/.ssh/incognia -o IdentitiesOnly=yes"`
   - Laboral (Kabat One):
     - `git config user.name  "Rodrigo Álvarez"`
     - `git config user.email "ralvarez@kabatone.com"`
     - `git config core.sshCommand "ssh -i ~/.ssh/kone -o IdentitiesOnly=yes"`
3) Configurar el remoto en SSH y verificar con `git remote -v`:
   - GitHub personal: `git remote add origin git@github.com:incognia/REPO.git`
   - GitHub laboral: `git remote add origin git@github.com:incogniadev/REPO.git`
   - GitLab personal: `git remote add origin git@gitlab.com:incognia/REPO.git`
   - GitLab laboral: `git remote add origin git@gitlab.com:incogniadev/REPO.git`
4) Definir la rama predeterminada: `git symbolic-ref HEAD refs/heads/main` si aún no hay *commits*, o `git branch -M main` si ya los hay.
5) *Commit* y primer *push* como en los pasos 4 y 5 de la opción recomendada.

Conclusión:

- Tras la configuración inicial, el flujo diario usa *push* simple: `git push`.
- Referencias: «~/rules/rulesets/GIT.md» ([../rulesets/GIT.md](../rulesets/GIT.md)) y «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md)).
