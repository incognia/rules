---
name: ssh-import
description: "Import SSH public key from GitHub into the current server. Run from within the server. Usage: /ssh-import <faraday|cad>"
---

# SSH key import (run from within the server)

## Argument

- **Key name**: $0 (faraday for personal servers, cad for client servers)

## Key mapping

- **faraday** → GitHub user `incognia` (personal servers and infra)
- **cad** → GitHub user `incogniadev` (client servers)

## Instructions

### 1. Determine GitHub user from key name

- If `$0` = `faraday` → `GITHUB_USER=incognia`
- If `$0` = `cad` → `GITHUB_USER=incogniadev`

### 2. Detect current user and home

```bash
SHELL_USER=$(whoami)
SHELL_HOME=$(eval echo ~$SHELL_USER)
echo "Importing key for user: $SHELL_USER ($SHELL_HOME)"
```

### 3. Import the key

**Option A: ssh-import-id (Ubuntu/Debian)**

```bash
ssh-import-id gh:GITHUB_USER
```

**Option B: curl (any Linux, including Fedora/RHEL)**

```bash
mkdir -p "$SHELL_HOME/.ssh" && chmod 700 "$SHELL_HOME/.ssh"
curl -s "https://github.com/GITHUB_USER.keys" >> "$SHELL_HOME/.ssh/authorized_keys"
sort -u -o "$SHELL_HOME/.ssh/authorized_keys" "$SHELL_HOME/.ssh/authorized_keys"
chmod 600 "$SHELL_HOME/.ssh/authorized_keys"
```

### 4. Verify the key was added

```bash
echo "User: $SHELL_USER"
echo "Keys in authorized_keys: $(grep -c 'ssh-ed25519' "$SHELL_HOME/.ssh/authorized_keys")"
```

## For cloud-init provisioning (before install)

```yaml
ssh_import_id:
  - gh:GITHUB_USER
```

## Examples

- `/ssh-import faraday` — import personal key (from gh:incognia)
- `/ssh-import cad` — import work key (from gh:incogniadev)
