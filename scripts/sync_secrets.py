#!/usr/bin/env python3
"""Mirror ~/rules/.env into a managed block of ~/.secrets.yaml.

The .env file is the source of truth for every sensitive value the rules
repository uses. This script copies its variables, unchanged, into a block of
~/.secrets.yaml delimited by markers, under the key RULES_ENV, so both files
stay in sync. Nothing outside the markers is touched, values are never
printed, and the file keeps mode 600.

Usage:
    sync_secrets.py            write or refresh the mirror
    sync_secrets.py --check    exit 1 when the mirror is missing or out of date

Exit codes: 0 = in sync (or written), 1 = out of sync (--check) or bad input,
2 = a source file is missing.
"""

import argparse
import os
from pathlib import Path
import re
import shutil
import sys
import time

BEGIN = "# >>> rules .env mirror (managed by ~/rules/scripts/sync_secrets.py; do not edit) >>>"
END = "# <<< rules .env mirror <<<"
KEY_RE = re.compile(r"^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$")


def parse_env(text):
    """Return the variables of a .env file as an ordered list of (key, value)."""
    pairs = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = KEY_RE.match(stripped)
        if not match:
            raise ValueError("line that is not KEY=value")
        key, value = match.group(1), match.group(2).strip()
        if value[:1] in ("'", '"'):
            quote = value[0]
            end = value.find(quote, 1)
            if end == -1:
                raise ValueError(f"unterminated quote in {key}")
            value = value[1:end]
        else:
            value = re.sub(r"\s+#.*$", "", value)
        pairs.append((key, value))
    return pairs


def yaml_quote(value):
    """Quote a value as a YAML double-quoted scalar."""
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def render(pairs):
    lines = [BEGIN, "RULES_ENV:"]
    lines += [f"  {key}: {yaml_quote(value)}" for key, value in pairs]
    lines.append(END)
    return "\n".join(lines) + "\n"


def split(content):
    """Return (before, block, after); block is '' when there is no mirror yet."""
    start = content.find(BEGIN)
    if start == -1:
        return content, "", ""
    end = content.find(END, start)
    if end == -1:
        raise ValueError("mirror start marker without its end marker")
    end += len(END)
    if content[end:end + 1] == "\n":
        end += 1
    return content[:start], content[start:end], content[end:]


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--env", type=Path, default=Path.home() / "rules" / ".env")
    parser.add_argument("--secrets", type=Path, default=Path.home() / ".secrets.yaml")
    parser.add_argument("--check", action="store_true", help="only report whether the mirror is in sync")
    args = parser.parse_args()

    for path in (args.env, args.secrets):
        if not path.is_file():
            print(f"sync_secrets: {path} does not exist", file=sys.stderr)
            return 2
    try:
        pairs = parse_env(args.env.read_text(encoding="utf-8"))
        content = args.secrets.read_text(encoding="utf-8")
        before, block, after = split(content)
    except ValueError as error:
        print(f"sync_secrets: {error}", file=sys.stderr)
        return 1

    wanted = render(pairs)
    if block == wanted:
        print(f"sync_secrets: mirror in sync ({len(pairs)} variables)")
        return 0
    if args.check:
        print("sync_secrets: mirror out of sync; run sync_secrets.py", file=sys.stderr)
        return 1

    backup = args.secrets.with_name(
        f"{args.secrets.name}_{time.strftime('%Y-%m-%dT%H-%M-%S', time.gmtime(time.time() - 6 * 3600))}.bkp")
    shutil.copy2(args.secrets, backup)
    os.chmod(backup, 0o600)

    if not block and before and not before.endswith("\n"):
        before += "\n"
    if not block and before and not before.endswith("\n\n"):
        before += "\n"
    temporary = args.secrets.with_name(args.secrets.name + ".tmp")
    descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
        handle.write(before + wanted + after)
    os.replace(temporary, args.secrets)
    os.chmod(args.secrets, 0o600)
    print(f"sync_secrets: mirrored {len(pairs)} variables into {args.secrets} (backup: {backup.name})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
