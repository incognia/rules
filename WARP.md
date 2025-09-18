# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is the `rules` repository containing technical standards, philosophy, and Chain-of-Thought (CoT) prompts that guide professional and academic work for Rodrigo Álvarez (@incognia). It serves as structured context for LLMs and maintains consistency across personal and corporate projects.

## Core Philosophy

The repository combats three endemic problems in Latin American technology:
- **Mercenary work**: mediocre work without real commitment
- **Technical selfishness**: hoarding knowledge to create artificial dependencies  
- **Cultural identity loss**: abandoning Spanish cultural identity for perceived professional advancement

All work prioritizes **Spanish Mexican** as the cultural reference while using **international English** for technical code and commit messages.

## Common Development Tasks

### Linting and Quality Checks

```bash
# Lint all Markdown files
npm run lint:md

# Check all markdown links
npm run check:links

# Manual fixes (autofix not configured)
npm run lint:md:fix
```

### Working with Documentation

All documentation follows strict linguistic rules from `docs/LINGUISTICS.md`:
- Use **Spanish Mexican** terminology and expressions
- Apply correct capitalization (only first word and proper nouns in titles)
- Use angular quotes «» in Spanish text, double quotes "" only in code
- Calculate CST timezone correctly (UTC - 6 hours, not just appending "CST")

### Backup Operations

```bash
# Backup individual files/directories with checksums
./scripts/backup_file.sh [source_path]

# Create incremental daily backups with rsync
./scripts/backup_rsync_snapshot.sh [source] [destination]
```

### Commit Workflow (CRITICAL)

**MANDATORY PROCESS - Always follow this exact order:**

1. **FIRST**: Update `CHANGELOG.md` with changes (in Spanish Mexican)
2. **SECOND**: Add all files: `git add .`
3. **THIRD**: Commit with conventional format: `git commit -m "type: description"`
4. **FOURTH**: Push: `git push`

**Date calculation for CHANGELOG.md:**
```bash
# Get correct CST date (never use UTC with "CST" suffix)
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
echo "[$DATE_CST] type: description" >> CHANGELOG.md
```

**Commit message rules:**
- Always use **English international** for commit messages
- Follow [Conventional Commits](https://www.conventionalcommits.org/) specification
- Use non-interactive commands: `git --no-pager log --oneline -5`

## Architecture and Structure

### Directory Organization

```
├── docs/           # Core rules and documentation
│   ├── LINGUISTICS.md      # Spanish Mexican language standards
│   ├── COMMITTING.md       # Git workflow and CHANGELOG rules
│   ├── PHILOSOPHY.md       # Core technical philosophy
│   ├── LICENSING.md        # Licensing strategy (GPLv3 personal, MIT corporate)
│   └── [other standards]
├── prompts/        # Chain-of-Thought prompts and templates
│   ├── cot/        # Step-by-step reasoning templates
│   ├── templates/  # Reusable templates
│   ├── guides/     # Longer narrative guides
│   ├── actions/    # Executable workflow prompts
│   └── snippets/   # Reusable code fragments
└── scripts/        # Utility scripts for backups and automation
```

### Context Switching (Personal vs Corporate)

The repository supports dual contexts with different rules:

**Personal Projects (`@incognia`)**:
- License: GPLv3 (copyleft)
- Email: incognia@gmail.com
- SSH key: ~/.ssh/id_ed25519
- Documentation: Spanish Mexican

**Corporate Projects (`@incogniadev` for Promad Business Solutions)**:
- License: MIT (permissive) 
- Email: ralvarez@promad.com.mx
- SSH key: ~/.ssh/promad_ed25519
- Documentation: Spanish Mexican with STYLING.md rules

### Chain-of-Thought (CoT) System

The repository implements structured reasoning prompts following this format:

```markdown
---
domain: [project area]
task: [specific task]
difficulty: [básico|intermedio|avanzado]
priority: [crítico|alto|medio|bajo]
---

# CoT: [descriptive title]

## Razonamiento
[Brief mental framework of approach]

## Pasos
1. Acción: [what to do]
   Resultado: [expected outcome]
2. Acción: [next action]
   Resultado: [expected outcome]

## Conclusión
[Clear, verifiable final answer]
```

Key CoT files:
- `prompts/cot/context.md` - Get project context quickly
- `prompts/cot/committing.md` - Git workflow with SSH validation
- `prompts/cot/linguistics.md` - Apply Spanish Mexican rules
- `prompts/cot/changelog.md` - Maintain CHANGELOG.md

### Time and Date Handling (CRITICAL)

**Never append "CST" to UTC times without calculation.**

**Correct conversion**: CST = UTC - 6 hours
- UTC 14:30 → CST 08:30
- UTC 03:15 → CST 21:15 (previous day)

**Commands for correct CST time:**
```bash
# Always use this for accurate CST dates
TZ=America/Mexico_City date +"%Y-%m-%d %H:%M %Z"

# For CHANGELOG.md (date only)
TZ=America/Mexico_City date +"%Y-%m-%d"

# Verify conversion
echo "UTC: $(date -u '+%H:%M')" && echo "CST: $(TZ=America/Mexico_City date '+%H:%M')"
```

## Technical Specialization Context

Primary focus areas reflected in the documentation:
- **Kubernetes on bare-metal Proxmox**: kubeadm, containerd, cloud-init
- **GitOps automation**: Argo CD, Helm charts, versioned manifests
- **Service mesh networking**: Istio, Envoy, Cilium, MetalLB
- **Observability**: Prometheus, Grafana, OpenTelemetry, distributed tracing
- **Enterprise CI/CD**: Jenkins, GitLab CI with GitOps integration

## Key Rules to Follow

1. **CRITICAL**: Always read complete CoT files from line 1 to end when referenced - never assume based on partial reading
2. **CRITICAL**: Update CHANGELOG.md BEFORE every commit - this is mandatory workflow
3. **CRITICAL**: Convert UTC to CST by subtracting 6 hours - never just append "CST" suffix
4. **Language**: Spanish Mexican for documentation, English international for code/commits
5. **Markdown**: Use .yaml extension (never .yml), always use Mermaid for diagrams (never ASCII)
6. **Commits**: Non-interactive only, use conventional commits format
7. **Files**: Markdown files use UPPERCASE.md format (README.md, PHILOSOPHY.md, etc.)

## Integration with Other Repositories

When working in other projects, reference this repository:
- Path convention: `~/rules/docs/LINGUISTICS.md`
- Philosophy: `~/rules/PHILOSOPHY.md`  
- Commit rules: `~/rules/docs/COMMITTING.md`
- Templates: `~/rules/prompts/templates/`

This repository serves as the foundational context for all technical and academic work, ensuring consistency across different projects and environments.

<citations>
<document>
    <document_type>WARP_DOCUMENTATION</document_type>
    <document_id>getting-started/quickstart-guide/coding-in-warp</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>G5Mjw6X1XLRFYcv0RbTyDC</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>iHExsoZBx1f4jk5GT8mTb2</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>cwKu7GgjS8dtyS4LTDUXYo</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>l42Tn4qzs3YCWnMumi00x0</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>rC5e17b4LLWAPsfEGZStIU</document_id>
</document>
<document>
    <document_type>RULE</document_type>
    <document_id>hjJUBEZRzEgthvJjhe1P8U</document_id>
</document>
</citations>