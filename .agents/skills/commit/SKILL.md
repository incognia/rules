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
4. **Update CHANGELOG.md FIRST**: Add entry with CST date in Spanish Mexican, following `~/rules/rulesets/COMMITTING.md` format
5. **Stage files**: `git add .`
6. **Commit**: `git commit -m "type: description"` — message MUST be in English international, following Conventional Commits
7. **Push**: `git push`
8. **Verify**: `git --no-pager log --oneline -1`

## Rules

- CHANGELOG.md is ALWAYS updated BEFORE the commit — never after
- Commit messages are ALWAYS in English international
- Use non-interactive commands only (no pagers, no editors)
- CoT files classify as `feat:` not `docs:`

## References

- Detailed CoT: `~/rules/cot/committing.md`
- Rules: `~/rules/rulesets/COMMITTING.md`
- Git config: `~/rules/rulesets/GIT.md`
