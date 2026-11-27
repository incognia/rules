## Purpose

Defines the `ai` plugin: `AGENTS.md` as each repository's single, tool-agnostic instructions file, with a plain-text `CLAUDE.md` that imports it so Claude Code loads it on every platform, Windows included.

## ADDED Requirements

### Requirement: AGENTS.md is the single source with a CLAUDE.md import
`/ai:init` SHALL leave `AGENTS.md` as the repository's instructions and a plain-text `CLAUDE.md` whose first line is exactly `@AGENTS.md`, written with LF line endings; Claude-only notes, if any, go below that line.

#### Scenario: Repository with AGENTS.md only
- **WHEN** `AGENTS.md` exists and `CLAUDE.md` does not
- **THEN** the skill creates `CLAUDE.md` holding the import line

### Requirement: Symbolic links are replaced
A `CLAUDE.md` that is a symbolic link SHALL be replaced by the import file. A link SHALL be detected by its index mode `120000`, by the file system, or by content that is only a bare path, which is how a link checks out on Windows without link support.

#### Scenario: Link committed from macOS, checked out on Windows
- **WHEN** `CLAUDE.md` is a tracked link that a Windows checkout shows as a text file holding `AGENTS.md`
- **THEN** the skill removes the link from the index and writes the import file, which shows as a type change

### Requirement: Existing content is never overwritten without a choice
When both files exist and `CLAUDE.md` has its own content, the skill SHALL ask the user to choose: add the import on top and keep the content as Claude-only notes, move the content into `AGENTS.md` (showing what would be appended) and keep only the import, or leave it as it is.

#### Scenario: CLAUDE.md with its own rules
- **WHEN** `CLAUDE.md` holds instructions that `AGENTS.md` does not
- **THEN** the skill asks before changing either file

### Requirement: Migration from CLAUDE.md
When only `CLAUDE.md` exists with its own content, the skill SHALL rename it to `AGENTS.md` keeping its history, create the import file, and point out instructions that only apply to Claude so the user can move them below the import.

#### Scenario: Repository that only had CLAUDE.md
- **WHEN** the skill migrates it
- **THEN** `git status` shows the rename to `AGENTS.md` and a new `CLAUDE.md`, and the user gets the list of Claude-specific instructions

### Requirement: Idempotent and commit-free
The skill SHALL change nothing when `CLAUDE.md` already imports `AGENTS.md`, SHALL report but not touch `.claude/CLAUDE.md` or `CLAUDE.local.md`, and SHALL NOT commit; it hands over to the team's changelog and commit flow.

#### Scenario: Already configured repository
- **WHEN** `CLAUDE.md` already has the import line
- **THEN** the skill says so and leaves the working tree unchanged

### Requirement: Nothing to import
When neither file exists, or `CLAUDE.md` is a link to a missing target, the skill SHALL report it and change nothing unless the user asks for a minimal `AGENTS.md`.

#### Scenario: Empty repository
- **WHEN** neither `AGENTS.md` nor `CLAUDE.md` exists
- **THEN** the skill reports it and creates nothing on its own
