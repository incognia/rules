---
name: changelog
description: "Maintain CHANGELOG.md with correct CST dates, reverse chronological order, and Spanish Mexican language. Use this skill when updating the changelog."
---

# CHANGELOG.md maintenance

## When to use

When adding or updating entries in CHANGELOG.md for any project following rules conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/changelog.md` from line 1 to end
2. **Get CST date**: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")` — NEVER use UTC with "CST" suffix
3. **Check existing entries**: Verify if `## [YYYY-MM-DD]` already exists to avoid duplicate headings
4. **Update the target date block** (reverse chronological order):
   - **If the date already exists**: add new typed bullets inside that existing block; do NOT create a duplicate heading.
   - **If the date does not exist**: create `## [YYYY-MM-DD] - Título descriptivo breve` at the top and add typed bullets.
   - Base format:
     ```markdown
     ## [YYYY-MM-DD] - Título descriptivo breve

     - feat: descripción del cambio en español mexicano
     - docs: descripción adicional si aplica
     ```
5. **Language**: All entries in Spanish Mexican, no emojis
6. **Type in bullets**: Each bullet MUST start with `tipo:` and match valid commit types (`feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`, `perf`, `test`, `build`)
7. **Verify**: Check that the new entry is above all previous entries

## Critical rules

- Date format: `[YYYY-MM-DD]` only — no time component
- CST = UTC - 6 hours (verify with `TZ=America/Mexico_City date`)
- No emojis in CHANGELOG entries
- Descriptive title after the date: `## [YYYY-MM-DD] - Título descriptivo`
- Do NOT use subheadings like `### feat`/`### fix` inside a date entry

## Anti-error and anti-pattern protocol (MANDATORY)

1. Verify CST date and existing heading before editing (`TZ=America/Mexico_City date` + `grep -n "^## \[${DATE_CST}\]" CHANGELOG.md`).
2. Read the exact target date block before inserting bullets.
3. Apply minimal anchored edit only (preserve heading and existing lines intact).
4. Validate immediately with `git --no-pager diff -- CHANGELOG.md`.
5. Acceptance criterion: only added lines inside the target date block; no unexpected deletions.
6. If validation fails: do one minimal correction after re-reading the exact block.
7. If it fails again: stop and ask user confirmation before any further attempt.
8. Never chain 3+ consecutive attempts on CHANGELOG without an intermediate successful diff validation.

Forbidden anti-patterns:
- Reapplying the same failed anchor without adjusting to the real block content.
- Rewriting full `CHANGELOG.md` to insert a single bullet.
- Editing with ad-hoc scripts when a minimal anchored edit is sufficient.
- Continuing to commit flow when CHANGELOG diff acceptance criterion is not met.

## References

- Detailed CoT: `~/rules/cot/changelog.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
