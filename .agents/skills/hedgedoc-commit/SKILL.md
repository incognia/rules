---
name: hedgedoc-commit
description: "Commit workflow for contributions to the upstream hedgedoc/hedgedoc repository (2.x, develop): DCO sign-off, upstream commit style, per-package changelog only for user-visible changes. Use instead of /commit in that repo."
---

# HedgeDoc commit workflow

Use this skill instead of `/commit` and `/changelogger` in `hedgedoc/hedgedoc` (and forks of it).
Those skills enforce a root `CHANGELOG.md` gate, a `Co-Authored-By` trailer and an automatic push,
none of which match HedgeDoc's rules. Everything here comes from `CONTRIBUTING.md` and the git history.

## Instructions

1. **Identity and SSH key**: run `git config user.name`, `git config user.email` and
   `git config core.sshCommand`. Upstream contributions use the personal context: the name must be the
   real name (DCO forbids pseudonyms), the email `incognia@gmail.com` and `core.sshCommand` must be
   `ssh -i <home>/.ssh/incognia -o IdentitiesOnly=yes`, as `/git-init` sets it. Never accept an empty
   `core.sshCommand`: without it `~/.ssh/config` (`Host * → IdentityFile ~/.ssh/faraday`) decides the
   key, and GitHub still answers `Hi incognia!` with the wrong one. If any of the three is missing or
   different, stop and propose `bash ~/rules/scripts/git-init-context.sh personal incognia "" <current-branch>`
   (empty third argument so `origin` is untouched; pass the current branch, because the default `main`
   would rename it). Do not change the configuration without asking. Then check the key really offered
   with `ssh -i ~/.ssh/incognia -o IdentitiesOnly=yes -T git@github.com` (expect `Hi <user>!`). Do not
   rely on `git ls-remote origin`: a public fork is readable with any account.
2. **Remotes**: `git remote -v` must show `upstream` → `hedgedoc/hedgedoc` and `origin` → the user's
   fork over SSH (`git@github.com:<user>/<fork>.git`; the fork name can differ from `hedgedoc`). A
   plain clone has `origin` pointing at upstream over HTTPS: then stop and propose switching it to SSH
   and creating the fork with `gh repo fork --remote --default-branch-only` run inside the clone (it
   renames `origin` to `upstream` and adds the fork as `origin`), only if the user agrees. Never push
   to `upstream`.
3. **Branch**: never commit on `develop` or `master`. Start from an up-to-date base:
   `git fetch upstream && git switch -c <branch> upstream/develop` (`upstream/master` for 1.x fixes
   and docs). Use a descriptive branch name such as `docs/fix-visibility-api-description`.
4. **Plan atomic commits**: `git status --short`, group by purpose. Stage only named files with
   `git add -- <file>...`, never `git add .` or `git add -A` across mixed changes. Never mix a refactor
   with a functional change in one commit.
5. **Changelog (only when user-visible)**: add one bullet, in the same commit as the code, to
   `frontend/CHANGELOG.md` or `backend/CHANGELOG.md`, under `## [Unreleased]`, in `### Added` or
   `### Changed` (frontend also has `### Removed` and `### Deprecations`). One English sentence, no date,
   no author. Skip it for docs, tests, refactors, dependency bumps and internal fixes. Do not create a
   root `CHANGELOG.md`. `CONTRIBUTING.md` still points to `public/docs/release-notes.md`, which only
   exists on 1.x (`master`). If unsure, ask the user; the maintainers have not confirmed a rule for 2.x.
6. **Message**: write it to a temporary file outside the repository (`msg=$(mktemp)`) and rewrite it
   from scratch for every commit:

   ```text
   type(scope): imperative summary

   Body explaining what and why, wrapped at 72 columns.
   ```

   - Subject: `type(scope): summary`, maximum 50 characters, lowercase after the colon as in the
     recent 2.x history (`CONTRIBUTING.md` says «capitalize», the history does not), imperative mood,
     no trailing period. Types seen upstream: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`.
     Scope examples: `frontend`, `editor`, `settings`, `config`.
   - Body optional for trivial changes; explain what and why, not how. Blank line after the subject.
   - International English.
7. **Trailers**: always `Signed-off-by` via `git commit -s -F "$msg"`. Do **not** add `Co-Authored-By`
   for AI tools unless the user says the maintainers accept it (upstream co-authors are people only).
   Mention AI use in the PR description.
8. **Pre-commit checks**: run `pnpm lint` and `pnpm format` (oxlint / oxfmt; `format` only checks,
   `format:fix` rewrites), plus the tests of the touched package (`pnpm test`) when the change is code.
   The root scripts run through `dotenv -c <env>`, so they need `pnpm install` and a `.env` copied
   from `.env.example` first (not yet verified in practice: if a script fails for that reason, report
   it instead of skipping the check silently). Report failures honestly.
9. **Verify**: `git --no-pager log --format='%h %s%n%b' -3` and confirm every commit has the
   `Signed-off-by` line, then `git --no-pager show --stat HEAD`.
10. **Push**: never automatic. Ask the user first. Push to the fork (`origin`), never to `upstream`.
    If the history was amended after pushing, use `--force-with-lease`.
11. **PR**: target `develop` for 2.x. Fill `.github/pull_request_template.md`, remove steps that do
    not apply, link the issue, and disclose AI assistance. Open it only when the user asks, naming the
    repositories explicitly so `gh` does not pick the fork:
    `gh pr create --repo hedgedoc/hedgedoc --base develop --head <user>:<branch>`.

## Rules

- DCO sign-off on every commit; a missing one blocks the PR.
- Non-interactive commands only (no editors, no `git rebase -i`, no pagers).
- No commit message in Spanish.
