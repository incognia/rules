# Contributing

How to publish or change a plugin in this marketplace.

## Layout

```text
.claude-plugin/marketplace.json     # catalogue: one entry per plugin, no versions
plugins/<plugin>/
├── .claude-plugin/plugin.json      # name, version, description, license, author
├── README.md
├── skills/<skill>/SKILL.md
├── scripts/                        # helpers and a copy of python_check.py
└── references/
scripts/python_check.py             # the copy every plugin's copy must equal
```

## Adding a plugin

1. Create `plugins/<name>/` with its manifest at version `0.1.0`, a `README.md` and its skills.
2. Add its catalogue entry: `"source": "./plugins/<name>"`, the same `name`, a description in every description language and `tags`. No `version`.
3. If it ships Python, copy `scripts/python_check.py` into `plugins/<name>/scripts/` unchanged.
4. Add its row to the plugin table of `README.md` and of every translation.

## Skills

- Frontmatter: `name`, a `description` with a summary per language and the usage line, `argument-hint` when it takes arguments.
- `context: fork` only for skills that need no conversation history.
- Body: execution note, numbered steps, rules, forbidden actions. Full paths with `${CLAUDE_PLUGIN_ROOT}`.

## Versions

MAJOR for a removed or renamed skill or an incompatible change, MINOR for a new skill or behaviour, PATCH for fixes and documentation. While at `0.x`, an incompatible change bumps MINOR. Every release changes the version.

## Before every commit

```bash
claude plugin validate .
```

```bash
claude plugin validate ./plugins/<plugin>
```

```bash
for f in plugins/*/scripts/python_check.py; do cmp scripts/python_check.py "$f"; done
```

## Review and security

- Every change goes through a reviewed merge or pull request.
- No tokens, passwords, private keys or large binaries in the repository.
- Plugins run code on every installer's machine: standard library only, no downloaded binaries.
