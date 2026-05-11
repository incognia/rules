---
name: changelogger
description: "Maintain CHANGELOG.md with correct CST dates, reverse chronological order, and Spanish Mexican language. Use this skill when updating the changelog."
---

# CHANGELOG.md maintenance

## When to use

When adding or updating entries in CHANGELOG.md for any project following rules conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/changelog.md` from line 1 to end
2. **First execution step + hard stop (MANDATORY)**: read `CHANGELOG.md` lines `1-200` before any `grep`, search loop, or patch attempt.
   If this exact read has not been executed in the current run, HARD STOP immediately, restart from this step, and do absolutely nothing else (no `grep`, search, date calculation, anchor calculation, diff, or patch).
3. **Get CST date**: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")` — NEVER use UTC with "CST" suffix
4. **Check existing entries**: Verify if `## [YYYY-MM-DD]` already exists to avoid duplicate headings
5. **Update the target date block** (reverse chronological order):
   - **If the date already exists**: add new typed bullets inside that existing block; do NOT create a duplicate heading.
   - **First-attempt rule (MANDATORY)**: for an existing date block, the first attempt MUST use one single-hunk micro-block replacement with exact `search` = `## [YYYY-MM-DD] - ...` + immediate blank line + first existing bullet.
   - **Insertion rule (MANDATORY)**: in that same hunk, reproduce the heading and blank line intact, then insert the new bullet above the previous first bullet.
   - **No intra-block blank line (MANDATORY)**: keep bullets contiguous inside the same date block; never add an empty line between bullets of that block.
   - **If the date does not exist**: create `## [YYYY-MM-DD] - Título descriptivo breve` at the top and add typed bullets.
   - **Spacing rule (MANDATORY)**: keep exactly one blank line between the last bullet of the target date block and the next `## [YYYY-MM-DD]` heading.
   - **Fallback rule (MANDATORY, new date only)**: if insertion preview still shows no blank separator line after creating a new date block, switch immediately to a two-hunk edit (first hunk inserts the new block, second hunk enforces `blank line + next heading`).
   - Base format:
     ```markdown
     ## [YYYY-MM-DD] - Título descriptivo breve

     - feat: descripción del cambio en español mexicano
     - docs: descripción adicional si aplica
     ```
6. **Language**: All entries in Spanish Mexican, no emojis
7. **Type in bullets**: Each bullet MUST start with `tipo:` and match valid commit types (`feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`, `perf`, `test`, `build`)
8. **Verify**: Check that the new entry is above all previous entries

## Critical rules

- Date format: `[YYYY-MM-DD]` only — no time component
- CST = UTC - 6 hours (verify with `TZ=America/Mexico_City date`)
- No emojis in CHANGELOG entries
- Descriptive title after the date: `## [YYYY-MM-DD] - Título descriptivo`
- Do NOT use subheadings like `### feat`/`### fix` inside a date entry
- Keep exactly one blank line between consecutive date blocks (`## [YYYY-MM-DD]`)
- Keep bullets contiguous within the same date block (no blank lines between bullets)
- Incremental mode is insert-only by default: only `+` additions are allowed; deleting existing `CHANGELOG.md` lines requires explicit user instruction
- HARD STOP absolute: if the initial precise read of `CHANGELOG.md` lines `1-200` is missing in the current run, stop and restart from instruction 2; no other action is allowed
- NEVER edit entries from dates different than `DATE_CST` (current day) unless explicitly instructed by the user

## Anti-error and anti-pattern protocol (MANDATORY)

1. Read `CHANGELOG.md` lines `1-200` as the first operation of the run (before `grep`, extra search, or patch attempts).
2. HARD STOP gate: if there is no explicit evidence that step 1 happened in the current run, stop immediately and restart from step 1; absolutely no further action is allowed.
3. Verify CST date and existing heading before editing (`TZ=America/Mexico_City date` + `grep -n "^## \\[${DATE_CST}\\]" CHANGELOG.md`).
4. Read the exact target date block before inserting bullets.
5. If `DATE_CST` heading exists, first attempt MUST be one single-hunk micro-block replacement (`heading + blank line + first bullet`) and insertion of the new bullet at top of the block (no blank line between bullets).
6. Validate immediately with `git --no-pager diff -- CHANGELOG.md`.
7. Acceptance criterion: insertion-only diff inside the target date block (only `+` lines); any deleted line (`-`) invalidates the attempt unless the user explicitly requested deletion.
8. If validation fails: do one minimal correction after re-reading the exact block.
9. If creating a new date block and blank separator line is missing, apply mandatory two-hunk fallback:
   - Hunk 1: insert the new date block above the next date heading.
   - Hunk 2: anchor on the next heading and replace with `blank line + same heading` to force spacing.
10. If validation shows changes outside the target date block: stop and ask user confirmation; do NOT auto-correct historical entries.
11. If it fails again: stop and ask user confirmation before any further attempt.
12. Never chain 3+ consecutive attempts on CHANGELOG without an intermediate successful diff validation.
13. For existing-date insertion, NEVER anchor the edit from `# Registro de cambios` or any file-top replacement; anchor only on `heading + blank line + first bullet`.
14. If an insertion-only attempt shows any deleted line (`-`) anywhere in `CHANGELOG.md`, abort that patch and rebuild the anchor before retrying; deletions are allowed only with explicit user instruction.

Forbidden anti-patterns:
- Continuing the run without explicit evidence that `CHANGELOG.md` lines `1-200` were read in the current execution.
- Attempting to recover mid-run after skipping step 0 instead of hard-stopping and restarting from step 0.
- Starting with `grep`, search loops, or patch attempts before reading `CHANGELOG.md` lines `1-200`.
- Reapplying the same failed anchor without adjusting to the real block content.
- Using partial anchors for existing-date insertion (e.g., only the heading line).
- Using `search = heading + first bullet` without the required blank line between them for existing-date insertion.
- Rewriting full `CHANGELOG.md` to insert a single bullet.
- Editing with ad-hoc scripts when a minimal anchored edit is sufficient.
- Adding an empty line between bullets inside the same date block.
- Omitting the required blank line between consecutive date blocks.
- Repeating the same failed `+6` insertion attempt without switching to two-hunk fallback.
- Repeating discovery/search loops after the target date block is already identified.
- Editing entries outside the current day block (`DATE_CST`) without explicit user instruction.
- Continuing to commit flow when CHANGELOG diff acceptance criterion is not met.
- Anchoring an existing-date insertion from `# Registro de cambios` or replacing the file-top section instead of the micro-block anchor.
- Accepting a patch that deletes separator blank lines when the goal is only to prepend bullets in the current-day block.
- Deleting any existing `CHANGELOG.md` line during incremental insertion without explicit user instruction.

## References

- Detailed CoT: `~/rules/cot/changelog.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
