---
name: commit
description: "Full commit workflow with mandatory CHANGELOG validation, SSH validation, atomic conventional commits in English and a co-author trailer detected from the active session. Use this skill before making any git commit."
---

# Commit workflow

> **Execution:** this skill runs inline in the main session, never as a forked subagent, so the model that did the work is the one that commits and `scripts/commit_trailer.py` can read it from the active session.

## When to use

Before making any git commit in projects that follow the rules repository conventions.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/committing.md` from line 1 to end
2. **Validate identity (first time in session only)**: If you already validated identity in this conversation session, skip to step 3. Otherwise run the full step 0 of `~/rules/cot/committing.md`: check `user.name`, `user.email`, `core.sshCommand` and `remote.origin`, show the identity block, confirm the remote uses SSH (not HTTPS) and the identity matches the context (personal or laboral). If anything is missing or wrong, stop and apply `~/rules/cot/git_init.md` first.
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
5. **Plan atomic commits**: run `git status --short`, classify the changes by logical type and purpose (e.g. `feat` + `fix`, `docs` + `refactor`) and plan one commit per group, ordered by the new bullets of the day block in `CHANGELOG.md` from bottom to top (first commit = lowest new bullet; last commit = top bullet), so the CHANGELOG's reverse chronological order matches git history. Stage each group only with `git add -- <file>...`; never `git add .` or `git add -A` across mixed changes (a single homogeneous group may use `git add -A`). `CHANGELOG.md` goes in the **last** commit of the series, together with that group's files; earlier commits pass the gate because `CHANGELOG.md` still has pending changes.
6. **Build the commit message for the current group**: create (or rewrite before each commit) `/tmp/commit-msg.txt` using this detailed structure (international English, UK):

   ```text
   type(scope): short summary in english
   
   - Detail 1 in english
   - Detail 2 in english that wraps to another line
     aligned with the bullet text (continuation line)
   - Detail 3 in english

   Co-Authored-By: <agent in turn> <identifier>
   ```

   **Mandatory formatting rules for bullets and long lines:**
   - Bullet marker `-` MUST start at column 1 (no leading spaces or tabs before `-`).
   - If a bullet is too long, split it manually into a new line.
   - Continuation lines MUST be indented with two spaces so text stays aligned with the bullet content.
   - Keep exactly one blank line between subject/body and body/footer.
   - Redundancy rule: commit body details MUST NOT include `update/edit CHANGELOG.md` (or equivalent), because changelog maintenance is a precondition validated by `/commit`, not a detail to report in the body.
   - `Co-Authored-By` is resolved from the active session immediately before **each** commit (the model can change mid-conversation), never hardcoded. Shared format: `Co-Authored-By: [<Tool> ]<Model> (<effort>) <email>`, e.g. `Claude Opus 5.5 (medium)`, `Codex GPT-6.1 Sol (high)`, `Copilot GPT-6 Luna (low)`:
     1. In Claude Code, Codex or GitHub Copilot CLI, run `python3 ~/rules/scripts/commit_trailer.py` and use its stdout only when it exits 0. If it reports that the effort is unavailable, the printed model-only trailer is still valid.
     2. If the helper fails, use the attribution line the tool or harness supplies for the session (e.g. Claude Code's system-provided commit attribution), kept in the shared format.
     3. Other tools: build it from the identity the session itself reports, in the shared format, with the tool's documented commit email (Anthropic `noreply@anthropic.com`, OpenAI `noreply@openai.com`, GitHub Copilot `223556219+Copilot@users.noreply.github.com`, Google Antigravity `antigravity-agent@google.com`, Warp `oz-agent@warp.dev`; otherwise `noreply@<tool-domain>`).
     4. If the model cannot be verified, omit the trailer and tell the user; never guess.
     - Never copy a name, model or effort from these rules, an earlier commit, another session or configuration defaults.
   `/tmp/commit-msg.txt` persists across commits and invocations: rewrite it from scratch (subject included) for every commit, and before `git commit -F` check that subject and body describe exactly what `git diff --cached --stat` shows.
7. **Commit from file**: `git commit -F /tmp/commit-msg.txt` — message MUST be in international English (UK), following Conventional Commits. Repeat steps 5–7 for each group (re-running the trailer helper each time) until the working tree is clean.
8. **Push** once, after the last commit: `git push`
9. **Verify**: `git --no-pager log --oneline -5`

## Anti-error and anti-pattern protocol for /commit (MANDATORY)

1. Do not proceed to `git add`/`git commit` if CHANGELOG gate fails (no diff in `CHANGELOG.md`).
2. If CHANGELOG gate fails, abort and suggest `/changelogger` before any further commit action.
3. Before committing, enforce language checkpoint declaration:
   - `⚠️ LANGUAGE CHECK: All commit messages must be in international English (UK) per the CRÍTICO language rule in ~/rules/cot/committing.md`
4. Build or update `/tmp/commit-msg.txt`, then verify content is English before `git commit -F`.
5. Never use interactive editors/pagers in commit flow.
6. Stop immediately if any forbidden anti-pattern appears and request user confirmation before continuing.

Forbidden anti-patterns:

- Commit/push while `CHANGELOG.md` has no diff versus repo.
- Editing `CHANGELOG.md` from `/commit` instead of using `/changelogger`.
- Including `update/edit CHANGELOG.md` (or equivalent) as a commit body detail.
- Falling back to ad-hoc commit messages that skip `/tmp/commit-msg.txt`.
- Using Spanish in commit message subject/body.
- Mixing unrelated change types in one commit, or `git add .`/`git add -A` across mixed changes.
- Committing `CHANGELOG.md` before the last commit of the series.
- Stale commit message: reusing a subject or body left in `/tmp/commit-msg.txt` by an earlier commit or invocation without checking it against the staged files.

## Rules

- CHANGELOG.md MUST already be updated BEFORE `/commit`; `/commit` only validates changes
- If `CHANGELOG.md` has no diff, abort and invoke `/changelogger`
- Commit messages are ALWAYS in international English (UK)
- Commit body must describe substantive changes only; do not include changelog-edit tasks in body bullets
- Use non-interactive commands only (no pagers, no editors)
- Always use `git commit -F /tmp/commit-msg.txt`, never `git commit -m`
- Atomic commits: one logical change per commit, staged selectively; `CHANGELOG.md` travels with the last one
- Re-run `scripts/commit_trailer.py` before every commit
- In `/tmp/commit-msg.txt`, keep bullets left-aligned and wrap long lines with aligned continuation indentation
- `CHANGELOG.md` format maintenance belongs to `/changelogger` + `~/rules/cot/changelog.md`
- CoT files classify as `feat:` not `docs:`

## References

- Detailed CoT: `~/rules/cot/committing.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
- Git config: `~/rules/rulesets/GIT.md`
