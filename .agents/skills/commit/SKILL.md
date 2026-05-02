---
name: commit
description: "Full commit workflow with mandatory CHANGELOG update, SSH validation, and conventional commits in English. Use this skill before making any git commit."
---

# Commit workflow

## When to use

Before making any git commit in projects that follow the rules repository conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/committing.md` from line 1 to end
2. **Validate identity (first time in session only)**: If you already validated identity in this conversation session, skip to step 3. Otherwise: run `git config --list | grep ^user\.` and `git remote -v`, verify email/name match expected context and remote uses SSH (not HTTPS).
3. **Get CST date**: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`
4. **Update CHANGELOG.md FIRST** — seguir este procedimiento exacto:

   a. Verificar si ya existe entrada para la fecha de hoy:
      ```bash
      grep -n "^## \[${DATE_CST}\]" CHANGELOG.md
      ```
      - **Si YA existe**: agregar nuevos bullets DENTRO de esa entrada. NO crear encabezado nuevo.
      - **Si NO existe**: crear `## [YYYY-MM-DD] - Título descriptivo` al tope del archivo.

   b. **Técnica de edición con `edit_files` (OBLIGATORIA)** — Regla de oro:
      - El `search` es SOLO la línea ancla (el encabezado `## [FECHA]` o la última línea conocida).
      - El `replace` reproduce esa línea ancla INTACTA y añade el contenido nuevo.
      - NUNCA incluir en `search` una línea que luego se reproduzca en `replace` — eso duplica contenido.
      - Para insertar bullets al tope de una entrada existente:
        ```
        search:  "## [2026-04-30] - Título actual"
        replace: "## [2026-04-30] - Título actualizado\n\n- nuevo bullet"
        ```
        Las líneas que siguen quedan fuera del `search` y permanecen intactas.

   c. Orden cronológico inverso: entradas más recientes siempre arriba.

   d. Idioma: español mexicano en el CHANGELOG, inglés internacional en el mensaje de commit.

5. **Stage files**: `git add .`
6. **Build commit message in temporary file**: create `/tmp/commit-msg.txt` using this detailed structure (English international):
   ```text
   type(scope): short summary in english
   
   - Detail 1 in english
   - Detail 2 in english that wraps to another line
     aligned with the bullet text (continuation line)
   - Detail 3 in english

   Co-Authored-By: Oz <oz-agent@warp.dev>
   ```
   **Mandatory formatting rules for bullets and long lines:**
   - Bullet marker `-` MUST start at column 1 (no leading spaces or tabs before `-`).
   - If a bullet is too long, split it manually into a new line.
   - Continuation lines MUST be indented with two spaces so text stays aligned with the bullet content.
   - Keep exactly one blank line between subject/body and body/footer.
   Reuse and adjust `/tmp/commit-msg.txt` until the wording is final.
7. **Commit from file**: `git commit -F /tmp/commit-msg.txt` — message MUST be in English international, following Conventional Commits
8. **Push**: `git push`
9. **Verify**: `git --no-pager log --oneline -1`

## Rules

- CHANGELOG.md is ALWAYS updated BEFORE the commit — never after
- Commit messages are ALWAYS in English international
- Use non-interactive commands only (no pagers, no editors)
- Prefer `git commit -F /tmp/commit-msg.txt` over `git commit -m` to keep detailed, reusable commit messages
- In `/tmp/commit-msg.txt`, keep bullets left-aligned and wrap long lines with aligned continuation indentation
- CoT files classify as `feat:` not `docs:`

## References

- Detailed CoT: `~/rules/cot/committing.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
- Git config: `~/rules/rulesets/GIT.md`
