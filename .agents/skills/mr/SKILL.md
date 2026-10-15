---
name: mr
description: "Abre un merge request en GitLab desde la rama actual, con título y descripción derivados de los commits reales y el revisor tomado del contexto de empresa en ~/rules/.env según el origin del repositorio. Invocación esperada: /mr [rama-destino] [draft]."
---

# Merge request en GitLab

## Cuándo usar

Cuando la rama de trabajo ya tiene sus *commits* (después de `/changelogger` y `/commit`) y hay que abrir el *merge request* para revisión, por ejemplo: `/mr`, `/mr main` o `/mr main draft`.

## Parámetros (opcionales)

- **Rama destino:** por omisión, la rama por defecto de `origin` (`git symbolic-ref refs/remotes/origin/HEAD`); si no se puede resolver, `main`.
- **`draft`:** abre el *merge request* como borrador (`--draft`).

## Contexto de empresa (`~/rules/.env`)

El revisor y la empresa **nunca** van en archivos versionados (este repositorio es público): se leen de `MR_CONTEXTS` en `~/rules/.env` (no versionado, modo 600; plantilla en `.env.example`).

```text
MR_CONTEXTS=<empresa>|<prefijo de origin>|<revisor>[+<revisor>...][,<empresa>|<prefijo>|<revisores>...]
```

- **`<prefijo de origin>`:** `host/grupo[/subgrupo]` normalizado, sin esquema, sin `git@` y sin `.git` (por ejemplo `gitlab.com/<grupo>`).
- **`<revisor>`:** *username* de GitLab, sin `@`; varios separados por `+`.
- Se usa el contexto cuyo prefijo coincide con el `origin` normalizado del repositorio; si coinciden varios, el más largo.

## Instrucciones

1. **Leer el contexto sin exponer el `.env`:** extraer solo `MR_CONTEXTS` (por ejemplo, `grep '^MR_CONTEXTS=' ~/rules/.env`), nunca imprimir el archivo completo ni otras llaves.
2. **Detectar la plataforma y el contexto:**
   - normalizar `git remote get-url origin` (`git@host:grupo/repo.git` y `https://host/grupo/repo.git` → `host/grupo/repo`);
   - si el *host* no es GitLab (`github.com` u otro), detenerse: esta *skill* solo abre *merge requests* con `glab`;
   - elegir el contexto por prefijo más largo; **si ninguno coincide, detenerse y pedir que se agregue a `MR_CONTEXTS`**, nunca adivinar el revisor.
3. **Validar el estado de la rama:**
   - la rama actual no es la rama destino;
   - árbol de trabajo limpio (si hay cambios, sugerir `/changelogger` y `/commit` primero);
   - hay *commits* respecto a `origin/<destino>` (`git fetch` antes de comparar); si no hay, detenerse;
   - si la rama no tiene *upstream*, publicarla con `git push -u origin <rama>`; si va adelantada, `git push`;
   - si ya existe un *merge request* abierto para la rama (`glab mr list --source-branch <rama>`), mostrar su liga y detenerse, sin duplicarlo.
4. **Respetar la política del repositorio:** si el `AGENTS.md` del repositorio define qué cambios van directo a la rama principal sin *merge request* (por ejemplo, solo documentación) y los archivos de la rama (`git diff --name-only origin/<destino>...HEAD`) caen todos en esa categoría, avisarlo y preguntar antes de abrir el *merge request*.
5. **Derivar título y descripción de los *commits* reales** (`git log origin/<destino>..HEAD`):
   - **título:** con un solo *commit*, su asunto tal cual; con varios, un asunto de Commits Convencionales que los resuma, en inglés internacional (UK), igual que los *commits*;
   - **descripción:** en el idioma principal del repositorio (la misma detección que `/changelogger`): qué hace, por qué y cómo se validó; fuente principal, las entradas nuevas del bloque del día de `CHANGELOG.md` y los cuerpos de los *commits*; nunca inventar validaciones que no ocurrieron;
   - si la herramienta o el entorno definen una línea de atribución para descripciones de *pull* o *merge request*, terminar la descripción con ella;
   - escribir la descripción en un archivo temporal y pasarla con `--description "$(cat <archivo>)"`.
6. **Crear el *merge request*:**

   ```bash
   glab mr create --source-branch <rama> --target-branch <destino> \
     --title "<título>" --description "$(cat <archivo>)" \
     --reviewer <revisor>[,<revisor>...] [--draft] --yes
   ```

7. **Verificar:** `glab mr view <iid>` muestra el estado abierto, la rama destino correcta y los revisores del contexto. Reportar la liga, el título y los revisores; no notificar por chat ni correo (eso lo decide el usuario).

## Reglas críticas

- El revisor y la empresa salen solo de `MR_CONTEXTS`; si falta el contexto, se detiene el flujo. Nunca copiar un revisor de otro repositorio, de un *merge request* anterior ni de estas reglas.
- Nunca imprimir, registrar ni versionar el contenido de `~/rules/.env`.
- Comandos no interactivos únicamente (`--yes`, descripción desde archivo); nunca editores.
- No fusionar ni aprobar el *merge request*: esta *skill* solo lo abre. La invocación `/mr` es la autorización para publicar la rama y abrirlo; ante cualquier advertencia (árbol sucio, rama sin *commits*, política del repositorio, contexto ambiguo), detenerse y preguntar.
- Título en inglés internacional (UK) y descripción en el idioma principal del repositorio; nunca mezclar idiomas dentro de la descripción.

## Referencias

- Flujo previo: `/changelogger` y `/commit` (`~/rules/cot/changelog.md`, `~/rules/cot/committing.md`)
- Detección de plataforma y proyecto desde `origin`: `/release` (`~/rules/cot/release.md`)
- Credenciales y datos sensibles: `~/rules/.env` (plantilla `.env.example`)
