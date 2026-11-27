# example

Minimal plugin that shows the two skill shapes and the helper-script contract. Replace it with your first real plugin (`git`) and delete it from the catalogue.

| Skill | What it does | Context |
|-------|--------------|---------|
| `/example:hello <name>` | Greets through `scripts/hello.py` | inline |
| `/example:report` | Summarises pending changes | forked subagent |

## Requirements

- A supported Python with current security patches (`scripts/python_check.py` refuses anything else with exit code `10`).
- `git`.

## Layout

```text
plugins/example/
├── .claude-plugin/plugin.json   # name, version, description, license, author
├── README.md
├── skills/<skill>/SKILL.md      # one folder per skill
├── scripts/                     # helpers: standard library only, JSON on stdout
└── references/                  # material a skill reads on demand
```
