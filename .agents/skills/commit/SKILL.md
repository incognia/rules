---
name: commit
description: "Full commit workflow with mandatory CHANGELOG update, SSH validation, and conventional commits in English. Use this skill before making any git commit."
---

# Commit workflow

## When to use

Before making any git commit in projects that follow the rules repository conventions.

## Instructions

1. **Read the full CoT**: Load and follow `cot/committing.md` from line 1 to end
2. **Validate identity**: Run `git config --list | grep ^user\.` and verify the email/name match the expected context (personal vs corporate)
3. **Verify SSH**: Run `git remote -v` — if it shows `https://` the repo is misconfigured (must use SSH)
4. **Get CST date**: `DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")`
5. **Update CHANGELOG.md FIRST**: Add entry with CST date in Spanish Mexican, following `rulesets/COMMITTING.md` format
6. **Stage files**: `git add .`
7. **Commit**: `git commit -m "type: description"` — message MUST be in English international, following Conventional Commits
8. **Push**: `git push`
9. **Verify**: `git --no-pager log --oneline -1`

## Rules

- CHANGELOG.md is ALWAYS updated BEFORE the commit — never after
- Commit messages are ALWAYS in English international
- Use non-interactive commands only (no pagers, no editors)
- CoT files classify as `feat:` not `docs:`

## References

- Detailed CoT: `cot/committing.md`
- Rules: `rulesets/COMMITTING.md`
- Git config: `rulesets/GIT.md`
