## Purpose

Defines the `provision` plugin: machines created on `{HYPERVISOR}` hosts through `{CONTROL_PLANE}`, from a form validated against a live capacity scan, with a naming canon, secrets passed only on standard input and nothing created, replaced or destroyed without a confirmed plan.

## ADDED Requirements

### Requirement: Work runs on the control plane
The skills SHALL reach `{CONTROL_PLANE}` over SSH and run there the infrastructure repositories' own scripts, because only it sees the internal network at layer 2 and holds the infrastructure tokens; the skills collect and validate values and drive those scripts.

#### Scenario: Control plane unreachable
- **WHEN** the control plane does not answer over SSH
- **THEN** the skill stops with exit code `2` and suggests checking the network path, such as a VPN

#### Scenario: Control plane lacks a capability
- **WHEN** a script on the control plane does not exist or does not know a flag the skill needs
- **THEN** the skill stops and names the missing piece instead of working around it

### Requirement: Non-secret settings in a plugin data file
Hosts, hosts not recommended with a reason, memory headroom, storage, the subnet, machine types (prefix, address range, templates per distribution, defaults, size choices, repository on the control plane) and regions (locale, time zone, keyboard) SHALL live in a data file of the plugin, with no secret in it.

#### Scenario: New machine type
- **WHEN** an instance adds a machine type
- **THEN** it adds an entry to the data file and the scan reports that type's free addresses

### Requirement: Naming canon
Each machine SHALL be named `<prefix>-<octet>`, with guest id equal to the octet and address `<subnet>.<octet>`, the octet taken from the range of its type.

#### Scenario: Desktop on octet 193
- **WHEN** a desktop type with prefix `<prefix>` gets octet `193`
- **THEN** its hostname is `<prefix>-193`, its guest id `193` and its address `<subnet>.193`

### Requirement: Read-only capacity scan
`/provision:scan` SHALL report, without changing anything, the free cores, memory (after headroom) and disk per host, guest ids in use, templates available and the free addresses of each type, and SHALL cache the result locally under `{CACHE_DIR}` with its time.

#### Scenario: Recent scan reused
- **WHEN** a provisioning skill asks for a scan no older than its maximum age
- **THEN** it reads the cache instead of scanning again

#### Scenario: Host does not answer
- **WHEN** one host does not answer during the scan
- **THEN** the scan exits with code `3`, names the host, and no provisioning skill creates anything from it

### Requirement: Free means free twice
An octet SHALL be offered only when its guest id is unused on every host and its address does not answer ARP from the control plane, and both checks SHALL be repeated right before creating the machine.

#### Scenario: Address taken after the scan
- **WHEN** an address starts answering ARP between the scan and the creation
- **THEN** the creation stops before changing anything

### Requirement: Form limited to what fits
The form SHALL offer only hosts that hold the type's template, octets that are free and sizes that fit the chosen host after headroom, mark the type's defaults and hosts not recommended, keep a free-text option, and never shrink a disk.

#### Scenario: Host with little free memory
- **WHEN** a host has less free memory than the larger size choices
- **THEN** those choices are not offered for that host

### Requirement: Owner never assumed
The machine's owner (system user, full name, email (in `{EMAIL_DOMAINS}` for a `corporate` instance), SSH key and the forge account of that key) SHALL be typed by the operator, never taken from the profile, the machine or an earlier machine; the key SHALL authenticate on the forge as that account before anything is created.

#### Scenario: Key not registered on the forge
- **WHEN** the owner's key does not authenticate on the forge
- **THEN** the skill shows the public key and the forge page to add it, and waits until it authenticates as the confirmed account

#### Scenario: Key with a passphrase
- **WHEN** the named key has a passphrase or its public half does not match
- **THEN** the skill explains why it cannot be used and asks for another key or offers to create one, always ed25519

#### Scenario: Owner key of an older type
- **WHEN** the owner's usable key is RSA or ECDSA
- **THEN** the skill recommends an ed25519 key and offers to create it, but goes on with the existing key if the operator prefers

### Requirement: Secrets typed in dialogs and passed on standard input
The machine's password SHALL be typed twice in a masked dialog and kept in a temporary file with mode `600`; it, the owner's private key and an optional forge token SHALL reach the control plane only on the SSH session's standard input and SHALL NOT be stored there.

#### Scenario: Configuration succeeds
- **WHEN** the machine is configured
- **THEN** the local temporary files holding the password and token are deleted

### Requirement: Forge token checked before use
An optional forge token for the owner SHALL be checked from the operator's machine against the forge API (it must authenticate as the owner and carry the needed scope) before it travels, and SHALL stay on the new machine only in the owner's CLI configuration with mode `600`.

#### Scenario: Token of another user
- **WHEN** the token authenticates as someone other than the owner
- **THEN** it is rejected and nothing is sent

### Requirement: Plan confirmed before creating
The skill SHALL show the infrastructure-as-code plan and create only after the operator's explicit confirmation; a plan that replaces or destroys anything SHALL stop the skill.

#### Scenario: Plan shows a replacement
- **WHEN** the plan would replace an existing machine
- **THEN** the skill stops and creates nothing

### Requirement: One state per machine, never replaced
Each machine SHALL have its own infrastructure state, so creating one never touches another, and the skills SHALL NOT replace or destroy machines.

#### Scenario: Octet already has a machine
- **WHEN** the operator types an octet that already has a machine
- **THEN** the skill refuses it and offers free octets

### Requirement: Configuration and handover
After creation, the skill SHALL configure the machine through the control plane's configuration management and report how to reach it and who owns it, without showing any secret.

#### Scenario: Desktop ready
- **WHEN** a desktop is created and configured
- **THEN** the report gives its name, address and owner, and how to connect, with no password in it
