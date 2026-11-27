# Tasks

## 1. Parameters

- [ ] 1.0 **Project gate:** choose `{PROJECT_MODE}`: `corporate` (company data in every profile: `{COMPANY_FIELDS}`, `{EMAIL_DOMAINS}`, the company's licence and `{TEAMS}`) or `personal` (flat profile, any email the owner has, their own licence). No later task starts until it is recorded
- [ ] 1.1 **Format gate:** choose `{FORMAT_MODE}`: `multinational` (UTC, recommended when teams span time zones) or `regional` (for example Mexico: `{LOCAL_TZ}` `CST6`, `{REGION_LANGUAGE}` Spanish Mexican). Commits stay in international English (UK) in both. No later task starts until it is recorded
- [ ] 1.2 Fill the parameter table of `design.md` with the instance's values (`{ORG}`, `{MARKETPLACE}`, `{GIT_HOST}`, `{EMAIL_DOMAINS}`, languages, `{LOCAL_TZ}`, `{LICENCE}`, `{CONFIG_DIR}`, `{ENV_PREFIX}`, `{PYTHON_MINIMUMS}` and the rest)
- [ ] 1.3 Choose `{PLUGINS}` and delete the delta specs and tasks of the optional plugins the instance leaves out
- [ ] 1.4 Check the current Python security releases and set `{PYTHON_MINIMUMS}` from them, never from this table's example
- [ ] 1.5 Run `openspec validate --strict` on the instantiated change

## 2. Repository skeleton

- [ ] 2.1 Create the repository on `{GIT_HOST}` and set the maintainer's identity and SSH remote (with the origin `git-init` skill until `/git:init` exists)
- [ ] 2.2 Add `LICENSE` (`{LICENCE}`, `{LICENCE_HOLDER}`) and a `.gitignore` that excludes environment files, keys, Python caches, editor files and the generated catalogue output
- [ ] 2.3 Create `.claude-plugin/marketplace.json` with `name` `{MARKETPLACE}`, the multilingual description, `owner` and an empty `plugins` list
- [ ] 2.4 Write `AGENTS.md` (what the repository is, plugin rules, languages, Git workflow, parameters) and a `CLAUDE.md` holding only `@AGENTS.md`
- [ ] 2.5 Write `CONTRIBUTING.md`: layout, manifest fields, description languages, version rule, validation commands, documentation languages, Git workflow, review and security
- [ ] 2.6 Write `README.md` in `{DOC_LANGUAGE}`: installation, access check, updates, team-repository scope, plugin table, layout, contributing and security; then one `README.<lang>.md` per `{DOC_TRANSLATIONS}` with the same structure
- [ ] 2.7 Create `TODO.md` and `CHANGELOG.md` with the canonical header of the declared `{FORMAT_MODE}` (UTC or `{LOCAL_TZ}`)
- [ ] 2.8 Run `claude plugin validate .`

## 3. Shared rules

- [ ] 3.1 Write `scripts/python_check.py`: minimums per branch, exit code `10`, fix-it message, `{ENV_PREFIX}ALLOW_PYTHON` escape hatch, importable by old interpreters
- [ ] 3.2 Test it on an end-of-life interpreter, on each supported branch below and at its minimum, and on a newer branch
- [ ] 3.3 Document in `AGENTS.md` and `CONTRIBUTING.md` the rules of `cross-cutting-rules`: secrets, conversation language, README synchronisation, non-interactive commands, confirmation before outward actions

## 4. `git` plugin

- [ ] 4.1 Create `plugins/git/` with `plugin.json` (`0.1.0`), `README.md` and a copy of `python_check.py`; register it in the catalogue
- [ ] 4.2 Write `scripts/profile.py`: `detect`, `save`, `show`, `verify` (exit `0`, `1`, `2`), `keygen` and `open-keys-page`, with the profile shape of `{PROJECT_MODE}` (company fields and email allow-list only in `corporate`) one key per forge host, the identities-only key check on each host, ed25519 for every generated key and a non-blocking recommendation for RSA, ECDSA or DSA keys
- [ ] 4.3 Write `scripts/git-init.sh` (repository-level identity, `core.sshCommand`, branch, SSH-only `origin`) and the `/git:init` skill with its two-step form, the key check against the target remote's host, key creation and registration guide
- [ ] 4.4 Write the plugin's instance data file (`scripts/instance.json`: `{PROJECT_MODE}`, `{ORG}`, `{LICENCE}`, `{LICENCE_HOLDER}`, `{FORMAT_MODE}`, `{LOCAL_TZ}`, `{REGION_LANGUAGE}`) that the profile, licence and changelog skills read
- [ ] 4.5 Write the `/git:changelog` skill (UTC, international English (UK), deterministic modes, insert-only edits, forked context, format gate in create mode)
- [ ] 4.6 Write the `/git:changelogger` skill (`TZ={LOCAL_TZ}` as a POSIX string, repository language, format gate in create mode) and the language reference it reads in `references/`, starting from the origin's `changelogger` and `rulesets/LINGUISTICS.md`
- [ ] 4.7 Test `/git:changelogger` in Git Bash on Windows between 18:00 and 23:59 local time: the entry keeps the local date
- [ ] 4.8 Write `scripts/commit_msg.py` (per-session message file, `--clean`) and `scripts/commit_trailer.py` (four agents, active session only), starting from the origin's `scripts/commit_trailer.py`
- [ ] 4.9 Write the `/git:commit` skill: identity check, changelog gate, atomic plan, message checked against the staged diff, push and clean-up
- [ ] 4.10 Write `scripts/forge.py` (`info`, `normalise`; exit `3` on an unknown host) and the `/git:mr` skill for GitLab and GitHub
- [ ] 4.11 Write the `/git:release` skill: version format, preconditions, tag history, SemVer check, annotated tag, notes from the changelog, fork safety
- [ ] 4.12 Write `scripts/license.py` (`plan`, `apply`, markers, approval exit codes) and the `/git:license` skill with the `{ORG_NAMESPACES}` check
- [ ] 4.13 Validate the plugin, update the README table and its translations, and record the release in `CHANGELOG.md`
- [ ] 4.14 From here on, commit the marketplace with its own changelog skill (the one of its `{FORMAT_MODE}`) and `/git:commit`

## 5. `ai` plugin

- [ ] 5.1 Create `plugins/ai/` with its manifest, README and the `/ai:init` skill (create, replace a link, ask on own content, migrate, idempotent, no commit)
- [ ] 5.2 Test it on each case of its decision table, including a link checked out on Windows

## 6. `sdd` plugin (if selected)

- [ ] 6.1 Create `plugins/sdd/` with its manifest, README and a copy of `python_check.py`
- [ ] 6.2 Write the rubric in `skills/readiness/references/` from the origin's `rulesets/SDD_READINESS.md`, with Platform Readiness criteria fitted to the organisation's stack
- [ ] 6.3 Write the `{WIKI}` client and comment builder in `scripts/` (setup check without secrets, post, find the marked thread, reply) and the `/sdd:readiness` skill
- [ ] 6.4 Test it on a real page through the connector only and with the user's token, including a re-assessment in the same thread

## 7. `llm` plugin (if selected)

- [ ] 7.1 Create `plugins/llm/` with its manifest, README and a copy of `python_check.py`
- [ ] 7.2 Write `scripts/fork_session.py` (`list`, `plan`, `fork`): grouping by repository, path rewriting in every spelling, hand-off packs, `tar` over SSH, SHA-256 verification and the manifest
- [ ] 7.3 Write the `/llm:fork-session` skill and test a real fork, then resume each session on the destination

## 8. `security` plugin (if selected)

- [ ] 8.1 Create `plugins/security/` with its manifest, README and a copy of `python_check.py`
- [ ] 8.2 Write `references/canon.md` from the organisation's security policy, and `references/report-format.md` for `{SECURITY_CHANNEL}`
- [ ] 8.3 Pin the scanner images in `scripts/tools.json`
- [ ] 8.4 Write `scripts/scan.py`: `tools`, `repo`, `image`, `os`, `--on` with a `git bundle`, `summarize` and `ci audit|image`, all producing the same `summary.json`
- [ ] 8.5 Create `{SCAN_CI_PROJECT}` with one job per scanner and a final `summarize` job, on a runner the instance controls
- [ ] 8.6 Write the skills `audit`, `image`, `os`, `java`, `node`, `python` and `cve`
- [ ] 8.7 Test each skill on a real target and each venue (local, worker, CI), including a project that lacks the job-token permission

## 9. `provision` plugin (if selected)

- [ ] 9.1 Create `plugins/provision/` with its manifest, README and a copy of `python_check.py`
- [ ] 9.2 Write the data file (hosts, subnet, machine types, ranges, templates, defaults, choices, regions) with no secret in it
- [ ] 9.3 Write the scan (`scan.py` locally, the read-only part that runs on `{CONTROL_PLANE}`) with its cache, maximum age and exit codes
- [ ] 9.4 Write the owner helper (email, key, forge user, ed25519 key creation, recommendation for older key types, masked password and token dialogs) and the machine helper (options, plan, create, configure, forget)
- [ ] 9.5 Write `/provision:scan` and one skill per machine type whose template exists, starting with the type the instance needs first
- [ ] 9.6 Run a first real provisioning and confirm no secret stayed on the control plane

## 10. CI and catalogue

- [ ] 10.1 Add a CI job that compares every copy of `python_check.py` with `scripts/python_check.py`
- [ ] 10.2 Add a CI job that runs `claude plugin validate` on the marketplace and every plugin on each merge or pull request, on a glibc slim image with an explicit version
- [ ] 10.3 If `{CATALOGUE}` is enabled, write `scripts/build_catalogue.py` and a job that publishes the page from the default branch on an isolated runner
- [ ] 10.4 Turn off the forge's shared fallback runners if the instance's policy requires its own, and put tags on every job

## 11. Verification

- [ ] 11.1 Install every plugin from scratch on a clean machine with a member's own SSH key, following only the README
- [ ] 11.2 Run `/git:init`, `/git:changelog`, `/git:commit`, `/git:mr` and `/git:release` on a real repository of each forge, a fork included, checking nothing lands upstream
- [ ] 11.3 Run the Git workflow with one member per team and conversation language
- [ ] 11.4 Have a native speaker review each README translation
- [ ] 11.5 Add `CODEOWNERS` once a second team publishes a plugin
- [ ] 11.6 Record open items in `TODO.md` and archive this change
