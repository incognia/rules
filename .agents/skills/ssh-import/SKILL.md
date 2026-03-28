---
name: ssh-import
description: "Import SSH public key to a remote server from GitHub. Usage: /ssh-import <faraday|cad> <user@server>"
---

# SSH key import to remote servers

## Arguments

- **Key name**: $0 (faraday for personal servers, cad for client servers)
- **Target**: $1 (user@server, e.g. incognia@192.168.1.100)

## Key mapping

- **faraday** → `~/.ssh/faraday` — personal servers and infra (GitHub user: `incognia`)
- **cad** → `~/.ssh/cad` — client servers (GitHub user: `incogniadev`)

Both keys are published on GitHub and can be imported with `ssh-import-id` or `curl`.

## Instructions

### 1. Determine GitHub user from key name

- If `$0` = `faraday` → GitHub user = `incognia`
- If `$0` = `cad` → GitHub user = `incogniadev`

### 2. Import key to the server

**Option A: server already has the key (Ubuntu auto-import during install)**

If the server was provisioned with the correct GitHub username, just connect:

```bash
ssh -i ~/.ssh/$0 $1
```

**Option B: import to an existing server (requires temporary access)**

```bash
# From the server — if ssh-import-id is available (Ubuntu/Debian)
ssh-import-id gh:GITHUB_USER

# Alternative — curl (any Linux)
curl -s https://github.com/GITHUB_USER.keys >> ~/.ssh/authorized_keys
sort -u -o ~/.ssh/authorized_keys ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

**Option C: provision via cloud-init**

```yaml
ssh_import_id:
  - gh:GITHUB_USER
```

### 3. Verify connection

```bash
ssh -i ~/.ssh/$0 -o IdentitiesOnly=yes $1 "echo 'OK: $(hostname)'"
```

## SSH config shortcut (optional)

```
Host server-alias
    HostName server-ip-or-hostname
    User username
    IdentityFile ~/.ssh/$0
    IdentitiesOnly yes
```

## Examples

- `/ssh-import faraday incognia@proxmox.local` — personal server
- `/ssh-import cad ralvarez@client-server.com` — client server
- `/ssh-import faraday` — shows instructions without connecting
