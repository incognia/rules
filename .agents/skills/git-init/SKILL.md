---
name: git-init
description: "Initialize a git repo with SSH, identity and remote configured. Usage: /git-init <personal|laboral> <key_name> <remote_url> <branch>"
---

# Git init with SSH and identity

## Arguments

- **Context**: $0 (personal or laboral)
- **Key name**: $1 (name of the SSH key in ~/.ssh/, e.g. incognia, promad_ed25519, kone)
- **Remote URL**: $2 (SSH URL, e.g. git@github.com:incognia/repo.git)
- **Branch**: $3 (default branch name, e.g. main)

## Instructions

1. **Read the full CoT**: Load and follow `cot/git_init.md` from line 1 to end
2. **Initialize repo**: `git init`
3. **Configure identity** based on context ($0):
   - If `personal`:
     ```bash
     git config user.name "Rodrigo Álvarez"
     git config user.email "incognia@gmail.com"
     ```
   - If `laboral`:
     ```bash
     git config user.name "Rodrigo Álvarez"
     git config user.email "ralvarez@promad.com.mx"
     ```
4. **Configure SSH key**: `git config core.sshCommand "ssh -i ~/.ssh/$1 -o IdentitiesOnly=yes"`
   - Verify the key exists: `ls ~/.ssh/$1` — if not found, list available keys with `ls ~/.ssh/` and ask the user
5. **Add remote**: `git remote add origin $2`
6. **Set default branch**: `git branch -M $3`
7. **Verify configuration**:
   ```bash
   echo "=== CONFIGURACIÓN ==="
   echo "Email: $(git config user.email)"
   echo "SSH: $(git config core.sshCommand)"
   echo "Remoto: $(git remote get-url origin)"
   echo "Rama: $3"
   echo "====================="
   ```
8. **Confirm**: Verify remote uses SSH (git@), not HTTPS

## Defaults

If arguments are missing, use these defaults based on context:

- **personal**: key=`incognia`, branch=`main`
- **laboral**: key=`promad_ed25519`, branch=`main`

If no arguments are provided at all, ask the user for context and remote URL.

## Examples

- `/git-init personal incognia git@github.com:incognia/myproject.git main`
- `/git-init laboral promad_ed25519 git@gitlab.com:incogniadev/project.git main`
- `/git-init laboral kone git@gitlab.com:incogniadev/project.git main`
- `/git-init personal` — uses defaults, asks for remote URL

## References

- Detailed CoT: `cot/git_init.md`
- Rules: `rulesets/GIT.md`
