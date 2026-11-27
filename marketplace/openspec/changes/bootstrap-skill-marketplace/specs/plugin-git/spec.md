## Purpose

Defines the `git` plugin: a per-user identity profile and repository set-up, changelog maintenance in a UTC variant and a local-time variant, atomic commits behind a changelog gate, merge or pull requests and semantic releases on GitLab and GitHub, and the organisation's licence.

## ADDED Requirements

### Requirement: Per-user Git profile
The plugin SHALL keep one profile per user in `{CONFIG_DIR}/git-profile.json` (or the path in `{ENV_PREFIX}GIT_PROFILE`), mode `600`, holding full name, email, conversation language and, per forge host (`{GIT_HOST_DOMAIN}` first), the forge user and the SSH key name and folder; it SHALL be read and written only through the plugin's profile script.

#### Scenario: No profile yet
- **WHEN** a user runs `/git:init` for the first time on a machine
- **THEN** the profile check reports that there is no profile and the skill shows the form

#### Scenario: Valid profile
- **WHEN** the profile exists and passes validation
- **THEN** `/git:init` shows it in one line and goes on to configure the repository without asking again

### Requirement: Corporate profiles carry company data
In a `corporate` instance, the profile SHALL also hold the user's `{COMPANY_FIELDS}` (team, role, job title and email signature), asked once in the `/git:init` form; the company's name and legal name SHALL come from `{ORG}` and `{LICENCE_HOLDER}`, never typed by the user. A `personal` profile SHALL NOT ask for them.

#### Scenario: First run in a corporate instance
- **WHEN** a user of a corporate instance fills the form for the first time
- **THEN** the form asks for their team, role, job title and email signature, and shows the company name without asking for it

#### Scenario: First run in a personal instance
- **WHEN** the owner of a personal instance fills the form
- **THEN** it asks only for name, forge user, email, SSH key and language

#### Scenario: Corporate profile missing company data
- **WHEN** an existing corporate profile lacks the job title
- **THEN** the profile check reports `ERROR [job_title]` and the form asks only for it

### Requirement: Only allowed email domains
In a `corporate` instance, the profile and every commit SHALL use an email in `{EMAIL_DOMAINS}`, with the first domain suggested as preferred; personal or other domains SHALL be rejected when saving the profile and when committing. A `personal` instance SHALL accept any email the user owns.

#### Scenario: Personal email in the form
- **WHEN** a user of a corporate instance types an email outside `{EMAIL_DOMAINS}`
- **THEN** saving fails with `ERROR [email]` and the form asks only for the email again

#### Scenario: Personal instance
- **WHEN** the owner of a personal instance types their personal email
- **THEN** the profile is saved

### Requirement: The SSH key authenticates as the declared forge user
Before saving, the profile script SHALL check, on each forge host the profile records and with `ssh -T git@<host>`, that its key, offered alone (identities-only, ignoring the SSH configuration and agent), authenticates as the declared forge user; the form SHALL offer only keys that do.

#### Scenario: Key registered to another account
- **WHEN** the chosen key authenticates as a different forge user
- **THEN** the profile is not saved and the user is told which account the key belongs to

#### Scenario: Several local keys
- **WHEN** the user has several keys and some are not registered on the forge
- **THEN** each key is checked on its own and an unregistered key is never mistaken for another

### Requirement: Creating and registering a key
When the user has no suitable key, `/git:init` SHALL offer to create an ed25519 key with a name they choose and their profile email as its comment, refusing existing names and disallowed emails, print only its public key, open the forge's SSH-keys page and re-check up to three times.

#### Scenario: New key added on the forge
- **WHEN** the user creates a key, adds the public key on the forge and confirms
- **THEN** the skill checks that it authenticates as the chosen user and saves the profile

#### Scenario: Key not added correctly
- **WHEN** the key still does not authenticate after the user confirms three times
- **THEN** the skill stops and explains the likely causes

#### Scenario: Generated key type
- **WHEN** `/git:init` generates a key for a user whose other keys are RSA
- **THEN** the new key is ed25519

### Requirement: Profile form
The first-run form SHALL offer detected candidates (full names, forge users per local key, allowed emails and suggestions built from the name) and always a free-text option; when the profile is invalid, it SHALL ask only the fields that failed.

#### Scenario: Profile missing only the language
- **WHEN** an older profile lacks `language`
- **THEN** the form asks only for the language, defaulting to the detected one

### Requirement: Per-repository configuration
`/git:init [ssh_url] [branch]` SHALL set `user.name`, `user.email` and `core.sshCommand` (the profile key for the remote's host, with identities-only) in the repository's own configuration, the branch (default `main`) and an SSH-only `origin`, then test access with `git ls-remote origin HEAD`.

#### Scenario: HTTPS remote given
- **WHEN** the user gives an HTTPS remote URL
- **THEN** the skill proposes its SSH form and uses it only after the user confirms

#### Scenario: No access to the project
- **WHEN** `git ls-remote origin HEAD` fails
- **THEN** the skill reports a wrong key or missing access instead of continuing

### Requirement: A valid key for every target repository
`/git:init` SHALL configure a key that authenticates on the target remote's host and can read the repository. When the profile has no key for that host, the skill SHALL offer the user's local keys that authenticate there, and otherwise generate an ed25519 key, guide its registration on that forge and record it in the profile for that host.

#### Scenario: Repository on another forge
- **WHEN** the profile only has a key for `{GIT_HOST_DOMAIN}` and the target remote is on another forge
- **THEN** the skill finds or generates a key that authenticates on that forge, records it for that host and configures the repository with it

#### Scenario: Account without access to the repository
- **WHEN** the key authenticates on the host but `git ls-remote` is refused
- **THEN** the skill reports that the account lacks access to that repository and does not generate another key for it

#### Scenario: Repositories on two forges
- **WHEN** the user sets up one repository on GitLab and another on GitHub
- **THEN** each repository's `core.sshCommand` names the key of its own host

### Requirement: Canonical changelog format
`CHANGELOG.md` SHALL start with its title, a note naming the time zone of its dates and a markdownlint-disable comment, then one `## [YYYY-MM-DD] - Title` block per day, newest first, each with `- type: description` bullets; it SHALL NOT have `###` headings or an unreleased block.

#### Scenario: Two changes on the same day
- **WHEN** two runs on the same day add bullets
- **THEN** both bullets sit under one heading for that date

### Requirement: UTC changelog variant
`/git:changelog` SHALL write dates in UTC and bullets in international English (UK), so teams in different time zones share the same calendar day; it is the default changelog skill when `{FORMAT_MODE}` is `multinational`.

#### Scenario: Late evening in a western time zone
- **WHEN** a change is recorded at 23:30 local time in a zone six hours behind UTC
- **THEN** the entry is dated the next calendar day, as in UTC

### Requirement: Local-time changelog variant
`/git:changelogger` SHALL write dates in `{LOCAL_TZ}` and bullets in the repository's primary language: that of existing entries, otherwise the majority language of its README and documents, otherwise `{REGION_LANGUAGE}`. It is the default when `{FORMAT_MODE}` is `regional`, SHALL never label a UTC date as local and SHALL follow the plugin's language reference.

#### Scenario: Spanish repository without a changelog
- **WHEN** a repository whose documents are mostly Spanish gets its first changelog through `/git:changelogger`
- **THEN** the file uses a Spanish title, a `{LOCAL_TZ}` note and Spanish bullets

### Requirement: New changelogs follow the format gate
In create mode, a changelog skill SHALL use the variant of the `{FORMAT_MODE}` shipped with the plugin; an existing changelog SHALL keep the convention its header note declares, whatever the mode. With no declared mode and no changelog, the skill SHALL stop and ask instead of guessing.

#### Scenario: Regional instance, repository with a UTC changelog
- **WHEN** a regional instance works on a repository whose changelog declares UTC dates
- **THEN** the entry is added in UTC and international English (UK), and the formats never mix in one file

#### Scenario: Wrong skill for a new repository
- **WHEN** a user of a `regional` instance runs `/git:changelog` on a repository with no changelog
- **THEN** the skill says the instance's mode is `regional`, suggests `/git:changelogger` and creates the file only if the user confirms UTC for that repository

#### Scenario: Plugin without a declared mode
- **WHEN** the plugin's data file has no mode and the repository has no changelog
- **THEN** the skill asks whether the repository is regional or multinational before creating anything

### Requirement: Local dates use a POSIX time-zone string
Every command that computes a local date SHALL set `TZ` to `{LOCAL_TZ}`, a full POSIX time-zone string that needs no time-zone database: a fixed offset for a zone without daylight saving (`CST6`) or the offset with its daylight-saving rules (`IST-2IDT,M3.4.4/26,M10.5.0`). It SHALL never use an IANA name or the system's default zone.

#### Scenario: Git Bash without a time-zone database
- **WHEN** `/git:changelogger` runs at 18:30 Mexico City time in Git Bash on Windows, which has no time-zone database
- **THEN** the entry is dated that same day, not the next one

#### Scenario: Region with daylight saving
- **WHEN** a regional instance's zone observes daylight saving, such as Israel
- **THEN** `{LOCAL_TZ}` carries its rules (`IST-2IDT,M3.4.4/26,M10.5.0`) and a change recorded at 23:30 local time is dated that same day in both summer and winter

#### Scenario: IANA name in the parameters
- **WHEN** an instance sets `{LOCAL_TZ}` to an IANA name such as `America/Mexico_City`
- **THEN** the bootstrap rejects it and asks for the equivalent POSIX string (`CST6`)

### Requirement: Deterministic changelog modes
Both changelog skills SHALL pick a mode from the file's state: create when missing; normalise an untracked non-canonical file; insert into a canonical file; and stop on a tracked non-canonical file, reporting the deviations and suggesting the other variant when that is the cause.

#### Scenario: Tracked changelog in the other convention
- **WHEN** `/git:changelog` runs on a tracked changelog dated in local time
- **THEN** it changes nothing, reports the deviations and suggests `/git:changelogger`

### Requirement: Insert-only, idempotent changelog edits
A changelog skill SHALL only add lines inside today's block, never edit or reorder older blocks without an explicit instruction, and SHALL produce no diff when run again with no new changes.

#### Scenario: Re-run without new changes
- **WHEN** a changelog skill runs twice on the same repository state
- **THEN** the second run leaves `CHANGELOG.md` unchanged

#### Scenario: Edit touches an older block
- **WHEN** the diff after an edit shows a removed line or a change outside today's block
- **THEN** the skill discards the attempt and stops after three failed attempts

### Requirement: Changelog bullets follow the commit plan
When one run adds several bullets, they SHALL be ordered by the atomic commits that will carry them: the bullet of the last commit (the one that carries `CHANGELOG.md`) on top. The changelog skills SHALL NOT commit.

#### Scenario: Three atomic commits
- **WHEN** a change will be committed as a fix, a feature and a documentation commit, in that order
- **THEN** today's block shows the documentation bullet first, then the feature, then the fix

### Requirement: Identity check before committing
Once per session and repository, `/git:commit` SHALL check that the repository's `user.name` and `user.email` match the profile, the email is in `{EMAIL_DOMAINS}` (corporate instances), `core.sshCommand` uses the profile key and `origin` is SSH; any mismatch stops it and suggests `/git:init`.

#### Scenario: Personal email in the repository
- **WHEN** a repository is configured with a personal email
- **THEN** `/git:commit` stops before staging anything

### Requirement: Changelog gate
`/git:commit` SHALL abort when `CHANGELOG.md` has no staged, unstaged or untracked change and suggest a changelog skill; the gate checks that the changelog changed, not its language or time zone.

#### Scenario: Commit without a changelog entry
- **WHEN** a user runs `/git:commit` and `CHANGELOG.md` is unchanged
- **THEN** nothing is committed and the user is told to run `/git:changelog` or `/git:changelogger` first

### Requirement: Atomic Conventional Commits
Each commit SHALL hold one logical change, staged with explicit paths, with a Conventional Commits subject and body always in international English (UK), committed with `git commit -F`; `CHANGELOG.md` SHALL travel in the last commit of the series. The message SHALL be checked against the staged diff first.

#### Scenario: Mixed changes
- **WHEN** the working tree holds a fix and an unrelated documentation change
- **THEN** they become two commits, and the changelog goes with the last one

#### Scenario: Repository documented in Spanish
- **WHEN** a repository keeps its changelog, `README.md` and `AGENTS.md` in Spanish Mexican
- **THEN** its commit messages are still in international English (UK)

### Requirement: One message file per session
`/git:commit` SHALL write each message to `<tmp>/<session-id>-commit.txt`, with the id of the active agent session (Claude Code, Codex, Copilot CLI or Antigravity), stop when there is no session id or more than one, never use a fixed shared file, and delete its file after pushing.

#### Scenario: Two sessions commit at once
- **WHEN** an orchestrating session and a session it started commit in parallel on the same machine
- **THEN** each writes its own message file and neither overwrites the other's

### Requirement: Co-author trailer from the active session
Before each commit, `/git:commit` SHALL build the `Co-Authored-By` trailer from the active session's tool, model and effort; when that fails, it SHALL use the attribution the tool supplies, or omit the trailer and say so. It SHALL never copy a trailer from history or another session.

#### Scenario: Model changed mid-session
- **WHEN** the user switches model between two commits
- **THEN** each commit's trailer names the model active when it was made

### Requirement: Push and verify
After the last commit, `/git:commit` SHALL push (setting the upstream on the first push) and show the latest commits and branch status.

#### Scenario: First push of a branch
- **WHEN** the branch has no upstream
- **THEN** the skill runs `git push -u origin HEAD`

### Requirement: Forge facts come from origin
`/git:mr` and `/git:release` SHALL derive platform (`gitlab` or `github`), project, default and current branch, a `dev` branch and fork status from `origin`, never from the forge CLI's default repository; every `gh` command SHALL pass `--repo`. An unknown host SHALL make the skill ask which forge it is.

#### Scenario: Release in a GitHub fork
- **WHEN** a user publishes a release from a fork on GitHub
- **THEN** the tag and release are created in the fork and the upstream repository receives nothing

### Requirement: Merge and pull request preconditions
`/git:mr [target] [draft] [@reviewer ...]` SHALL check that the forge CLI is logged in, the branch differs from the target, the tree is clean and commits are ahead; it SHALL push the branch and, if a request for it is already open, show its link and stop.

#### Scenario: Request already open
- **WHEN** the branch already has an open merge request
- **THEN** the skill shows its link and creates nothing

#### Scenario: Fork with an upstream remote
- **WHEN** the repository has an `upstream` remote
- **THEN** the skill asks whether the request targets the fork or the original repository

### Requirement: Reviewers are never guessed
Reviewers SHALL come from the arguments, then from a reviewers section of the repository's `AGENTS.md` or its `CODEOWNERS` for the changed paths, otherwise from the user, with "no reviewer" as a valid answer; they SHALL never be copied from another repository or an earlier request.

#### Scenario: No reviewers declared
- **WHEN** no argument, `AGENTS.md` section or `CODEOWNERS` entry names a reviewer
- **THEN** the skill asks the user who should review

### Requirement: Request content from real changes
The request title SHALL be in international English (UK): the commit subject, or one Conventional Commits subject summing up several. The description SHALL be in the changelog's language and list what it does and why, the changes traceable to commits or changelog, and only validation that really ran.

#### Scenario: No tests were run
- **WHEN** the branch was not tested
- **THEN** the description does not claim any test

### Requirement: Limited authority of the request skill
`/git:mr` SHALL only push the branch and open the request; it SHALL NOT merge, approve, close or notify anyone about it.

#### Scenario: Request opened
- **WHEN** the request is created
- **THEN** the skill reports its link, title and reviewers and stops

### Requirement: Strict release version
`/git:release` SHALL take exactly one version matching `^v[0-9]+\.[0-9]+\.[0-9]+$` and stop to ask for it otherwise.

#### Scenario: Version without prefix
- **WHEN** the user runs `/git:release 1.2.0`
- **THEN** the skill asks for `v1.2.0` and publishes nothing

### Requirement: Release preconditions
Before publishing, the tree SHALL be clean on the source branch (`dev` if it exists, otherwise the default branch), in sync with `origin`; every existing `v*` tag SHALL be `vX.Y.Z` with no duplicates, every release SHALL point to a tag, and the version SHALL be unused as tag or release.

#### Scenario: Version already tagged
- **WHEN** the requested tag exists locally or on `origin`
- **THEN** the skill stops and reports it

### Requirement: Version checked against the changes
The skill SHALL compare the requested bump with the commits and changelog entries since the previous tag (its date taken in the changelog's own zone): any breaking change requires MAJOR (MINOR while `0.x`), any feature at least MINOR, otherwise PATCH; a smaller or unexplained larger bump SHALL be questioned before publishing.

#### Scenario: Feature released as a patch
- **WHEN** the range holds a `feat` commit and the user asks for a PATCH version
- **THEN** the skill warns and asks before publishing

### Requirement: Annotated tag and release notes from real changes
The skill SHALL fast-forward the default branch from `dev` when it exists, create and push an annotated `vX.Y.Z` tag, and create or update the release named `vX.Y.Z — <descriptor>` with notes in the changelog's language, each item traceable to a changelog entry or commit.

#### Scenario: Release published
- **WHEN** the release is created
- **THEN** the skill verifies the remote tag and the release name and notes, and reports the link

#### Scenario: First own release of a fork
- **WHEN** the previous tag comes from the upstream repository
- **THEN** the notes say this is the fork's first own release

### Requirement: The organisation's licence file
`/git:license` SHALL write `LICENSE` with the `{LICENCE}` text, the current year and `{LICENCE_HOLDER}` after showing a plan of the file's state (missing, same, differs, other licence); replacing a differing or other licence SHALL require the user's approval.

#### Scenario: Licence from an earlier year
- **WHEN** `LICENSE` holds the same licence with last year's date
- **THEN** the skill shows the difference and replaces it only after approval

### Requirement: Licence footer between markers
The skill SHALL write the licence footer, crediting the author from the profile (with job title and company in a `corporate` instance, the name only in a `personal` one), between `<!-- licence:start -->` and `<!-- licence:end -->` in `README.md` and every `README.<lang>.md`, in `{LICENCE_FOOTER_LANGUAGE}` unless the user asks for another, changing nothing outside the markers.

#### Scenario: README with an unmarked footer
- **WHEN** a README already has credit lines without markers
- **THEN** the skill shows them and moves them into the marked block only after approval

### Requirement: Licence only for the owner's repositories
`/git:license` SHALL check that `origin` is under `{ORG_NAMESPACES}` on `{GIT_HOST_DOMAIN}` (the company's groups, or the person's own namespace), or ask the user to confirm the repository belongs to `{ORG}`; a `corporate` instance SHALL NOT apply the company's licence to personal projects.

#### Scenario: Personal repository in a corporate instance
- **WHEN** the repository's origin is outside `{ORG_NAMESPACES}` and the user does not confirm it belongs to `{ORG}`
- **THEN** nothing is written

#### Scenario: Personal instance
- **WHEN** the owner of a personal instance licenses a repository under their own namespace
- **THEN** `LICENSE` carries their licence and their name as holder
