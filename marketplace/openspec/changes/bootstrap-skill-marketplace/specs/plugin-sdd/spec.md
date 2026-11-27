## Purpose

Defines the `sdd` plugin: an evidence-based assessment of whether a specification page in `{WIKI}` is ready to run with OpenSpec, Platform Readiness included, posted on the page as a comment only after the user confirms the draft.

## ADDED Requirements

### Requirement: Specification page as input
`/sdd:readiness <link>` SHALL accept the link forms of a `{WIKI}` page (canonical, by page id or short link); without a link it SHALL show its usage and stop.

#### Scenario: No argument
- **WHEN** the user runs `/sdd:readiness` with no link
- **THEN** the skill shows `/sdd:readiness <link>` and reads nothing

### Requirement: Rubric shipped with the plugin
The assessment SHALL follow a rubric in the plugin's `references/`, with weighted dimensions (intent and scope, requirements, scenarios, capabilities, design, tasks, non-functional and security, dependencies and open questions, and Platform Readiness), blockers and verdict thresholds.

#### Scenario: Documentation-only change
- **WHEN** the specification has no runtime or infrastructure impact
- **THEN** Platform Readiness is marked not applicable with a reason and the other weights are rescaled

### Requirement: Evidence-based result
The result SHALL give a verdict (ready, ready with observations or not ready), a score per dimension citing the page's sections as evidence, blockers, inconsistencies, open questions and a draft OpenSpec change (proposal, capabilities and tasks).

#### Scenario: Missing rollback plan
- **WHEN** a deployable specification has no rollback strategy
- **THEN** the Platform Readiness score cites that gap and the verdict follows the rubric's thresholds

### Requirement: Post only after confirmation
The comment SHALL be written in `{COMMIT_LANGUAGE}`, shown to the user as a draft in the conversation language's report, and posted to the page only after explicit approval; the page itself SHALL never be edited.

#### Scenario: User asks for changes to the draft
- **WHEN** the user edits or rejects the draft
- **THEN** nothing is posted until they approve a version

### Requirement: Re-assessment in the same thread
A later assessment of the same page SHALL find the earlier marked comment and reply in its thread instead of opening a new one.

#### Scenario: Specification updated after feedback
- **WHEN** the skill runs again on a page it already assessed
- **THEN** the new result is a reply in the existing thread, stating what changed

### Requirement: Per-user wiki credentials
The skill SHALL post with the user's own API token from a file under `{CONFIG_DIR}` with mode `600`; its setup check SHALL report only whether it is configured, and without it the skill SHALL fall back to the `{WIKI}` connector and explain once how to configure the file.

#### Scenario: Token not configured
- **WHEN** the credentials file is missing
- **THEN** the skill reads and posts through the connector and tells the user how to create the file, never asking for the token in the conversation
