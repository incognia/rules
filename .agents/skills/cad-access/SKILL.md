---
name: cad-access
description: "Set up SSH access to a client server using the cad key, imported from GitHub. Usage: /cad-access <user@server>"
---

# SSH access to client servers (cad key)

## Purpose

The `cad` key (`~/.ssh/cad`) is exclusively for connecting to client servers — NOT for git repos (use `kone` for repos).

Ubuntu imports public keys from GitHub during installation (`ssh-import-id`). This skill leverages that: the `cad` public key is published at `https://github.com/incogniadev.keys`, so client servers provisioned with Ubuntu can import it automatically without manual copy.

## Arguments

- **Target**: $0 (user@server, e.g. ralvarez@192.168.1.100)

## Instructions

### Option A: server already has your key (Ubuntu auto-import during install)

If the server was installed with your GitHub username (`incogniadev`), the key is already there:

```bash
ssh -i ~/.ssh/cad $0
```

### Option B: import key to an existing server

If you have temporary access (password, another key, or console), import from GitHub:

```bash
# From the client server (if ssh-import-id is available — Ubuntu/Debian)
ssh-import-id gh:incogniadev

# Alternative: curl (works on any Linux)
curl -s https://github.com/incogniadev.keys >> ~/.ssh/authorized_keys
sort -u -o ~/.ssh/authorized_keys ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Then connect from your machine:

```bash
ssh -i ~/.ssh/cad $0
```

### Option C: provision via cloud-init

For VMs provisioned with cloud-init (Proxmox, AWS, etc.), add to the user-data:

```yaml
ssh_import_id:
  - gh:incogniadev
```

### Verification

After setup, verify the connection works:

```bash
ssh -i ~/.ssh/cad -o IdentitiesOnly=yes $0 "echo 'Connection OK: $(hostname)'"
```

## SSH config shortcut (optional)

Add to `~/.ssh/config` for quick access without remembering the key:

```
Host client-name
    HostName server-ip-or-hostname
    User ralvarez
    IdentityFile ~/.ssh/cad
    IdentitiesOnly yes
```

Then just: `ssh client-name`

## Key details

- **Key name**: `cad`
- **Location**: `~/.ssh/cad` (private), `~/.ssh/cad.pub` (public)
- **Published at**: `https://github.com/incogniadev.keys`
- **GitHub user**: `incogniadev`
- **Use**: client server access ONLY (not for git repos)

## Examples

- `/cad-access ralvarez@192.168.1.100`
- `/cad-access root@client-proxmox.local`
- `/cad-access` — shows setup instructions without connecting
