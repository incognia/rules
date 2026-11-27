# Design

## Context

See `proposal.md` for the motivation. Two sources shape the approach:

- **Origin:** the public `rules` repository (<https://github.com/incognia/rules>, GPLv3 except
  its `marketplace/` folder, these specs and the starter kit, which is MIT as its `NOTICE`
  declares, so a corporate instance can copy it) holds personal skills (`.agents/skills/<name>/SKILL.md`)
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
- Claude Code clones with the machine's `git` and never prompts for a password, so every
  machine needs a key with read access; a read-only deploy key also needs an SSH host alias.
- `claude plugin update` fails with "is not installed" for a plugin never installed on that
  machine: plugins are installed one by one on each machine first.
- A relative Markdown link to `references/` does not resolve inside an installed skill: a
  skill body says "read `${CLAUDE_PLUGIN_ROOT}/references/<file>.md`".
- A skill with `context: fork` runs in a subagent that cannot read the main session, so a
  skill that reads the active session (the commit trailer) runs inline.
- On macOS, `python3` may be the old interpreter bundled with the system.

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
| `{PROJECT_MODE}` | Project gate: `corporate` (a company, its data in every profile) or `personal` (one person, flat profile) | `corporate`; the origin `rules` would be `personal` |
| `{ORG}` | Owner of the marketplace: the company (`corporate`) or the person (`personal`) | Kabat One |
| `{MARKETPLACE}` | Marketplace name; plugins install as `<plugin>@{MARKETPLACE}` | `k1` |
| `{TEAMS}` | Teams that publish and use plugins (`corporate` only) | two teams, Mexico and Israel |
| `{COMPANY_FIELDS}` | Company data each user's profile holds (`corporate` only); the company's own name and legal name come from `{ORG}` and `{LICENCE_HOLDER}` | team, role, job title and email signature |
| `{GIT_HOST}` | Forge of the marketplace and of most repositories: `gitlab` or `github` | `gitlab` |
| `{GIT_HOST_DOMAIN}` | SSH host of that forge | `gitlab.com` |
| `{MARKETPLACE_URL}` | SSH URL of the marketplace repository | `git@gitlab.com:<group>/skill-marketplace.git` |
| `{ORG_NAMESPACES}` | Forge namespaces whose repositories belong to `{ORG}`: the company's groups, or the person's own namespace | the organisation's top-level group |
| `{EMAIL_DOMAINS}` | Email domains allowed for commits, the first one preferred (`corporate` only; `personal` has no allow-list) | `kabatone.com` first, plus a second corporate domain |
| `{DOC_LANGUAGE}` | Language of `README.md` (source of truth) and every other document | international English (UK) |
| `{DOC_TRANSLATIONS}` | Languages of `README.<lang>.md` translations | Spanish Mexican (`es`), Hebrew (`he`) |
| `{DESCRIPTION_LANGUAGES}` | Languages of every plugin, catalogue-entry and skill description | English and Spanish |
| `{CONVERSATION_LANGUAGES}` | Languages the skills talk to users in | `en`, `es` |
| `{FORMAT_MODE}` | Format gate: `multinational` (UTC dates, changelogs in international English, UK) or `regional` (dates in `{LOCAL_TZ}`, changelogs in `{REGION_LANGUAGE}`) | `multinational` (teams in two countries, one with daylight saving) |
| `{LOCAL_TZ}` | Time zone of the region as a full POSIX `TZ` string (offset, plus daylight-saving rules where the region has them), never an IANA name | `CST6` (Mexico City, UTC−6, no daylight saving since 2022); with daylight saving, Israel would be `IST-2IDT,M3.4.4/26,M10.5.0` |
| `{REGION_LANGUAGE}` | Language of changelogs and release notes in `regional` mode | Spanish Mexican (only for repositories kept with `/git:changelogger`) |
| `{LICENCES}` / `{LICENCE_HOLDER}` | Licences allowed for `{ORG}`'s repositories, as SPDX identifiers, the first one the default and the marketplace's own (`corporate`: exactly one; `personal`: one or more, chosen per repository); copyright holder (the company's legal name, or the person) | `MIT` / Kabat One; a `personal` instance like the origin: `MIT`, `GPL-3.0-or-later` / the person |
| `{ORIGIN_REF}` | Tag of the public `rules` repository the instance starts from, recorded in its own copy of this design | a release tag such as `v0.1.0` (`k1` predates the tags) |
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

### D6. Two changelog variants, never mixed

Teams in different time zones (one with daylight saving) need the same calendar day in every
changelog, so `/git:changelog` writes UTC dates in international English (UK). An organisation that
works in one region (the origin's convention: Mexico City time, Spanish) uses
`/git:changelogger`, with dates in `{LOCAL_TZ}` and `{REGION_LANGUAGE}`. The commit gate only
checks that `CHANGELOG.md` changed, so it works with both. *Alternative:* one skill with a
flag was rejected because the two formats must never mix in one file and a flag is easy to
forget.

### D7. One commit-message file per session

The origin wrote every message to one shared temporary file; an orchestrating session and
the sessions it delegated to overwrote each other's message. The file name now comes from the
active agent and session (`<tmp>/<tool>-<session-id>-commit.txt`), printed by the trailer
helper with `--message-file`, as the origin's `scripts/commit_trailer.py` already does;
outside an agent session the commit uses a new `mktemp` file instead of stopping. No separate
message-file script is needed.

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

### D12. Format gate: regional or multinational

Which variant a new repository gets is not left to each user: the instance declares
`{FORMAT_MODE}` before building anything, and the `git` plugin ships it in a data file its
skills read.

| | `multinational` (recommended across time zones) | `regional` (one region, e.g. Mexico) |
|---|---|---|
| Changelog dates | UTC | `{LOCAL_TZ}` (`CST6` for Mexico) |
| Changelog and release-notes language | international English (UK) | `{REGION_LANGUAGE}` (Spanish Mexican) |
| Default changelog skill | `/git:changelog` | `/git:changelogger` |
| Marketplace's own `CHANGELOG.md` | UTC, international English (UK) | `{LOCAL_TZ}`, `{REGION_LANGUAGE}` |
| Commits and request titles | international English (UK) | international English (UK) |
| Wiki comments | international English (UK) | international English (UK) |
| Machine timestamps (`summary.json`, caches, manifests) | UTC, ISO 8601 | UTC, ISO 8601 |

**Commits are not part of the choice.** Commit messages and merge or pull request titles are
always in international English (UK), whatever the language of `CHANGELOG.md`, `README.md`
or `AGENTS.md`: a commit history is read by tools and by anyone who joins later, in any
country, and one language keeps it searchable. That is why the language of commits is not a
parameter.

The mode only chooses the default for **new** changelogs: an existing changelog keeps the
convention its own header note declares, so a regional instance can still work on a
repository with a UTC changelog and the other way round. Without a declared mode, a changelog
skill in create mode stops and asks instead of guessing.

`{LOCAL_TZ}` is a full POSIX `TZ` string, not an IANA name (`TZ=America/Mexico_City`): Git
Bash on Windows ships no time-zone database, silently computes in UTC and, from 18:00 to
23:59 in Mexico City, dates the entry the next day. A POSIX string carries everything the C
library needs, so it gives the same result on macOS, Linux, WSL and Git Bash:

- a region without daylight saving uses a fixed offset: `CST6` for Mexico City;
- a region with daylight saving adds its rules, `<STD><offset><DST>,<start>,<end>`: Israel is
  `IST-2IDT,M3.4.4/26,M10.5.0`. A fixed offset there would be an hour wrong half the year.

The cost: the string must be updated by hand when a government changes its rules (the
database would have done it). *Alternative:* an IANA name with a check that the database
exists was rejected: the check is one more place to fail, and the POSIX string already
matches the origin's rule (`rulesets/LINGUISTICS.md`).

### D13. Project gate: corporate or personal

The origin already separates two contexts (`rulesets/LICENSING.md`, `ATTRIBUTION.md`):
corporate work and personal projects, each with its own email, key and licence. The instance
declares `{PROJECT_MODE}` before building anything, next to `{FORMAT_MODE}`, and the `git`
plugin ships it in the same data file.

| | `corporate` | `personal` |
|---|---|---|
| `{ORG}` | The company | The person |
| Profile | Name, forge user, corporate email, SSH key, language and `{COMPANY_FIELDS}` (team, role, job title, email signature) | Name, forge user, email, SSH key, language |
| Email | Only `{EMAIL_DOMAINS}`, personal addresses refused | Any address the person owns; no allow-list |
| Licence | Exactly one in `{LICENCES}` (e.g. MIT), applied without asking; holder `{LICENCE_HOLDER}` | One or more in `{LICENCES}` (e.g. MIT and GPLv3): the repository's own if allowed, otherwise asked per repository; holder the person |
| README licence footer | Author, job title and company | Author only |
| Signed outward content (wiki comments, reports, emails) | Name, job title, role, company and the email signature | Name only |
| Ownership and review | `{TEAMS}`, reviews across teams, `CODEOWNERS` | One owner; no team rules |
| `/git:license` ownership check | Repository under `{ORG_NAMESPACES}` | Repository under the person's own namespace |

The company's name and legal name are instance parameters (`{ORG}`, `{LICENCE_HOLDER}`), so
nobody types them; each user only adds their own team, role, job title and signature once,
in the `/git:init` form. *Alternative:* one profile shape for both was rejected: a personal
marketplace would ask for data that does not exist, and a corporate one would let commits go
out under a personal address.

### D14. A working key per target forge, ed25519 when generated

A repository is only usable once its configured key reaches it, so `/git:init` checks the
target remote's own host, not only `{GIT_HOST_DOMAIN}`: a user who works on GitLab and GitHub
gets one key per forge host in the profile, and each repository's `core.sshCommand` names the
key of its host. When no local key authenticates there, the skill generates one.

Every generated key is ed25519: short, fast and without the parameter choices of RSA or
ECDSA. An existing RSA, ECDSA or DSA key that still authenticates is **not** a stopper: the
skill uses it, recommends an ed25519 replacement once and goes on; the user decides when to
retire the old key, which the skill never deletes. (A DSA key no longer authenticates on
current OpenSSH, so it fails the access check by itself, not by this rule.) *Alternative:*
refusing older keys was rejected: it would block people on a working key for a
recommendation.

## Origin of each skill

| Plugin skill | Origin in `rules` | What changed |
|--------------|-------------------|--------------|
| `/git:init` | `git-init` (`cot/git_init.md`, `rulesets/GIT.md`) | A profile form replaces the `personal`/`laboral` argument; the key must authenticate as the declared user on the target repository's own forge (GitLab, GitHub or another); it creates and registers an ed25519 key when none works |
| `/git:changelog` | new | UTC dates and international English (UK) for teams across time zones |
| `/git:changelogger` | `changelogger` (`cot/changelog.md`, `rulesets/COMMITTING.md`) | Same CST flow, generalised to `{LOCAL_TZ}` as a POSIX time-zone string; default in `regional` mode; language rules shipped as a plugin reference |
| `/git:commit` | `commit` (`cot/committing.md`) | Identity checked against the profile; per-session message file; gate accepts either changelog skill |
| `/git:mr` | `mr` | GitHub pull requests too; reviewers from arguments, `AGENTS.md` or `CODEOWNERS` instead of a private `.env` |
| `/git:release` | `release` (`rulesets/RELEASING.md`) | Fork-safe (`--repo` always); notes in the changelog's language |
| `/git:license` | `licensing` (`rulesets/LICENSING.md`, `ATTRIBUTION.md`) | Only licences in `{LICENCES}` (one fixed licence in `corporate`, a choice per repository in `personal`); author from the profile; footer between markers in every README translation |
| `/ai:init` | `AGENTS.md`/`CLAUDE.md` rule of `rules` («Claude Code specifics») | Turned into a skill that migrates or fixes any repository |
| `/sdd:readiness` | `sdd-readiness` (`rulesets/SDD_READINESS.md`) | Credentials per user in `{CONFIG_DIR}`; falls back to the wiki connector |
| `/llm:fork-session` | new | — |
| `/security:*` (seven skills) | new | Built on the security canon of the organisation |
| `/provision:scan`, `/provision:desktop` | new | — |

Shared scripts with an origin: `commit_trailer.py` (`scripts/commit_trailer.py`, same
four agents, also printing the per-session message file), and the language reference of `/git:changelogger` (`rulesets/LINGUISTICS.md`,
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
  together; `scripts/check-marketplace.sh` in `rules` validates them and compares the main
  specs with the archived change in CI; see D11.
- [Optional plugins depend on infrastructure the spec does not define] → each declares its
  prerequisites and stops with a clear message when one is missing.

## Not yet proven in the reference instance

These requirements go beyond what `k1` does, or were written from its documentation and
headers without reading the implementation. An instance verifies them first.

**`k1` does not do it yet:**

- CI job with `claude plugin validate` on every merge or pull request.
- `scanner` and `scan_py` in every `summary.json` (`k1` writes them only from `summarize`).
- One key per forge host and the key check on GitHub (`k1` checks GitLab only).
- The two gates and the instance data file (`k1` hard-codes one corporate, multinational
  instance).
- Licences chosen per repository in `personal` mode, and signatures taken from the profile.
- `{LOCAL_TZ}` as a POSIX string (`k1`'s `/git:changelogger` uses an IANA name).
- The per-session message file printed by the trailer helper with a `mktemp` fallback
  (`k1` has a separate script that stops without a session id).

**Written without reading the implementation:**

- `plugin-provision` beyond its skill and README: plan inspection, replacement detection
  and the ARP re-check inside the control plane's scripts.
- The scenarios of `/security:os`, `/security:java`, `/security:node`, `/security:python`
  and `/security:cve` (from their descriptions only), and the scanner pinning file.
- The exact content of `HANDOFF.md` in `plugin-llm`.
- `/sdd:readiness` replying in the same thread on a re-assessment (taken from `k1`'s pending
  tests, not from a run).

**Checked only by hand or on one platform:**

- The gates stopping the build is a task rule (tasks 1.0 and 1.1), not a tool.
- Git Bash and daylight-saving dates were checked with `date` on macOS only.
- Whether `autoUpdate` and `--scope project` are honoured is pending in `k1` too.

## Migration Plan

For a new instance:

1. Pick a release tag of <https://github.com/incognia/rules> and record it as `{ORIGIN_REF}`.
   From that tag (all of `marketplace/` is MIT), copy `marketplace/kit/skeleton/` as the
   repository skeleton, the instance file and changelog header of the chosen modes from
   `marketplace/kit/templates/`, the CI of `{GIT_HOST}` from `marketplace/kit/ci/`, and
   `marketplace/openspec/changes/bootstrap-skill-marketplace/` into the new repository's
   `openspec/changes/`, with an empty `openspec/specs/`.
2. Pass both gates: choose `{PROJECT_MODE}` (`corporate` or `personal`) and `{FORMAT_MODE}`
   (and, for `regional`, `{LOCAL_TZ}` and `{REGION_LANGUAGE}`). Then fill the rest of the parameter table in the copy of this
   design and choose `{PLUGINS}`; delete the delta specs of plugins the instance does not
   include.
3. Run `openspec validate --strict`, then work through `tasks.md`.
4. Archive the change when every task is done; the instance's main specs are the result.

Rollback: a plugin is removed by deleting its catalogue entry and folder in a reviewed
change; users uninstall it with `/plugin uninstall <plugin>@{MARKETPLACE}`.

## Open Questions

- **`pr-check`:** whether the personal pull-request check (`rulesets/PR_CHECK.md`) becomes
  `/git:pr-check`. It can be added later as a new skill without changing these specs.
- **Native fork for other agents:** Codex and Copilot CLI sessions travel as a hand-off pack
  until their formats are verified; a later change can promote them to native.
