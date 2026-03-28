---
name: context
description: "Quickly detect project context: technologies, structure, CI/CD, documentation. Use this skill when starting work on any repository."
---

# Project context detection

## When to use

When starting work on a new or unfamiliar repository to quickly understand its structure and technologies.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/context.md` from line 1 to end
2. **Check documentation**: Look for README.md, AGENTS.md, AGENTS.md, CONTRIBUTING.md
3. **Detect technologies**: Check for package.json, go.mod, Cargo.toml, requirements.txt, pom.xml, Gemfile
4. **Check containers**: Look for Dockerfile, compose.yaml, docker-compose.yaml
5. **Check orchestration**: Look for k8s/, kubernetes/, manifests/, Helm charts
6. **Check CI/CD**: Look for .github/workflows/, .gitlab-ci.yml, Jenkinsfile
7. **Analyze structure**: Run `tree -L 2 -I node_modules` or `ls -la`
8. **Read key files**: First 20 lines of README.md and any AGENTS.md found
9. **Identify context**: Determine if personal (@incognia) or corporate (@incogniadev) project
10. **Summarize findings**: Technologies, structure, CI/CD, documentation, context

## References

- Detailed CoT: `~/rules/cot/context.md`
