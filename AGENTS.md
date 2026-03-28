# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Repository overview

This is the `rules` repository containing technical standards, philosophy, and Chain-of-Thought (CoT) prompts that guide professional and academic work for Rodrigo Álvarez (@incognia). It serves as structured context for LLMs and maintains consistency across personal and corporate projects.

## Core philosophy

The repository combats three endemic problems in Latin American technology:

- **Mercenary work**: mediocre work without real commitment
- **Technical selfishness**: hoarding knowledge to create artificial dependencies
- **Cultural identity loss**: abandoning Spanish cultural identity for perceived professional advancement

All work prioritizes **Spanish Mexican** as the cultural reference while using **international English** for technical code and commit messages.

## Common development tasks

### Linting and quality checks

```bash
# Lint all Markdown files
npm run lint:md

# Check all markdown links
npm run check:links
```

### Working with documentation

All documentation follows strict linguistic rules from `rulesets/LINGUISTICS.md`:

- Use **Spanish Mexican** terminology and expressions
- Apply correct capitalization (only first word and proper nouns in titles)
- Use angular quotes «» in Spanish text, double quotes "" only in code
- Calculate CST timezone correctly (UTC - 6 hours, not just appending "CST")

### Backup operations

```bash
# Backup individual files/directories with checksums
./scripts/backup_file.sh [source_path]

# Create incremental daily backups with rsync
./scripts/backup_rsync_snapshot.sh [source] [destination]
```

### Commit workflow (CRITICAL)

**MANDATORY PROCESS - Always follow this exact order:**

1. **FIRST**: Update `CHANGELOG.md` with changes (in Spanish Mexican)
2. **SECOND**: Add all files: `git add .`
3. **THIRD**: Commit with conventional format: `git commit -m "type: description"`
4. **FOURTH**: Push: `git push`

**Date calculation for CHANGELOG.md:**

```bash
# Get correct CST date (never use UTC with "CST" suffix)
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
```

**Commit message rules:**

- Always use **English international** for commit messages
- Follow [Conventional Commits](https://www.conventionalcommits.org/) specification
- Use non-interactive commands: `git --no-pager log --oneline -5`

## Architecture and structure

### Directory organization

```
├── rulesets/           # Core rules and documentation
│   ├── LINGUISTICS.md      # Spanish Mexican language standards
│   ├── COMMITTING.md       # Git workflow and CHANGELOG rules
│   ├── LICENSING.md        # Licensing strategy (GPLv3 personal, MIT corporate)
│   └── [other standards]
├── cot/                # Chain-of-Thought reasoning prompts
│   ├── committing.md       # Git commit workflow with SSH validation
│   ├── context.md          # Project context detection
│   ├── changelog.md        # CHANGELOG maintenance
│   ├── linguistics.md      # Spanish Mexican rules application
│   └── [other CoTs]
├── templates/          # Reusable document templates
├── scripts/            # Utility scripts for backups and automation
├── .agents/skills/     # AI agent-discoverable skills (see below)
└── .warp/workflows/    # Parameterized command workflows (see below)
```

### Context switching (personal vs corporate)

The repository supports dual contexts with different rules:

**Personal Projects (`@incognia`)**:

- License: GPLv3 (copyleft)
- Email: incognia@gmail.com
- SSH key: ~/.ssh/incognia
- Documentation: Spanish Mexican

**Corporate Projects (`@incogniadev` for Promad Business Solutions)**:

- License: MIT (permissive)
- Email: ralvarez@promad.com.mx
- SSH key: ~/.ssh/kone
- Documentation: Spanish Mexican with STYLING.md rules

### Chain-of-Thought (CoT) system

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

## Conclusión
[Clear, verifiable final answer]
```

Key CoT files:

- `cot/context.md` - Get project context quickly
- `cot/committing.md` - Git workflow with SSH validation
- `cot/linguistics.md` - Apply Spanish Mexican rules
- `cot/changelog.md` - Maintain CHANGELOG.md

## Skills

Skills are lightweight, agent-discoverable instruction sets in `.agents/skills/`. Each skill references detailed CoTs and rulesets without duplicating content.

Available skills:

- **commit** — Full commit workflow with mandatory CHANGELOG update
- **changelog** — CHANGELOG.md maintenance with CST dates
- **linguistics** — Apply Spanish Mexican linguistic rules
- **context** — Quick project context detection
- **backup** — File/directory backup with standard naming
- **licensing** — Apply correct license based on project context (GPLv3 vs MIT)

Invoke with natural language (e.g. "use the commit skill") or slash command (e.g. `/commit`).

## Workflows

Parameterized commands in `.warp/workflows/` for frequent operations:

- **backup_file** — Backup a file or directory with checksums
- **lint_markdown** — Run markdownlint on all files
- **commit_flow** — Complete commit flow with type and description
- **cst_date** — Get current date/time in CST (Ciudad de México)

## Time and date handling (CRITICAL)

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

## Technical specialization context

Primary focus areas reflected in the documentation:

- **Kubernetes on bare-metal Proxmox**: kubeadm, containerd, cloud-init
- **GitOps automation**: Argo CD, Helm charts, versioned manifests
- **Service mesh networking**: Istio, Envoy, Cilium, MetalLB
- **Observability**: Prometheus, Grafana, OpenTelemetry, distributed tracing
- **Enterprise CI/CD**: Jenkins, GitLab CI with GitOps integration

## Key rules to follow

1. **CRITICAL**: Always read complete CoT files from line 1 to end when referenced - never assume based on partial reading
2. **CRITICAL**: Update CHANGELOG.md BEFORE every commit - this is mandatory workflow
3. **CRITICAL**: Convert UTC to CST by subtracting 6 hours - never just append "CST" suffix
4. **Language**: Spanish Mexican for documentation, English international for code/commits
5. **Markdown**: Use .yaml extension (never .yml), always use Mermaid for diagrams (never ASCII)
6. **Commits**: Non-interactive only, use conventional commits format
7. **Files**: Markdown files use UPPERCASE.md format (README.md, PHILOSOPHY.md, etc.)

## Integration with other repositories

When working in other projects, reference this repository:

- Path convention: `~/rules/rulesets/LINGUISTICS.md`
- Philosophy: `~/rules/PHILOSOPHY.md`
- Commit rules: `~/rules/rulesets/COMMITTING.md`
- Templates: `~/rules/templates/`
- CoTs: `~/rules/cot/`
