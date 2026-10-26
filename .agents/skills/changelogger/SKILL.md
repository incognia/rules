---
name: changelogger
description: "Maintain CHANGELOG.md with correct CST dates, reverse chronological order, and the repository's primary language: Spanish Mexican or international English (UK). Use this skill when updating the changelog."
context: fork
agent: general-purpose
model: claude-sonnet-5-5
background: false
---

# CHANGELOG.md maintenance

> **Execution (Claude Code):** this skill runs in a forked subagent on Claude Sonnet 5.5 (`context: fork`, `model: claude-sonnet-5-5`, `background: false`). The subagent starts with no conversation history: gather everything from the repository itself (`git status`, `git diff`, `CHANGELOG.md`) and report the result back to the main session in Spanish Mexican. Other tools ignore these frontmatter keys and run the skill inline.

## When to use

When adding or updating entries in CHANGELOG.md for any project following rules conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/changelog.md` from line 1 to end
2. **Step 0 + hard stop (MANDATORY)**: run `git --no-pager status --short` to validate all current changes before any other operation.
   If this exact status check has not been executed in the current run, HARD STOP immediately, restart from step 0 (`git --no-pager status --short`), and do absolutely nothing else (no read, `grep`, search, date calculation, anchor calculation, diff, or patch).
3. **Step 0b (MANDATORY)**: read `CHANGELOG.md` lines `1-200` with the agent's file-reading tool before any `grep`, search loop, or patch attempt.
   If this exact read has not been executed in the current run, HARD STOP immediately, restart from step 0, and do absolutely nothing else.
   Exception: if `CHANGELOG.md` does not exist (`test -f CHANGELOG.md` fails), that check is the step 0b evidence; go on to step 0d (create mode) without a hard stop.
4. **Step 0d — pick the mode deterministically (MANDATORY)**: run `test -f CHANGELOG.md` and `git ls-files --error-unmatch CHANGELOG.md`, then check the canonical format (only when the file exists): line 1 is `# Historial de cambios` or `# Changelog`, followed by the CST note, `<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->` right before the first `## [`, every level-2 heading is `## [YYYY-MM-DD] - Title`, and there is no `###`, `## [Unreleased]` or `## [Sin publicar]` (Keep a Changelog style). This step only picks the mode: no mode writes anything until `DATE_CST` (step 5) and the language (step 8) are known.
   - Missing → **create mode**: write the canonical header in the detected language (step 8) plus one `## [DATE_CST]` block.
   - Exists, untracked, not canonical → **normalise mode**: rewrite the whole file with the canonical header and turn its content into typed bullets inside a single `## [DATE_CST]` block, ordered by the atomic commits (step 7). Drop `[Unreleased]`/`[Sin publicar]` sections, `### Added`/`### Añadido` subheadings and bullets for changes no commit will carry (e.g. empty directories, which Git does not track). Deleted lines are allowed here: the file has no history to protect.
   - Exists and canonical (tracked or not) → **incremental insertion mode** (steps 5 onwards).
   - Exists, tracked, not canonical → stop and report the deviations; never rewrite tracked history without explicit user instruction.
   - **Idempotency (MANDATORY, every mode)**: before adding a bullet, check whether the `DATE_CST` block already has a bullet of the same type for the same change (same file, same purpose); if so, do not add it. A second run with no new working-tree changes yields no diff, and two runs on the same state yield the same file.
5. **Get CST date**: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")` — NEVER use UTC with "CST" suffix
6. **Check existing entries**: Verify if `## [YYYY-MM-DD]` already exists to avoid duplicate headings
7. **Update the target date block** (reverse chronological order):
   - **If the date already exists**: add new typed bullets inside that existing block; do NOT create a duplicate heading.
   - **First-attempt rule (MANDATORY)**: for an existing date block, the first attempt MUST use one single-hunk micro-block replacement with exact `search` = `## [YYYY-MM-DD] - ...` + immediate blank line + first existing bullet.
   - **Insertion rule (MANDATORY)**: in that same hunk, reproduce the heading and blank line intact, then insert the new bullet above the previous first bullet.
   - **Bullet order (MANDATORY)**: inside a date block, bullets are in reverse chronological order — the most recent change at the top, right under the day heading. When one run adds several bullets, order them by the atomic commits that will carry them: the last commit's bullet (the one that ships `CHANGELOG.md`) at the top, the first commit's at the bottom of the new group; `/commit` commits them bottom-up. Never reorder existing bullets.
   - **No intra-block blank line (MANDATORY)**: keep bullets contiguous inside the same date block; never add an empty line between bullets of that block.
   - **If the date does not exist**: create `## [YYYY-MM-DD] - Título descriptivo breve` at the top and add typed bullets.
   - **Spacing rule (MANDATORY)**: keep exactly one blank line between the last bullet of the target date block and the next `## [YYYY-MM-DD]` heading.
   - **Fallback rule (MANDATORY, new date only)**: if insertion preview still shows no blank separator line after creating a new date block, switch immediately to a two-hunk edit (first hunk inserts the new block, second hunk enforces `blank line + next heading`).
   - Base format, Spanish Mexican:

     ```markdown
     ## [YYYY-MM-DD] - Título descriptivo breve

     - feat: descripción del cambio en español mexicano
     - docs: descripción adicional si aplica
     ```

   - Base format, international English (UK):

     ```markdown
     ## [YYYY-MM-DD] - Short descriptive title

     - feat: description of the change in international English (UK)
     - docs: additional description if applicable
     ```

   - **New `CHANGELOG.md` file header** (only when the file does not exist yet), in the detected language:
     - Spanish Mexican: `# Historial de cambios` + `**Nota:** Todas las fechas están en zona horaria CST de Ciudad de México (UTC-6).`
     - International English (UK): `# Changelog` + `**Note:** All dates are in Mexico City CST (UTC-6).`
     - Then `<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->` right before the first `## [YYYY-MM-DD]` heading.

8. **Language**: write entries (title and bullets) in the repository's **primary language**, no emojis. Same rule for personal and corporate repos.
   - **Detection, in this order**:
     1. `CHANGELOG.md` already has entries → keep their language, so the file never mixes languages.
     2. No prior entries → primary language of `README.md` and the docs (`*.md` at the root and in `docs/`): mostly Spanish → **Spanish Mexican**; mostly English → **international English (UK)**.
     3. More than one language with no clear primary one (bilingual README, English README with Spanish docs, etc.) → **international English (UK)**.
     4. No README or docs at all → **Spanish Mexican** (default).
   - **Spanish Mexican**: apply `~/rules/rulesets/LINGUISTICS.md` (angular quotes «», italics for loanwords such as *commit* or *pipeline*, no anglicisms).
   - **International English (UK)**: `-ise`/`-isation` (organise, standardisation), `colour`, `behaviour`, `licence` (noun), `catalogue`; sentence-case titles; straight double quotes `""` instead of `«»`; no italics for technical terms.
   - Typed prefixes (`feat:`, `fix:`, etc.), `[YYYY-MM-DD]` format and CST date rules stay the same in both languages.
9. **Type in bullets**: Each bullet MUST start with `tipo:` and match valid commit types (`feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`, `perf`, `test`, `build`)
10. **Verify**: Check that the new entry is above all previous entries

## Critical rules

- Date format: `[YYYY-MM-DD]` only — no time component
- CST = UTC - 6 hours (verify with `TZ=America/Mexico_City date`)
- No emojis in CHANGELOG entries
- Language: the repository's primary language, detected per instruction 8: Spanish Mexican or international English (UK), defaulting to international English (UK) when there are several with no clear primary one
- Descriptive title after the date: `## [YYYY-MM-DD] - Título descriptivo`
- Do NOT use subheadings like `### feat`/`### fix` inside a date entry
- Keep exactly one blank line between consecutive date blocks (`## [YYYY-MM-DD]`)
- Keep bullets contiguous within the same date block (no blank lines between bullets)
- Incremental mode is insert-only by default: only `+` additions are allowed; deleting existing `CHANGELOG.md` lines requires explicit user instruction. The only exception is normalise mode (step 0d): an untracked, non-canonical file is rewritten in canonical form, never kept with two styles side by side
- Deterministic and idempotent: the same repository state always yields the same `CHANGELOG.md`; re-running with no new changes yields no diff
- Step 0 is mandatory: run `git --no-pager status --short` first to validate all current changes in the run
- HARD STOP absolute: if step 0 (`git --no-pager status --short`) or the precise read of `CHANGELOG.md` lines `1-200` is missing in the current run, stop and restart from step 0; no other action is allowed
- NEVER edit entries from dates different than `DATE_CST` (current day) unless explicitly instructed by the user

## Anti-error and anti-pattern protocol (MANDATORY)

1. Run `git --no-pager status --short` as the first operation of the run (step 0) to validate all current changes.
2. HARD STOP gate: if there is no explicit evidence that the status check happened in the current run, stop immediately and restart from step 0; absolutely no further action is allowed.
3. Read `CHANGELOG.md` lines `1-200` as the second operation of the run (step 0b) (before `grep`, extra search, or patch attempts).
4. HARD STOP gate: if there is no explicit evidence that the `1-200` read happened in the current run, stop immediately and restart from step 0; absolutely no further action is allowed.
5. Verify CST date and existing heading before editing (`TZ=America/Mexico_City date` + `grep -n "^## \\[${DATE_CST}\\]" CHANGELOG.md`).
6. Read the exact target date block before inserting bullets.
7. If `DATE_CST` heading exists, first attempt MUST be one single-hunk micro-block replacement (`heading + blank line + first bullet`) and insertion of the new bullet at top of the block (no blank line between bullets).
8. Validate immediately with `git --no-pager diff -- CHANGELOG.md`.
9. Acceptance criterion: insertion-only diff inside the target date block (only `+` lines); any deleted line (`-`) invalidates the attempt unless the user explicitly requested deletion.
10. If validation fails: do one minimal correction after re-reading the exact block.
11. If creating a new date block and blank separator line is missing, apply mandatory two-hunk fallback:

- Hunk 1: insert the new date block above the next date heading.
- Hunk 2: anchor on the next heading and replace with `blank line + same heading` to force spacing.

12. If validation shows changes outside the target date block: stop and ask user confirmation; do NOT auto-correct historical entries.
13. If it fails again: stop and ask user confirmation before any further attempt.
14. Never chain 3+ consecutive attempts on CHANGELOG without an intermediate successful diff validation.
15. For existing-date insertion, NEVER anchor the edit from the file's H1 (`# Historial de cambios` or `# Changelog`) or any file-top replacement; anchor only on `heading + blank line + first bullet`.
16. If an insertion-only attempt shows any deleted line (`-`) anywhere in `CHANGELOG.md`, abort that patch and rebuild the anchor before retrying; deletions are allowed only with explicit user instruction.

Forbidden anti-patterns:

- Continuing the run without explicit evidence that `git --no-pager status --short` was executed in the current execution.
- Continuing the run without explicit evidence that `CHANGELOG.md` lines `1-200` were read after step 0 in the current execution.
- Attempting to recover mid-run after skipping step 0 or step 0b instead of hard-stopping and restarting from step 0.
- Starting with `grep`, search loops, or patch attempts before reading `CHANGELOG.md` lines `1-200` after executing step 0.
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
- Anchoring an existing-date insertion from the file's H1 (`# Historial de cambios` or `# Changelog`) or replacing the file-top section instead of the micro-block anchor.
- Accepting a patch that deletes separator blank lines when the goal is only to prepend bullets in the current-day block.
- Deleting any existing `CHANGELOG.md` line during incremental insertion without explicit user instruction.

## References

- Detailed CoT: `~/rules/cot/changelog.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
