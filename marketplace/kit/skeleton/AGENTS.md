# AGENTS.md

Guidance for AI coding agents working in this marketplace repository. Replace every `<placeholder>`.

## What this repository is

The `<marketplace>` marketplace of Claude Code plugins for `<organisation>`. Members add it with `/plugin marketplace add <ssh-url>` and install plugins as `/plugin install <plugin>@<marketplace>`.

## Instance parameters

| Parameter | Value |
|-----------|-------|
| Project mode | `<corporate or personal>` |
| Format mode | `<multinational or regional>` |
| Local time zone (regional only) | `<POSIX TZ string, for example CST6>` |
| Changelog language | `<language>` |
| Licences | `<SPDX identifiers, default first>` |
| Config folder | `~/.config/<marketplace>/` |
| Environment prefix | `<PREFIX_>` |
| Origin | `https://github.com/incognia/rules` at tag `<vX.Y.Z>` |

## Plugin rules

- Layout: `plugins/<plugin>/` with `.claude-plugin/plugin.json`, `README.md`, `skills/<skill>/SKILL.md`, helpers in `scripts/`, references in `references/`. No top-level `bin/`.
- Skills are invoked as `/<plugin>:<skill>`; a skill name never repeats its plugin name.
- Every description (catalogue entry, plugin, skill) carries a summary in each description language; skills end each one with their usage.
- `${CLAUDE_PLUGIN_ROOT}` is substituted in `SKILL.md` but is not an environment variable in Bash: write the full path in every command, and name reference files by full path instead of relative links.
- A skill uses `context: fork` only when it needs no conversation history. A commit skill never does.
- Helper scripts: Python standard library only, `import python_check; python_check.require()` first, one JSON object on standard output, errors on standard error as `ERROR [field] reason`, exit codes documented in the header.
- Secrets never reach the repository, a command line, an output or the conversation: masked dialog, temporary file with mode `600`, standard input.
- The model talks and decides; scripts act and validate.

## Versions

- A plugin's `version` lives only in its `plugin.json` and changes in every release: users receive an update only when it changes.
- A catalogue entry never carries a `version`.
- See `RELEASING.md` for the checklist.

## Validation (before every commit)

```bash
claude plugin validate .
```

```bash
claude plugin validate ./plugins/<plugin>
```

## Git workflow

1. Record the change with the changelog skill of the format mode.
2. Commit with the commit skill: atomic Conventional Commits in international English (UK), the plugin name as scope, `CHANGELOG.md` in the last commit of the series.
3. Open a reviewed merge or pull request; never push to the default branch.
