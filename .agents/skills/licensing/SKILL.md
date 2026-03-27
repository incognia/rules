---
name: licensing
description: "Apply correct license (GPLv3 for personal, MIT for corporate) based on project context analysis. Use this skill when setting up licensing for a new project."
---

# Licensing by context

## When to use

When creating a new project or when a project needs its LICENSE file and README footer configured.

## Instructions

1. **Read the full CoT**: Load and follow `cot/licensing.md` from line 1 to end
2. **Detect context** by analyzing the project:
   - Look for "Promad", "promad.com.mx", "@incogniadev" → **Corporate (MIT)**
   - Look for "@incognia", "incognia@gmail.com" → **Personal (GPLv3)**
3. **Create LICENSE file**: Download the full license text
   - Corporate: MIT License with `Copyright (c) YYYY, Promad Business Solutions`
   - Personal: GNU GPLv3 from https://www.gnu.org/licenses/gpl-3.0.txt
4. **Add README footer**:
   - Corporate: `*Este proyecto fue elaborado por Rodrigo Álvarez para Promad Business Solutions y se distribuye bajo la licencia MIT.*`
   - Personal: `*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3.*`
5. **Add copyright line** with current year
6. **Verify**: Confirm LICENSE file exists and README footer is correct

## Context indicators

- **Personal (@incognia)**: GPLv3, incognia@gmail.com, ~/.ssh/id_ed25519
- **Corporate (@incogniadev)**: MIT, ralvarez@promad.com.mx, ~/.ssh/promad_ed25519

## References

- Detailed CoT: `cot/licensing.md`
- Rules: `rulesets/LICENSING.md`
