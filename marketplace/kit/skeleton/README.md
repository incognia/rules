# `<marketplace>`

Claude Code plugins and skills of `<organisation>`.

## Install

Check access first; it must print a commit or fail without prompting:

```bash
git -c core.askPass= ls-remote <ssh-url> HEAD
```

Then, inside Claude Code:

```text
/plugin marketplace add <ssh-url>
/plugin install example@<marketplace>
```

Requirements: your own SSH key registered on the forge, loaded without a prompt, and the forge host in `known_hosts`.

## Plugins

| Plugin | Owner | Version | Skills |
|--------|-------|---------|--------|
| `example` | `<team>` | 0.1.0 | `/example:hello`, `/example:report` |

## Updates

See «What users do after the merge» in [RELEASING.md](./RELEASING.md).

## Team repositories

```bash
claude plugin marketplace add <ssh-url> --scope project
```

Commit the `.claude/settings.json` it writes: whoever clones and trusts the repository is offered the marketplace.

## Contributing and security

See [CONTRIBUTING.md](./CONTRIBUTING.md). Report a security problem privately to `<contact>`.
