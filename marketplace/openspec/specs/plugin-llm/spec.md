# plugin-llm Specification

## Purpose
Defines the `llm` plugin: forking coding-agent sessions to another machine over SSH, natively for Claude Code and as a hand-off pack for other agents, with a fresh clone of each repository and the source sessions left untouched.

## Requirements

### Requirement: Copy, never move
`/llm:fork-session` SHALL copy sessions; it SHALL NOT move, delete or change a source session, its repository or its memory.

#### Scenario: After a fork
- **WHEN** a fork completes
- **THEN** every source session file has the same content and checksum as before

### Requirement: Menu of local sessions by repository
The skill SHALL list local sessions of the supported agents grouped by repository, with each repository's remote, uncommitted paths and commits ahead or behind, and SHALL group a repository reached through a symbolic link only once.

#### Scenario: Repository behind a link
- **WHEN** a repository is reachable both through a symbolic link and its real path
- **THEN** it appears once in the menu with the sessions of both spellings

### Requirement: Destination asked, never assumed
The skill SHALL ask for the destination host, the remote user (which may differ from the local one), the SSH key when the default does not work and the folder layout (default `~/Code/<repo>`), and SHALL allow sending a repository to another folder or remote.

#### Scenario: Different user on the destination
- **WHEN** the local user is not the destination user
- **THEN** paths are rewritten to the destination user's home, read from the destination

### Requirement: Plan before writing
A plan step SHALL write nothing and SHALL list, per repository, the sessions that travel and what stays behind: uncommitted changes and unpushed commits.

#### Scenario: Unpushed commits
- **WHEN** a repository has commits that `origin` does not have
- **THEN** the plan says they will not reach the destination

### Requirement: Fresh clones on the destination
Each repository SHALL arrive as a fresh `git clone` made on the destination with the remote user's identity; the working tree is never copied.

#### Scenario: Destination cannot clone
- **WHEN** the destination's key has no access to a repository
- **THEN** the fork stops, names the repository that could not be cloned and copies none of its sessions

### Requirement: Claude Code sessions travel natively
Claude Code transcripts, subagents, tool results and project memory SHALL land in the destination's project folder with every path inside the repository rewritten in all its spellings and paths outside it left as they were; the copy resumes with `claude --resume <id> --fork-session`.

#### Scenario: Resuming on the destination
- **WHEN** the user runs the printed resume command on the destination
- **THEN** the session opens in the cloned repository with its history and receives its own new session id

### Requirement: Other agents travel as a hand-off pack
Sessions of agents whose format is not verified for rewriting SHALL travel as their raw files plus a `HANDOFF.md` (origin, paths and the user's prompts in order) under `~/.llm-fork/<agent>/<id>/` on the destination.

#### Scenario: Codex session
- **WHEN** a Codex session is forked
- **THEN** the destination has its raw files and `HANDOFF.md`, and a new session can start from them

### Requirement: Verified transfer and manifest
Files SHALL travel with `tar` over SSH, every file SHALL be verified by SHA-256 on the destination, and each fork SHALL leave a manifest on the destination listing the sessions, their origin and the command that resumes each one.

#### Scenario: Corrupted file
- **WHEN** a copied file's checksum does not match its source
- **THEN** the fork fails with a verification error that lists the files, and writes no manifest and no resume command
