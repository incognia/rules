---
name: git-init
description: "Initialize a git repo with SSH, identity and remote configured. Usage: /git-init <personal|laboral> <key_name> <remote_url> <branch>"
---

# Git init with SSH and identity

## Arguments

Same arguments, in the same order, as `~/rules/scripts/git-init-context.sh`:

- **Context**: $0 (`personal` or `laboral`) — required
- **Key name**: $1 (SSH key in `~/.ssh/`; default `incognia` for personal, `kone` for laboral; a value containing `/` is used as a path)
- **Remote URL**: $2 (SSH URL such as `git@github.com:incognia/repo.git` or `ssh://…`; optional, HTTPS is rejected)
- **Branch**: $3 (default branch; default `main`)

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/git_init.md` from line 1 to end
2. **Context guard**: if $0 is missing, ask the user for the context (`personal` or `laboral`) and the remote URL; never run the script without arguments from an agent, because without arguments it becomes interactive.
3. **Run the script non-interactively** from the repository root (or from the empty directory to initialise; the script runs `git init` when needed):

   ```bash
   bash ~/rules/scripts/git-init-context.sh "$0" "$1" "$2" "$3"
   ```

   Omit trailing arguments that were not given; the script applies the defaults above. It configures `user.name`, `user.email`, `core.sshCommand` with the key, the default branch and `origin`, and prints a configuration block.
4. **Check the key warning**: if the script warns that the SSH key does not exist, list available keys with `ls ~/.ssh/` and ask the user which one to use, then run the script again with that key name.
5. **Confirm**: verify in the printed block that the identity matches the context and the remote uses SSH (`git@` or `ssh://`), not HTTPS.

## Examples

- `/git-init personal incognia git@github.com:incognia/myproject.git main`
- `/git-init laboral kone git@gitlab.com:incogniadev/project.git main`
- `/git-init personal` — uses the default key and branch, and asks for the remote URL

## References

- Detailed CoT: `~/rules/cot/git_init.md`
- Rules: `~/rules/rulesets/GIT.md`
- Script: `~/rules/scripts/git-init-context.sh`
