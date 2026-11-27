#!/usr/bin/env python3
"""Example helper: the model talks and decides, the script acts and validates.

Prints one JSON object on standard output and errors on standard error.

Exit codes: 0 = ok, 1 = invalid argument (ERROR [field] reason), 10 = unsupported Python.
"""

import python_check

python_check.require()

import argparse  # noqa: E402
import json  # noqa: E402
import sys  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("name", help="who to greet")
    args = parser.parse_args()
    name = args.name.strip()
    if not name:
        print("ERROR [name] must not be empty", file=sys.stderr)
        return 1
    print(json.dumps({"greeting": f"Hello, {name}"}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
