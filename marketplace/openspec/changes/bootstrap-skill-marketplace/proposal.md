# Proposal

## Why

Personal skills (commit, changelog, identity, merge requests, releases, licensing,
specification readiness) live as loose files in one person's `rules` repository: each
machine needs a manual sync, nobody else can install them, and every organisation that
wants the same workflow has to rebuild it. A Claude Code plugin marketplace turns them into
versioned, installable plugins that a whole organisation shares. The reference instance
(`k1`) proved the approach in one week; this change captures it as a generic, parameterised
specification so any organisation or project can build its own marketplace from scratch
and get the same result.

## What Changes

- Create a marketplace repository served by Git: a catalogue
  (`.claude-plugin/marketplace.json`) named `{MARKETPLACE}`, plugins under `plugins/<name>/`
  with their own manifest, skills, scripts and references, semantic versioning per plugin
  and mandatory validation with `claude plugin validate`.
- Add the cross-cutting rules every plugin follows: supported Python with current security
  patches, no secrets in the repository, outputs or conversation, the conversation
  language taken from the user's profile, and multilingual documentation kept in sync with
  one source of truth.
- Add the `git` plugin (always included): identity profile and repository set-up
  (`/git:init`), two changelog variants (`/git:changelog` in UTC and international English (UK),
  `/git:changelogger` in `{LOCAL_TZ}` and the repository's language), atomic commits behind
  a changelog gate (`/git:commit`), merge or pull requests (`/git:mr`) and releases
  (`/git:release`) on GitLab and GitHub, and the organisation's licence (`/git:license`).
- Add the `ai` plugin: `AGENTS.md` as the single instructions file, imported by a
  plain-text `CLAUDE.md` that works on every platform.
- Add the optional plugins an instance selects in `{PLUGINS}`:
  - `sdd`: readiness of a wiki specification for OpenSpec, posted after confirmation;
  - `llm`: fork coding-agent sessions to another machine over SSH;
  - `security`: read-only scans of repositories, images, operating systems and runtimes,
    run locally, on a worker over SSH or in CI, with a common `summary.json` contract;
  - `provision`: machines created through a control plane from a form validated against a
    live capacity scan, with secrets passed only on standard input.
- Add a format gate: before building, the instance declares `{FORMAT_MODE}`,
  `multinational` (UTC dates, recommended when teams span time zones) or `regional` (dates
  in `{LOCAL_TZ}`, a POSIX time-zone string such as `CST6`, and changelogs in `{REGION_LANGUAGE}`), which
  sets the default changelog variant for new repositories. Commits are always in
  international English (UK), in both modes.
- Add a project gate: before building, the instance declares `{PROJECT_MODE}`, `corporate`
  (each profile carries the user's `{COMPANY_FIELDS}`: team, role, job title and email
  signature; commit emails limited to `{EMAIL_DOMAINS}`; the company's licence) or
  `personal` (a flat profile, any email the owner has, their own licence).
- Introduce the instance parameters (organisation, marketplace name, Git host and domain,
  allowed email domains, languages, time zone, licence, paths, environment prefix, Python
  minimums and the optional plugins' settings), recorded in `design.md`.

## Capabilities

### New Capabilities

- `marketplace-repository`: repository layout, catalogue, plugin manifests, semantic
  versioning per plugin, validation, installation and updates, ownership and review, and
  the optional generated catalogue page.
- `cross-cutting-rules`: supported Python check, secret handling, conversation language,
  multilingual documentation, non-interactive operation and confirmation before outward or
  destructive actions.
- `plugin-git`: identity profile and repository set-up, changelog variants, commits,
  merge and pull requests, releases and licence.
- `plugin-ai`: agent instructions with `AGENTS.md` as the single source and a `CLAUDE.md`
  import.
- `plugin-sdd`: readiness assessment of a wiki specification for OpenSpec.
- `plugin-llm`: forking coding-agent sessions across machines.
- `plugin-security`: security scans, their execution venues, the `summary.json` contract,
  the security canon and reporting.
- `plugin-provision`: capacity scan, provisioning form, naming canon, secret transport and
  plan confirmation.

### Modified Capabilities

None: this is the first change of the project.

## Impact

- **New repository** per instance (on `{GIT_HOST}`), private or public as the
  organisation decides; members install it with their own Git credentials over SSH.
- **Users' machines:** plugins run scripts there, so every change goes through review. They
  need `git`, `ssh`, a supported Python 3 and, per plugin, the forge CLI (`glab` or `gh`), a
  container engine (security) or SSH access to a control plane (provision).
- **Per-user files** under `{CONFIG_DIR}` (profile, credentials, mode `600`) and caches
  under `{CACHE_DIR}`; the global Git configuration is never touched.
- **CI:** one validation job, and optionally the catalogue page and the central scan
  project, on runners chosen by the instance.
- **Origin repository (`rules`):** its skills stay as they are; the plugins are
  tool-agnostic rewrites, not links to it.
