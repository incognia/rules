# Design

## Context

See `proposal.md` for the motivation. Two sources shape the approach:

- **Origin:** the `rules` repository holds personal skills (`.agents/skills/<name>/SKILL.md`)
  that point to chain-of-thought files (`cot/`) and rulesets (`rulesets/COMMITTING.md`,
  `LINGUISTICS.md`, `LICENSING.md`, `RELEASING.md`, `SDD_READINESS.md`). They assume one
  person, two contexts (personal and corporate), Spanish Mexican documentation and a sync
  script that links them into each agent's folder.
- **Reference result:** the `k1` marketplace, built from those skills for one organisation
  with teams in two countries and three documentation languages. Its history (about seventy
  commits) settled most decisions below. It is an example instance: its values appear only
  in the parameter table.

Claude Code constraints that every decision respects:

- A marketplace is a Git repository with `.claude-plugin/marketplace.json`; a plugin is a
  folder with `.claude-plugin/plugin.json`, and its skills are `skills/<skill>/SKILL.md`.
- Skills are invoked as `/<plugin>:<skill>`. `${CLAUDE_PLUGIN_ROOT}` is substituted in skill
  bodies, but it is not an environment variable inside Bash.
- Users receive an update only when the plugin's `version` changes; private marketplaces do
  not update automatically.
- Claude Code clones with the machine's `git` and never prompts for a password.

## Goals / Non-Goals

**Goals:**

- A specification any organisation can instantiate by setting parameters, with no
  organisation-specific value inside a requirement.
- The same observable result as the reference instance: the same plugins, skills, gates and
  safety rules.
- Plugins that work for people who did not write them: profile forms instead of personal
  defaults, both GitLab and GitHub, several conversation languages.

**Non-Goals:**

- Porting every personal skill: mail, Kubernetes analysis, backups, asset naming,
  LaTeX and teaching stay personal (see «Skills not carried over»).
- Defining an organisation's infrastructure: `provision` drives a control plane and
  infrastructure-as-code repositories that the instance already has; it does not specify
  them.
- Agents other than Claude Code as plugin hosts. Scripts stay tool-agnostic where it is
  cheap (session id and co-author trailer cover four agents), but the marketplace format
  is Claude Code's.

## Parameters

Every placeholder in the specs is one of these. An instance records its values in its own
`AGENTS.md` (and, if it keeps OpenSpec, in its `openspec/config.yaml` context).

| Parameter | Meaning | Reference instance `k1` |
|-----------|---------|-------------------------|
| `{ORG}` | Organisation that owns the marketplace | Kabat One |
| `{MARKETPLACE}` | Marketplace name; plugins install as `<plugin>@{MARKETPLACE}` | `k1` |
| `{TEAMS}` | Teams that publish and use plugins | two teams, Mexico and Israel |
| `{GIT_HOST}` | Forge of the marketplace and of most repositories: `gitlab` or `github` | `gitlab` |
| `{GIT_HOST_DOMAIN}` | SSH host of that forge | `gitlab.com` |
| `{MARKETPLACE_URL}` | SSH URL of the marketplace repository | `git@gitlab.com:<group>/skill-marketplace.git` |
| `{ORG_NAMESPACES}` | Forge namespaces whose repositories belong to `{ORG}` | the organisation's top-level group |
| `{EMAIL_DOMAINS}` | Email domains allowed for commits, the first one preferred | `kabatone.com` first, plus a second corporate domain |
| `{DOC_LANGUAGE}` | Language of `README.md` (source of truth) and every other document | international English (UK) |
| `{DOC_TRANSLATIONS}` | Languages of `README.<lang>.md` translations | Spanish Mexican (`es`), Hebrew (`he`) |
| `{DESCRIPTION_LANGUAGES}` | Languages of every plugin, catalogue-entry and skill description | English and Spanish |
| `{CONVERSATION_LANGUAGES}` | Languages the skills talk to users in | `en`, `es` |
| `{COMMIT_LANGUAGE}` | Language of commits, request titles, the default changelog and wiki comments | international English (UK) |
| `{LOCAL_TZ}` | Time zone of the local-time changelog variant | `America/Mexico_City` (UTC−6, no daylight saving) |
| `{LICENCE}` / `{LICENCE_HOLDER}` | Licence of the marketplace and of the organisation's repositories; copyright holder | MIT / Kabat One |
| `{LICENCE_FOOTER_LANGUAGE}` | Default language of the README licence footer | Spanish |
| `{CONFIG_DIR}` | Per-user configuration folder (profile, credentials) | `~/.config/k1/` |
| `{CACHE_DIR}` | Per-user cache folder prefix | `~/.cache/k1-<plugin>` |
| `{ENV_PREFIX}` | Prefix of every environment variable the plugins read | `K1_` |
| `{PYTHON_MINIMUMS}` | Minimum patch release per supported Python branch | 3.11.18, 3.12.16, 3.13.18, 3.14.10, 3.15.2 (October 2026) |
| `{SECRET_STORE}` | Where runtime secrets come from, besides per-user files | a secrets manager on the control plane |
| `{PLUGINS}` | Optional plugins the instance includes besides `git` and `ai` | `sdd`, `security`, `provision`, `llm` |
| `{CATALOGUE}` | Whether a generated catalogue page is published, and where | yes, on the forge's static pages, members only |
| `{WIKI}` | Wiki that holds specifications (`sdd`) | Confluence |
| `{SECURITY_CHANNEL}` | Private chat channel for scan reports (`security`) | a private Slack channel |
| `{SCAN_CI_PROJECT}` | Central CI project that runs scans (`security`) | a DevSecOps project with its own runner |
| `{CONTROL_PLANE}` | Host that provisions machines and holds infrastructure tokens (`provision`) | a container on the internal network |
| `{HYPERVISOR}` | Virtualisation platform the control plane drives (`provision`) | Proxmox VE, standalone hosts |

## Decisions

### D1. Parameters in braces, examples only in this design

Requirements name `{PARAMETERS}`; concrete values live only in the table above.
*Alternative:* a generic template repository with placeholders to search and replace. It
was rejected because the specs must also explain *why* each value exists, and a template
drifts from the specs the moment someone edits it.

### D2. One capability per plugin, plus two shared ones

`marketplace-repository` and `cross-cutting-rules` hold what every plugin shares; each
plugin is its own capability (`plugin-git`, `plugin-ai`, …), so an instance that drops an
optional plugin drops one spec. *Alternative:* one capability per skill (about twenty specs)
was rejected: the skills of a plugin share a profile, scripts and gates, and splitting them
would repeat those requirements.

### D3. `git` and `ai` always, the rest optional

The marketplace's own workflow uses `/git:init`, `/git:changelog` and `/git:commit`, so `git`
is mandatory; `ai` is cheap and keeps every repository's instructions portable. `sdd`,
`llm`, `security` and `provision` depend on a wiki, a second machine, a scan runner or a
control plane that not every organisation has.

### D4. Tool-agnostic rewrites, not links to the origin

The origin skills read `~/rules/.env`, assume one person's keys and contexts (personal
versus corporate) and Spanish prompts. The plugins replace those assumptions with a per-user
profile filled by a form (`{CONFIG_DIR}/git-profile.json`), an allow-list of email domains
and a profile language. *Alternative:* keeping the personal skills and syncing them per
machine was the starting point and is exactly what the marketplace replaces.

### D5. Python standard library, one shared version check

Every helper is a Python 3 script with the standard library only, so installing a plugin
needs no package manager. Each entry script calls a shared `python_check` first; one copy
per plugin (plugins cannot import across folders) and one in the repository's `scripts/`,
compared in CI. *Alternative:* shell scripts were kept only where they are trivial
(`git-init.sh`); JSON handling, SSH probing and API calls are safer in Python.

### D6. UTC changelog by default, local time as a variant

Teams in different time zones (one with daylight saving) need the same calendar day in every
changelog, so `/git:changelog` writes UTC dates in `{COMMIT_LANGUAGE}`. Repositories that
already keep a changelog in local time and another language (the origin's convention) use
`/git:changelogger`. The commit gate only checks that `CHANGELOG.md` changed, so it works
with both. *Alternative:* one skill with a flag was rejected because the two formats must
never mix in one file and a flag is easy to forget.

### D7. One commit-message file per session

The origin wrote every message to one shared temporary file; an orchestrating session and
the sessions it delegated to overwrote each other's message. The plugin derives the file
name from the active session id (`<tmp>/<session-id>-commit.txt`) and refuses to run without
one.

### D8. Forge facts from `origin`, never from the forge CLI's default

In a fork, `gh` resolves the default repository to the upstream one, so a release or pull
request would land in somebody else's repository. One helper derives platform, project,
branches and fork status from `origin`, and every `gh` command passes `--repo`.

### D9. Security scans: CI first, one summary contract

Scanners and their caches take several gigabytes, so scans run in CI (default), on a worker
over SSH, or locally only when the user accepts the download. All three produce the same
`summary.json`, and `summarize` builds it from reports another system produced, so the skill
reads one format whatever ran the scan.

### D10. Provisioning through a control plane, secrets on standard input

Only the control plane sees the internal network at layer 2 (needed to prove an address is
free by ARP) and holds the infrastructure tokens. The skill collects and validates values,
then drives the control plane's own scripts over SSH; passwords, private keys and tokens
travel only on that session's standard input and are never stored there.

### D11. Where these specs live

The `rules` repository keeps the main specs (`openspec/specs/`) as the canonical, generic
version, and this change as the build plan a new instance applies. To replicate: copy this
change into the new marketplace repository's `openspec/changes/` (with an empty
`openspec/specs/`), fill the parameters, apply it and archive it there. The main specs here
are what that archive produces; a requirement edited in one place is edited in the other in
the same commit.

## Origin of each skill

| Plugin skill | Origin in `rules` | What changed |
|--------------|-------------------|--------------|
| `/git:init` | `git-init` (`cot/git_init.md`, `rulesets/GIT.md`) | A profile form replaces the `personal`/`laboral` argument; the key must authenticate on the forge as the declared user; it can create and register a key |
| `/git:changelog` | new | UTC dates and `{COMMIT_LANGUAGE}` for teams across time zones |
| `/git:changelogger` | `changelogger` (`cot/changelog.md`, `rulesets/COMMITTING.md`) | Same CST flow; dates in `{LOCAL_TZ}`; language rules shipped as a plugin reference |
| `/git:commit` | `commit` (`cot/committing.md`) | Identity checked against the profile; per-session message file; gate accepts either changelog skill |
| `/git:mr` | `mr` | GitHub pull requests too; reviewers from arguments, `AGENTS.md` or `CODEOWNERS` instead of a private `.env` |
| `/git:release` | `release` (`rulesets/RELEASING.md`) | Fork-safe (`--repo` always); notes in the changelog's language |
| `/git:license` | `licensing` (`rulesets/LICENSING.md`, `ATTRIBUTION.md`) | Only the organisation's `{LICENCE}`; author from the profile; footer between markers in every README translation |
| `/ai:init` | `AGENTS.md`/`CLAUDE.md` rule of `rules` («Claude Code specifics») | Turned into a skill that migrates or fixes any repository |
| `/sdd:readiness` | `sdd-readiness` (`rulesets/SDD_READINESS.md`) | Credentials per user in `{CONFIG_DIR}`; falls back to the wiki connector |
| `/llm:fork-session` | new | — |
| `/security:*` (seven skills) | new | Built on the security canon of the organisation |
| `/provision:scan`, `/provision:desktop` | new | — |

Shared scripts with an origin: `commit_trailer.py` (`scripts/commit_trailer.py`, same
four agents), and the language reference of `/git:changelogger` (`rulesets/LINGUISTICS.md`,
reduced to what a changelog needs).

### Skills not carried over

`backup`, `aws-naming`, `bmail`, `mail`, `kube`, `kubetbs`, `ssh-import`, `context`,
`linguistics` (only as a reference file), `styling` (a `docs` plugin was added and removed
the same day: its rules were one person's), `hedgedoc-commit` (one upstream project) and
`pr-check` (pending: see Open Questions).

## Risks / Trade-offs

- [Plugins run code on every installer's machine] → every change through a reviewed merge
  or pull request; no binaries; standard library only; per-plugin ownership.
- [Python minimums age with every security release] → one constant set in identical copies,
  compared in CI; an environment escape hatch recorded as a security exception.
- [Translations drift from the source README] → same-commit rule and a structural check
  (sections, code blocks, table rows) before every commit.
- [Private marketplaces do not auto-update] → README documents the manual update; the
  version bump is part of every release.
- [Two copies of each requirement in `rules` (main spec and change delta)] → edited
  together, checked with `openspec validate --strict`; see D11.
- [Optional plugins depend on infrastructure the spec does not define] → each declares its
  prerequisites and stops with a clear message when one is missing.

## Migration Plan

For a new instance:

1. Copy `openspec/changes/bootstrap-skill-marketplace/` into the new repository's
   `openspec/changes/`, with an empty `openspec/specs/`.
2. Fill the parameter table in the copy of this design and choose `{PLUGINS}`; delete the
   delta specs of plugins the instance does not include.
3. Run `openspec validate --strict`, then work through `tasks.md`.
4. Archive the change when every task is done; the instance's main specs are the result.

Rollback: a plugin is removed by deleting its catalogue entry and folder in a reviewed
change; users uninstall it with `/plugin uninstall <plugin>@{MARKETPLACE}`.

## Open Questions

- **`pr-check`:** whether the personal pull-request check (`rulesets/PR_CHECK.md`) becomes
  `/git:pr-check`. It can be added later as a new skill without changing these specs.
- **Native fork for other agents:** Codex and Copilot CLI sessions travel as a hand-off pack
  until their formats are verified; a later change can promote them to native.
