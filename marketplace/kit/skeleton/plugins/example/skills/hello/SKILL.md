---
name: hello
description: "EN: Greet someone through the plugin's helper script; a template for a skill that runs inline in the main session. Usage: /example:hello <name>. ES: Saluda a alguien con el script de apoyo del plugin; plantilla de una skill que corre en línea en la sesión principal. Uso: /example:hello <nombre>."
argument-hint: "<name>"
---

# Hello (inline skill template)

> **Execution:** this skill runs inline in the main session. Use this shape whenever the skill needs the conversation history or must act as the session's own model (a commit skill, for example, never runs in a fork: its co-author trailer reads the main session).

Arguments: `$ARGUMENTS`

## Instructions

1. If no name was given, show the usage `/example:hello <name>` and stop.
2. Read `${CLAUDE_PLUGIN_ROOT}/references/STYLE.md` for the greeting rules. A relative Markdown link does not work here; always name the full path.
3. Run the helper with the full path in the same command, because `${CLAUDE_PLUGIN_ROOT}` is substituted in this file but is not an environment variable inside Bash:

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/scripts/hello.py" "<name>"
   ```

4. Read the JSON it prints. On a non-zero exit, read `ERROR [field] reason` on standard error and ask only for that field again. Exit code `10` means an unsupported Python: relay its fix-it message.
5. Report the greeting in the user's conversation language.

## Rules

- The script acts and validates; you talk and decide. Never rebuild its logic in the conversation.
- Never ask for a secret in the conversation and never print one.
- Show a draft and wait for explicit confirmation before any outward or destructive action.
