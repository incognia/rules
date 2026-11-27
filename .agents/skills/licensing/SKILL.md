---
name: licensing
description: "Apply the licence of the project context: MIT held by the employer for corporate work, GPLv3 by default or MIT for personal projects. Use this skill when setting up licensing for a new project."
---

# Licensing by context

## When to use

When creating a new project or when a project needs its LICENSE file and README footer configured.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/licensing.md` from line 1 to end
2. **Detect context** by analyzing the project:
   - Look for "Kabat One", "kabatone.com", "@incogniadev" (or the legacy "Promad", "promad.com.mx") → **Corporate (MIT)**. The copyright holder is the employer the work was made for: Kabat One when the README names it, otherwise ask; never assume it
   - Look for "@incognia", "<incognia@gmail.com>" → **Personal**: keep the licence the repository already has (GPLv3 or MIT); with none, GPLv3 unless the user asks for MIT
   - Both kinds of indicators, or none → stop and ask
3. **Create LICENSE file** with the current year from `date +%Y` (never hardcoded):
   - Corporate: MIT License with `Copyright (c) <current year>, <employer>`
   - Personal: GNU GPLv3 from <https://www.gnu.org/licenses/gpl-3.0.txt>, or MIT with `Copyright (c) <current year>, Rodrigo Ernesto Álvarez Aguilera`
4. **Write the README footer** between the `<!-- licence:start -->` and `<!-- licence:end -->` markers, using the exact texts of `~/rules/rulesets/LICENSING.md` §3.1 as the CoT builds them (step 4). Replace only the marked block, or append it when absent; never delete ranges starting at the first `---` (that would wipe the frontmatter and the body). If an unmarked footer already exists, show it and ask before changing it. Use portable commands (no `sed -i` without suffix).
5. **Verify**: LICENSE exists with the current year, the README has exactly one marked footer, and `git --no-pager diff --stat README.md` shows only the footer changed

## Context indicators

- **Personal (@incognia)**: GPLv3 by default or MIT, held by the author, <incognia@gmail.com>, ~/.ssh/incognia
- **Corporate (@incogniadev)**: MIT held by the employer, with the author credited, <ralvarez@kabatone.com>, ~/.ssh/kone

## References

- Detailed CoT: `~/rules/cot/licensing.md`
- Rules: `~/rules/rulesets/LICENSING.md`
