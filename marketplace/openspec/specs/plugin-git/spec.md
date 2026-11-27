# plugin-git Specification

## Purpose
Defines the `git` plugin: a per-user identity profile and repository set-up, changelog maintenance in a UTC variant and a local-time variant, atomic commits behind a changelog gate, merge or pull requests and semantic releases on GitLab and GitHub, and the organisation's licence.

## Requirements

### Requirement: Per-user Git profile
The plugin SHALL keep one profile per user in `{CONFIG_DIR}/git-profile.json` (or the path in `{ENV_PREFIX}GIT_PROFILE`), mode `600`, holding full name, forge user, email, SSH key name and folder, and conversation language; it SHALL be read and written only through the plugin's profile script.

#### Scenario: No profile yet
- **WHEN** a user runs `/git:init` for the first time on a machine
- **THEN** the profile check reports that there is no profile and the skill shows the form

#### Scenario: Valid profile
- **WHEN** the profile exists and passes validation
- **THEN** `/git:init` shows it in one line and goes on to configure the repository without asking again

### Requirement: Only allowed email domains
The profile and every commit SHALL use an email in `{EMAIL_DOMAINS}`, with the first domain suggested as preferred; personal or other domains SHALL be rejected when saving the profile and when committing.

#### Scenario: Personal email in the form
- **WHEN** a user types an email outside `{EMAIL_DOMAINS}`
- **THEN** saving fails with `ERROR [email]` and the form asks only for the email again

### Requirement: The SSH key authenticates as the declared forge user
Before saving, the profile script SHALL check with `ssh -T git@{GIT_HOST_DOMAIN}` that the chosen key, offered alone (identities-only, ignoring the SSH configuration and agent), authenticates as the declared forge user; the form SHALL offer only keys that do.

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

### Requirement: Profile form
The first-run form SHALL offer detected candidates (full names, forge users per local key, allowed emails and suggestions built from the name) and always a free-text option; when the profile is invalid, it SHALL ask only the fields that failed.

#### Scenario: Profile missing only the language
- **WHEN** an older profile lacks `language`
- **THEN** the form asks only for the language, defaulting to the detected one

### Requirement: Per-repository configuration
`/git:init [ssh_url] [branch]` SHALL set `user.name`, `user.email` and `core.sshCommand` (the profile key with identities-only) in the repository's own configuration, the branch (default `main`) and an SSH-only `origin`, then test access with `git ls-remote origin HEAD`.

#### Scenario: HTTPS remote given
- **WHEN** the user gives an HTTPS remote URL
- **THEN** the skill proposes its SSH form and uses it only after the user confirms

#### Scenario: No access to the project
- **WHEN** `git ls-remote origin HEAD` fails
- **THEN** the skill reports a wrong key or missing access instead of continuing

### Requirement: Canonical changelog format
`CHANGELOG.md` SHALL start with its title, a note naming the time zone of its dates and a markdownlint-disable comment, then one `## [YYYY-MM-DD] - Title` block per day, newest first, each with `- type: description` bullets; it SHALL NOT have `###` headings or an unreleased block.

#### Scenario: Two changes on the same day
- **WHEN** two runs on the same day add bullets
- **THEN** both bullets sit under one heading for that date

### Requirement: UTC changelog variant
`/git:changelog` SHALL write dates in UTC and bullets in `{COMMIT_LANGUAGE}`, and SHALL be the default for new repositories, so teams in different time zones share the same calendar day.

#### Scenario: Late evening in a western time zone
- **WHEN** a change is recorded at 23:30 local time in a zone six hours behind UTC
- **THEN** the entry is dated the next calendar day, as in UTC

### Requirement: Local-time changelog variant
`/git:changelogger` SHALL write dates in `{LOCAL_TZ}` and bullets in the repository's primary language: that of existing entries, otherwise the majority language of its README and documents. It SHALL never label a UTC date as local and SHALL follow the language reference shipped in the plugin.

#### Scenario: Spanish repository without a changelog
- **WHEN** a repository whose documents are mostly Spanish gets its first changelog through `/git:changelogger`
- **THEN** the file uses a Spanish title, a `{LOCAL_TZ}` note and Spanish bullets

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
Once per session and repository, `/git:commit` SHALL check that the repository's `user.name` and `user.email` match the profile, the email is in `{EMAIL_DOMAINS}`, `core.sshCommand` uses the profile key and `origin` is SSH; any mismatch stops it and suggests `/git:init`.

#### Scenario: Personal email in the repository
- **WHEN** a repository is configured with a personal email
- **THEN** `/git:commit` stops before staging anything

### Requirement: Changelog gate
`/git:commit` SHALL abort when `CHANGELOG.md` has no staged, unstaged or untracked change and suggest a changelog skill; the gate checks that the changelog changed, not its language or time zone.

#### Scenario: Commit without a changelog entry
- **WHEN** a user runs `/git:commit` and `CHANGELOG.md` is unchanged
- **THEN** nothing is committed and the user is told to run `/git:changelog` or `/git:changelogger` first

### Requirement: Atomic Conventional Commits
Each commit SHALL hold one logical change, staged with explicit paths, with a Conventional Commits subject and body in `{COMMIT_LANGUAGE}`, committed with `git commit -F`; `CHANGELOG.md` SHALL travel in the last commit of the series. The message SHALL be checked against the staged diff first.

#### Scenario: Mixed changes
- **WHEN** the working tree holds a fix and an unrelated documentation change
- **THEN** they become two commits, and the changelog goes with the last one

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
The request title SHALL be in `{COMMIT_LANGUAGE}`: the commit subject, or one Conventional Commits subject summing up several. The description SHALL be in the changelog's language and list what it does and why, the changes traceable to commits or changelog, and only validation that really ran.

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
The skill SHALL compare the requested bump with the commits and changelog entries since the previous tag: any breaking change requires MAJOR (MINOR while `0.x`), any feature at least MINOR, otherwise PATCH; a smaller or unexplained larger bump SHALL be questioned before publishing.

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
The skill SHALL write the licence footer, crediting the author from the profile, between `<!-- licence:start -->` and `<!-- licence:end -->` in `README.md` and every `README.<lang>.md`, in `{LICENCE_FOOTER_LANGUAGE}` unless the user asks for another, changing nothing outside the markers.

#### Scenario: README with an unmarked footer
- **WHEN** a README already has credit lines without markers
- **THEN** the skill shows them and moves them into the marked block only after approval

### Requirement: Licence only for the organisation's repositories
`/git:license` SHALL check that `origin` is under `{ORG_NAMESPACES}` on `{GIT_HOST_DOMAIN}`, or ask the user to confirm the repository belongs to `{ORG}`; it SHALL NOT license personal projects or need anything beyond the profile.

#### Scenario: Personal repository
- **WHEN** the repository's origin is outside `{ORG_NAMESPACES}` and the user does not confirm it belongs to `{ORG}`
- **THEN** nothing is written
