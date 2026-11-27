# plugin-security Specification

## Purpose
Defines the `security` plugin: read-only scans of repositories, container images, operating systems and language runtimes against the organisation's security canon, run locally, on a worker over SSH or in CI with one `summary.json` contract, plus CVE impact records and reports drafted for `{SECURITY_CHANNEL}`.

## Requirements

### Requirement: Security canon shipped with the plugin
The plugin SHALL ship the canon its skills apply in `references/`, and every finding SHALL cite the canon rule it breaks; the canon covers supported versions, patch minimums, base images, vulnerability blocking rules, exceptions and secrets.

#### Scenario: Finding in a report
- **WHEN** a scan finds an image pinned to `latest`
- **THEN** the report cites the canon's digest-pinning rule

### Requirement: Support status checked at run time
The skills SHALL check whether an operating system, runtime or base image is supported against a live end-of-life source at run time, never from memory, and SHALL require the latest security release of a supported line.

#### Scenario: Runtime past its end of life
- **WHEN** a repository declares a runtime line whose support ended
- **THEN** the finding says so with the end date taken from the live source

### Requirement: Image rules
The canon SHALL prefer glibc-based slim images over musl-based ones for anything the organisation builds or deploys, require images pinned by digest and forbid `sshd` inside application images; the image scan SHALL report each of these.

#### Scenario: Alpine base image
- **WHEN** an image is based on Alpine
- **THEN** the summary marks it as musl and the report recommends a glibc slim equivalent

### Requirement: Vulnerability blocking and exceptions
A CVE in the CISA KEV catalogue without mitigation, or a CRITICAL or HIGH vulnerability with an available fix not applied, SHALL block a deployment. One without a published fix, or a vendor-confirmed false positive, SHALL be accepted only as a documented exception naming the CVE, component, reason, owner and review date.

#### Scenario: Scanner flags a patched component
- **WHEN** a scanner flags a component that the vendor patched in place without changing its version
- **THEN** the finding is recorded as an exception citing the vendor's advisory, not silently ignored

### Requirement: Read-only scans
The skills SHALL only read and report: they SHALL NOT change code, images, machines or settings, and SHALL propose fixes for their owners.

#### Scenario: Secret found in a repository
- **WHEN** an audit finds a committed token
- **THEN** the report proposes revoking it and cleaning history, and the repository is left untouched

### Requirement: Execution venue order
Repository and image scans SHALL run in CI by default for repositories on the forge, on a worker over SSH when one is configured or the repository is elsewhere, and locally only after the user accepts downloading the scanners, which take several gigabytes.

#### Scenario: No worker and no CI access
- **WHEN** the user has no worker and the forge CLI is not logged in
- **THEN** the skill asks before scanning locally and states the expected download size

### Requirement: Pinned scanners and container engine
Scanner images SHALL be pinned in a plugin data file; scans SHALL run in containers with Podman rootless by default and Docker as an alternative, chosen by `{ENV_PREFIX}CONTAINER_ENGINE`.

#### Scenario: Machine with Docker only
- **WHEN** Podman is not installed and Docker is
- **THEN** the scan runs with Docker using the same pinned images

### Requirement: Worker over SSH without Git credentials
With `--on <user>@<host>`, the scan scripts SHALL travel over SSH and a repository revision SHALL travel as a `git bundle` with its history, so the worker needs no Git credentials; only the summary SHALL come back, while full reports stay on the worker.

#### Scenario: Auditing a private repository on a worker
- **WHEN** the user audits a private repository on a worker that has no access to the forge
- **THEN** the bundle carries the revision and its history and the scan completes

### Requirement: Scans in a central CI project
`ci audit|image` SHALL start a pipeline in `{SCAN_CI_PROJECT}` with the forge CLI, wait for it and print its `summary.json` with the pipeline link; exit `0` on success, `2` with `"scanned": false` and the failed jobs' log tails when the pipeline stopped before scanning, and `4` when the CLI is missing, the start fails or it times out.

#### Scenario: Target project does not allow the central project
- **WHEN** the audited project's job-token allow-list lacks `{SCAN_CI_PROJECT}`
- **THEN** the command exits `2` with the log tail explaining it, and the skill reports that adding it is the project owner's decision

### Requirement: Revision scanned
A repository scan SHALL default to the remote default branch, else `HEAD`, and SHALL report the exact commit scanned.

#### Scenario: Local clone behind its remote
- **WHEN** the local clone is behind `origin`
- **THEN** the scan covers the remote revision and the report names its commit

### Requirement: Summary contract
Every venue SHALL produce the same `summary.json`: for a repository its identity, revision, commit, UTC scan time, tools, per-tool step status and findings for secrets, misconfigurations, dependencies, images and runtimes; for an image its reference, digest, OS and support, musl, `sshd` and vulnerabilities.

#### Scenario: Same revision on two venues
- **WHEN** the same revision is scanned in CI and on a worker
- **THEN** both summaries have the same fields and findings, differing only in provenance and timestamps

### Requirement: Summary provenance
Each summary SHALL record the `scanner` that produced it (local, worker or CI) and `scan_py`, the marketplace commit of the scan script.

#### Scenario: Comparing two summaries
- **WHEN** a reviewer compares summaries from two dates
- **THEN** each one says which venue and which version of the scan script produced it

### Requirement: Summaries from reports produced elsewhere
`summarize repo|image` SHALL build the same `summary.json` from reports another system produced (one CI job per scanner, for example), with no container engine, taking each tool's step status and the path prefix the secret scanner used.

#### Scenario: CI with one job per scanner
- **WHEN** a pipeline stores each scanner's report as an artefact
- **THEN** a final job builds `summary.json` from them in the same format as a worker scan

### Requirement: No secret values in summaries
Secret scanning SHALL run with redaction, and summaries SHALL carry only rules, files and counts; files with real private-key material SHALL be verified and listed apart, and files removed from the tree but still in history SHALL be listed for revocation and history clean-up.

#### Scenario: Private key only in history
- **WHEN** a private key was deleted from the tree but remains in history
- **THEN** the summary lists the file under history-only findings without its content

### Requirement: Image references resolved from CI files
When inventorying images, a repository scan SHALL read the block form of an image declaration (`image:` followed by `name:`) and resolve variables defined in the same file, recording where each value came from.

#### Scenario: Image pinned through a CI variable
- **WHEN** a CI file sets the image to `$BUILD_IMAGE` and defines that variable with a digest
- **THEN** the inventory resolves it and counts the image as pinned by digest

### Requirement: Operating system scan
`/security:os [user@host]` SHALL detect macOS, Windows or Linux and report support status, pending updates, running versus installed kernel, runtimes, disk encryption, firewall and SSH, read-only, locally or over SSH.

#### Scenario: Host running an old kernel
- **WHEN** a Linux host has a newer kernel installed than the one running
- **THEN** the report says a reboot is pending to apply it

### Requirement: Runtime skills
`/security:java`, `/security:node` and `/security:python` SHALL check the runtime version against supported LTS lines and patch minimums, lock files, base images and dependencies of their ecosystem.

#### Scenario: Missing lock file
- **WHEN** a Node.js project has no lock file
- **THEN** the report flags unpinned dependencies

### Requirement: CVE impact records
`/security:cve <CVE-ID>` SHALL explain the CVE, whether it is in CISA KEV, its fixed versions and where it affects the organisation, and SHALL write a record to the folder in `{ENV_PREFIX}CVE_CATALOGUE` (default under `{CACHE_DIR}`).

#### Scenario: Exploited CVE
- **WHEN** the CVE is in CISA KEV
- **THEN** the record and the report put it first, with the affected systems found

### Requirement: Reports drafted for the security channel
Reports SHALL be drafted for `{SECURITY_CHANNEL}` after reading its latest messages, posted only after approval, short (severity line, KEV and critical first, what is new), with detail in the thread and status by reaction; they SHALL never hold secret values or working exploit steps.

#### Scenario: Follow-up report
- **WHEN** an earlier report already covered part of the findings
- **THEN** the new draft says only what is new or changed and links back

### Requirement: Configuration by environment
The plugin SHALL read its settings from `{ENV_PREFIX}`-prefixed variables: the default worker and its SSH key, the container engine, the cache and reports folder (default under `{CACHE_DIR}`), the CVE records folder and the central CI project.

#### Scenario: Default worker set
- **WHEN** `{ENV_PREFIX}SECURITY_WORKER` is set
- **THEN** scans that do not run in CI go to that worker without asking for it
