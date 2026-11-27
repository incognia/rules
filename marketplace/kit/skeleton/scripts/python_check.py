# -*- coding: utf-8 -*-
"""Refuse to run on a Python without current security patches.

Every entry script starts with:

    import python_check
    python_check.require()

This file is copied unchanged into each plugin's scripts/ folder (plugins
cannot import across folders); CI compares the copies. It uses only syntax
and modules that every Python 3 can import, so an old interpreter prints the
fix-it message instead of a traceback.

Exit codes: 10 = unsupported interpreter.
"""

import os
import sys

# Minimum patch release per supported branch. Branches below the lowest one
# are end of life; branches above the highest one are accepted.
# Current as of November 2026. Check https://www.python.org/downloads/ when you
# instantiate the marketplace and raise every copy together on each security release.
MINIMUMS = {
    (3, 11): 18,
    (3, 12): 16,
    (3, 13): 18,
    (3, 14): 10,
    (3, 15): 2,
}

# Prefix of the instance's environment variables ({ENV_PREFIX}).
ENV_PREFIX = "EXAMPLE_"

EXIT_UNSUPPORTED = 10


def _fmt(branch, patch):
    return "%d.%d.%d" % (branch[0], branch[1], patch)


def status(version=None):
    """Return (ok, reason) for an interpreter version tuple."""
    if version is None:
        version = sys.version_info
    branch = (version[0], version[1])
    lowest = min(MINIMUMS)
    highest = max(MINIMUMS)
    if branch > highest:
        return True, "newer branch"
    if branch < lowest or branch not in MINIMUMS:
        return False, "Python %d.%d is end of life" % branch
    if version[2] < MINIMUMS[branch]:
        return False, "Python %d.%d.%d lacks security fixes (minimum %s)" % (
            version[0], version[1], version[2], _fmt(branch, MINIMUMS[branch]))
    return True, "supported"


def message(reason):
    minimums = ", ".join(_fmt(b, MINIMUMS[b]) for b in sorted(MINIMUMS))
    allow = ENV_PREFIX + "ALLOW_PYTHON"
    lines = [
        "ERROR [python] %s." % reason,
        "  Interpreter: %s" % sys.executable,
        "  Supported minimums: %s (any newer branch is accepted)." % minimums,
        "  Install a supported Python from https://www.python.org/downloads/ or your",
        "  package manager, then run the script with it, for example: python3.14 <script>.",
        "  On macOS, /usr/bin/python3 is the system's older Python: use the installed one.",
        "  Distribution build with backported fixes? Set %s=1; it is a security" % allow,
        "  exception, so record it.",
    ]
    return "\n".join(lines)


def require():
    """Exit with code 10 and a fix-it message on an unsupported interpreter."""
    ok, reason = status()
    if ok:
        return
    if os.environ.get(ENV_PREFIX + "ALLOW_PYTHON") == "1":
        return
    sys.stderr.write(message(reason) + "\n")
    sys.exit(EXIT_UNSUPPORTED)


if __name__ == "__main__":
    require()
    sys.stdout.write('{"python": "%d.%d.%d", "supported": true}\n' % sys.version_info[:3])
