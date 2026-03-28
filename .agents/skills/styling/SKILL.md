---
name: styling
description: "Apply Kabat One Markdown styling to a file by platform. Usage: /styling <hedgedoc|gitlab|github> [mit|gpl] <file>"
---

# Styling

## Usage

```
/styling <platform> [license] <file>
```

- **platform** (required): `hedgedoc`, `gitlab` or `github`
- **license** (optional): `mit` or `gpl` — only for `README.md` on GitLab/GitHub. Omit to skip license block.
- **file** (required): path to the Markdown file to apply styling to. Always the last argument.

Examples:
- `/styling hedgedoc doc.md` — HedgeDoc, no license
- `/styling gitlab mit README.md` — GitLab with MIT license
- `/styling github gpl README.md` — GitHub with GPLv3

To detect arguments: `mit` and `gpl` are the only valid license values — if the second argument is neither, it is the file.

## Templates

Use as starting point:
- `templates/hedgedoc.md` — generic HedgeDoc document
- `templates/gitlab-readme.md` — GitLab README.md with license and badges
- `templates/github-readme.md` — GitHub README.md with license and badges

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/styling.md` from line 1 to end
2. **Parse arguments**: first arg is platform, last arg is the file. If 3 args are given, middle arg is license (`mit`|`gpl`). If only 2 args, there is no license. If any required argument is missing, ask the user before proceeding.
3. **Insert standard header** (varies by platform):
   - **HedgeDoc only**: YAML frontmatter with descriptive `tags` + Kabat One logo: `![Kabat One logo](https://hedgedoc.promad.com.mx:31418/uploads/aaa5198c-248f-4642-8c67-00f6edde677a.png)`
   - **GitLab/GitHub README.md only**: YAML frontmatter with `title` and `description` (rendered as table on GitHub, code block on GitLab):
     ```yaml
     ---
     title: "Nombre del proyecto"
     description: "Breve descripción del proyecto"
     ---
     ```
     > ⚠️ Always quote values with double quotes — values containing `:` cause YAML parse errors if unquoted.
   - **GitLab/GitHub other docs**: no frontmatter
   - H1 title
   - Timestamp: `LC_TIME=es_MX.UTF-8 TZ=America/Mexico_City date '+%d de %B de %Y, %H:%M (%Z)'`
   - **HedgeDoc**: `<div style="text-align: right;"><em>Última modificación: [timestamp] (CST)</em></div><br>`
   - **GitLab/GitHub**: `*Última modificación: [timestamp] (CST)*` — plain Markdown italic, no HTML (GL/GH strip inline styles)
4. **Apply content rules**: hierarchy H1→H2→H3→H4, no skipped levels, sentence case titles
   - **GitLab/GitHub only**: strip or adapt HedgeDoc-exclusive syntax:
     - Remove `[TOC]`, `[name=...]`, `[time=...]`, `[color=...]`
     - Convert `:::info`/`:::warning` admonition blocks to plain blockquotes (`> **Nota:**`)
     - Remove frontmatter YAML block (GitLab/GitHub ignore it)
     - Remove `<style>` blocks (ignored by both platforms)
5. **Remove ALL stray `---` separators** (CRITICAL — AI-generated documents tend to abuse these):
   - Run: `grep -n "^---$" <last_argument>` to locate every occurrence
   - The YAML frontmatter `---` (lines 1 and 3) are allowed
   - The ONE `---` immediately before the footer firma is allowed
   - **Delete every other `---` without exception** — sections, tables, code blocks, and paragraphs must NOT be separated with `---`
6. **Insert standard footer** based on platform:

### HedgeDoc footer (no license)

```markdown
---

![FIRMA](https://hedgedoc.promad.com.mx:31418/uploads/f8e2dc04-bbf8-41b7-9443-17b483f19beb.png)

[//]: # (CSS Corporativo)

<style>
  :root {
    --promad: #00B2E0;
    --midnight: #0E1821;
    --electric: #116dff;
    --lavender: #a5b7ea;
  }
  a { color: var(--midnight); }
  .night a { color: var(--promad); }
  a:hover { color: var(--promad); text-decoration: none; }
  .night a:hover { color: var(--lavender); text-decoration: none; }
  body { color: var(--midnight); }
  .markdown-body h1 { border-bottom: 1px solid var(--promad); }
  .markdown-body p { text-align: justify; }
  .markdown-body hr { height: 1px; background-color: var(--promad); }
</style>
```

### Badges en README.md (cuando se especifica `mit` o `gpl`)

Insertar después del timestamp y antes del primer párrafo. Si ya existen badges, verificar que sean correctos.

MIT:
```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

GPLv3:
```markdown
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
```

Badges adicionales (solo si el proyecto los tiene configurados):
- **GitLab**: pipeline status, coverage
- **GitHub**: Actions CI workflow

### GitLab / GitHub footer — README.md with license (`[mit|gpl]` provided)

```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
```

Para MIT:
```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez para Promad Business Solutions y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*
```

**Sin firma. Sin CSS.**

### GitLab / GitHub footer — otros documentos (sin tercer parámetro)

Sin footer. No se agrega nada.

## Rules

- Timestamps ALWAYS in CST (Ciudad de México, UTC-6) — never UTC
- **HedgeDoc**: firma image + CSS in footer. Never license.
- **GitLab/GitHub README.md** (with `mit`/`gpl`): copyright text only. No firma. No CSS.
- **GitLab/GitHub other docs**: no footer at all.

## References

- Detailed CoT: `~/rules/cot/styling.md`
- Rules: `~/rules/rulesets/STYLING.md`
- Linguistics: `~/rules/rulesets/LINGUISTICS.md`
