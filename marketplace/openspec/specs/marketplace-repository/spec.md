# marketplace-repository Specification

## Purpose
Defines the repository of a Claude Code plugin marketplace for any organisation: its catalogue, the layout and manifest of each plugin, semantic versioning per plugin, validation, installation and updates, ownership and review, and the optional generated catalogue page.

## Requirements

### Requirement: Marketplace catalogue
The repository SHALL hold its catalogue at `.claude-plugin/marketplace.json` with `name` set to `{MARKETPLACE}`, a `description` in every `{DESCRIPTION_LANGUAGES}`, an `owner` naming `{ORG}`, and a `plugins` list with one entry per published plugin.

#### Scenario: Adding the marketplace
- **WHEN** a member runs `/plugin marketplace add {MARKETPLACE_URL}`
- **THEN** Claude Code registers a marketplace named `{MARKETPLACE}` that lists every plugin of the catalogue

#### Scenario: Installing a plugin
- **WHEN** a member runs `/plugin install git@{MARKETPLACE}`
- **THEN** the `git` plugin is installed from the folder its catalogue entry points to

### Requirement: Plugin set
The catalogue SHALL always include the `git` and `ai` plugins, and SHALL include each optional plugin (`sdd`, `llm`, `security`, `provision`) only when the instance selects it in `{PLUGINS}`.

#### Scenario: Instance without a control plane
- **WHEN** an instance leaves `provision` out of `{PLUGINS}`
- **THEN** the repository has no `plugins/provision/` folder and no catalogue entry for it, and the other plugins work without it

### Requirement: Catalogue entries use relative sources
Each catalogue entry SHALL set `"source": "./plugins/<plugin>"`, a `name` equal to the plugin folder and to the `name` in its `plugin.json`, a `description` and `tags`. An entry SHALL NOT carry a `version`.

#### Scenario: Registering a new plugin
- **WHEN** a plugin `<name>` is added to the catalogue
- **THEN** its entry has `"source": "./plugins/<name>"`, the name `<name>` and no `version` field

### Requirement: Plugin layout
Each plugin SHALL live in `plugins/<plugin>/` with `.claude-plugin/plugin.json`, a `README.md` and one `skills/<skill>/SKILL.md` per skill; helpers go in `scripts/` and reference material in `references/`. A plugin SHALL NOT have a top-level `bin/`.

#### Scenario: Plugin with helpers
- **WHEN** a skill needs a helper script
- **THEN** the script lives in `plugins/<plugin>/scripts/` and the skill calls it as `${CLAUDE_PLUGIN_ROOT}/scripts/<script>`

#### Scenario: Helper path inside Bash
- **WHEN** a skill body runs a helper through the Bash tool
- **THEN** the command uses the `${CLAUDE_PLUGIN_ROOT}` path substituted in the skill body and never relies on it as an environment variable of the shell

### Requirement: Plugin manifest
Each `plugin.json` SHALL declare `name`, `version` (semantic versioning, `MAJOR.MINOR.PATCH`), `description` in every `{DESCRIPTION_LANGUAGES}`, `license` set to `{LICENCE}` and `author`.

#### Scenario: Manifest of a new plugin
- **WHEN** a plugin is created
- **THEN** its `plugin.json` has the five fields and its version starts at `0.1.0`

### Requirement: Version bump on every release
A plugin's `version` SHALL live only in its `plugin.json` and SHALL change in every release of that plugin, because users only receive an update when the version changes.

#### Scenario: Change without a bump
- **WHEN** a change alters a plugin's skills, scripts or references and leaves its `version` unchanged
- **THEN** the review rejects it until the version is bumped

### Requirement: Semantic versioning per plugin
Each plugin SHALL be versioned on its own: MAJOR for a removed or renamed skill or an incompatible argument or output change, MINOR for a new skill or behaviour, PATCH for fixes and documentation. While a plugin is at `0.x`, an incompatible change bumps MINOR.

#### Scenario: New skill in a plugin
- **WHEN** a skill is added to a plugin at `0.6.0`
- **THEN** the plugin is released as `0.7.0` and no other plugin's version changes

#### Scenario: Fix in a script
- **WHEN** only a bug in a helper script is fixed in a plugin at `0.3.0`
- **THEN** the plugin is released as `0.3.1`

### Requirement: Skills are invoked with their plugin prefix
Every skill SHALL be invoked as `/<plugin>:<skill>`; a skill name SHALL NOT repeat its plugin name, and no skill is offered without the prefix.

#### Scenario: Commit skill
- **WHEN** a user wants the commit workflow of the `git` plugin
- **THEN** they run `/git:commit`, not `/commit` or `/git:git-commit`

### Requirement: Skill frontmatter
Each `SKILL.md` SHALL start with frontmatter holding `name` and a `description` in every `{DESCRIPTION_LANGUAGES}` that includes a usage line when the skill takes arguments; `argument-hint` SHALL describe the arguments. A skill SHALL run in a forked context only when it needs no conversation history.

#### Scenario: Skill with arguments
- **WHEN** a skill takes a version argument
- **THEN** its description ends each language's summary with its usage, for example `Usage: /git:release vX.Y.Z`

#### Scenario: Skill that gathers everything from the repository
- **WHEN** a skill reads all its input from the repository, such as a changelog skill
- **THEN** it may declare `context: fork` and reports back to the main session, which relays the result in the user's language

### Requirement: Multilingual descriptions
The `description` of every plugin, catalogue entry and skill SHALL carry a brief summary in each of `{DESCRIPTION_LANGUAGES}`: `EN: … ES: …` style labels for skills, and `English summary / resumen en español` style for plugins and entries.

#### Scenario: Description check
- **WHEN** a plugin or skill is added or its behaviour changes
- **THEN** its description is updated in every language of `{DESCRIPTION_LANGUAGES}` in the same commit

### Requirement: Mandatory validation
`claude plugin validate .` and `claude plugin validate ./plugins/<plugin>` for each changed plugin SHALL pass before every commit, and the same validation SHALL run in CI on every merge or pull request.

#### Scenario: Invalid manifest
- **WHEN** a change leaves a `plugin.json` or the catalogue invalid
- **THEN** the validation fails and the change is neither committed nor merged

### Requirement: Repository documents
The repository root SHALL hold `README.md`, its translations, `CONTRIBUTING.md`, `AGENTS.md` with a `CLAUDE.md` that imports it, `TODO.md`, `CHANGELOG.md` and `LICENSE` (`{LICENCE}`, `{LICENCE_HOLDER}`), plus a `.gitignore` that excludes secrets, caches and generated output.

#### Scenario: New contributor
- **WHEN** someone wants to publish a plugin
- **THEN** `CONTRIBUTING.md` tells them the layout, the manifest fields, the description languages, the version rule, the validation commands and the Git workflow

### Requirement: README covers installation and the plugin table
`README.md` SHALL document how to add the marketplace and install each plugin, the access requirements, updates, adding it to a team repository, the layout, contributing, security, and a table with each plugin's owner team, version and skills.

#### Scenario: Plugin release
- **WHEN** a plugin's version changes
- **THEN** its row in the README table shows the new version and skills in `README.md` and every translation, in the same commit

### Requirement: Installation over SSH without prompts
The README SHALL state that members install with their own Git credentials over SSH, that the key must load without a prompt and the forge host must be in `known_hosts`, and SHALL give a non-interactive access check.

#### Scenario: Checking access before installing
- **WHEN** a member runs `git -c core.askPass= ls-remote {MARKETPLACE_URL} HEAD`
- **THEN** it either prints a commit or fails without prompting, telling them whether installation will work

### Requirement: Team repositories can declare the marketplace
The README SHALL document `claude plugin marketplace add {MARKETPLACE_URL} --scope project`, which writes the entry to the repository's `.claude/settings.json` so whoever clones and trusts the repository sees the marketplace.

#### Scenario: Shared team repository
- **WHEN** a team commits the `.claude/settings.json` written by that command
- **THEN** a member who clones the repository and trusts the folder is offered the marketplace

### Requirement: Updates are documented
The README SHALL state that automatic updates are off for private marketplaces, how to turn them on or update by hand (`/plugin marketplace update {MARKETPLACE}`), and that an open session keeps its version until `/reload-plugins` or a new session.

#### Scenario: New plugin version published
- **WHEN** a member wants the version just released
- **THEN** the README tells them to update the marketplace and reload plugins or start a new session

### Requirement: Ownership and review
Each plugin SHALL belong to one of `{TEAMS}`. Every change SHALL go through a reviewed merge or pull request, and a team SHALL NOT change another team's plugin without that team's review; once more than one team publishes, `CODEOWNERS` SHALL map each plugin folder to its team.

#### Scenario: Change to another team's plugin
- **WHEN** a member of one team changes a plugin owned by another
- **THEN** the change waits for a review by the owning team

### Requirement: No secrets or large binaries in the repository
The repository SHALL NOT contain tokens, passwords, private keys or Git LFS objects; skills read secrets at run time as `cross-cutting-rules` defines.

#### Scenario: Plugin that needs a token
- **WHEN** a skill needs an API token
- **THEN** the token comes from `{SECRET_STORE}` or a per-user file under `{CONFIG_DIR}`, and nothing in the repository holds it

### Requirement: Generated catalogue page
When `{CATALOGUE}` is enabled, a CI job SHALL build a static page from the catalogue, the manifests and the skill frontmatter on every change of the default branch, in `{DESCRIPTION_LANGUAGES}`, and SHALL never commit its output; right-to-left translations are linked, not embedded.

#### Scenario: Plugin version bumped
- **WHEN** a release of a plugin reaches the default branch
- **THEN** the next deployment of the page shows the new version without anyone editing the page

#### Scenario: Isolated build
- **WHEN** the page is built
- **THEN** it runs on a runner with no access to the organisation's internal network

### Requirement: CI images are glibc-based slim images
CI jobs of the marketplace, and images a plugin runs, SHALL start from a glibc-based slim image (for example `python:<version>-slim` or `debian:<release>-slim`), not from a musl-based one, with an explicit version.

#### Scenario: New CI job
- **WHEN** a CI job is added to the marketplace
- **THEN** its image is a versioned glibc-based slim image

### Requirement: The marketplace follows its own Git workflow
Changes to the marketplace SHALL be recorded with `/git:changelog` (UTC dates, `{COMMIT_LANGUAGE}`) and committed with `/git:commit`, using the plugin name as the Conventional Commits scope when a change touches one plugin.

#### Scenario: Release of the security plugin
- **WHEN** a feature of the `security` plugin is committed
- **THEN** the commit subject starts with `feat(security):` and `CHANGELOG.md` has a matching bullet under the UTC date
