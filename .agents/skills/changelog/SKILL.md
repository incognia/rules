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
3. **Check existing entries**: Verify the date doesn't already have an entry to avoid duplicates
4. **Add entry at the top** (reverse chronological order) using format:
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

## References

- Detailed CoT: `~/rules/cot/changelog.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
