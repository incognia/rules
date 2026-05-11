---
name: commit
description: "Full commit workflow with mandatory CHANGELOG validation, SSH validation, and conventional commits in English. Use this skill before making any git commit."
---

# Commit workflow

## When to use

Before making any git commit in projects that follow the rules repository conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/committing.md` from line 1 to end
2. **Validate identity (first time in session only)**: If you already validated identity in this conversation session, skip to step 3. Otherwise: run `git config --list | grep ^user\.` and `git remote -v`, verify email/name match expected context and remote uses SSH (not HTTPS).
3. **Validate CHANGELOG gate BEFORE staging (MANDATORY)**:
   a. Run change validation (staged or unstaged):
      ```bash
      git --no-pager diff --quiet -- CHANGELOG.md && git --no-pager diff --cached --quiet -- CHANGELOG.md
      ```
   b. Interpretation:
      - **Exit code 0**: `CHANGELOG.md` has NO changes versus repo → **abort** `/commit` flow.
      - **Exit code 1**: `CHANGELOG.md` has changes → continue.

   c. If there are no changes in `CHANGELOG.md`, stop execution and suggest:
      - `Run /changelogger to update CHANGELOG.md, then run /commit again.`

4. **(Optional) Inspect CHANGELOG diff**:
   - `git --no-pager diff -- CHANGELOG.md`
   - `git --no-pager diff --cached -- CHANGELOG.md`
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

## Anti-error and anti-pattern protocol for /commit (MANDATORY)

1. Do not proceed to `git add`/`git commit` if CHANGELOG gate fails (no diff in `CHANGELOG.md`).
2. If CHANGELOG gate fails, abort and suggest `/changelogger` before any further commit action.
3. Before committing, enforce language checkpoint declaration:
   - `⚠️ LANGUAGE CHECK: All commit messages must be in English per ~/rules/cot/committing.md line 15`
4. Build or update `/tmp/commit-msg.txt`, then verify content is English before `git commit -F`.
5. Never use interactive editors/pagers in commit flow.
6. Stop immediately if any forbidden anti-pattern appears and request user confirmation before continuing.

Forbidden anti-patterns:
- Commit/push while `CHANGELOG.md` has no diff versus repo.
- Editing `CHANGELOG.md` from `/commit` instead of using `/changelogger`.
- Falling back to ad-hoc commit messages that skip `/tmp/commit-msg.txt`.
- Using Spanish in commit message subject/body.

## Rules

- CHANGELOG.md MUST already be updated BEFORE `/commit`; `/commit` only validates changes
- If `CHANGELOG.md` has no diff, abort and invoke `/changelogger`
- Commit messages are ALWAYS in English international
- Use non-interactive commands only (no pagers, no editors)
- Prefer `git commit -F /tmp/commit-msg.txt` over `git commit -m` to keep detailed, reusable commit messages
- In `/tmp/commit-msg.txt`, keep bullets left-aligned and wrap long lines with aligned continuation indentation
- `CHANGELOG.md` format maintenance belongs to `/changelogger` + `~/rules/cot/changelog.md`
- CoT files classify as `feat:` not `docs:`

## References

- Detailed CoT: `~/rules/cot/committing.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
- Git config: `~/rules/rulesets/GIT.md`
