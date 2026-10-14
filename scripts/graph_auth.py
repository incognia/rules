#!/usr/bin/env python3
"""
Microsoft Graph API authentication with token caching.

Usage:
    import graph_auth
    token = graph_auth.get_token()                    # may start the device code flow
    token = graph_auth.get_token(interactive=False)   # raises SystemExit instead

    python3 graph_auth.py    # /mail token: authenticate once and fill the cache

Token lifecycle:
    1. Reuse cached access_token if still valid
    2. Use refresh_token to get a new access_token silently (~90 days); the
       offline_access scope is what makes Microsoft issue a refresh_token
    3. Fall back to device code flow only if there is no valid refresh_token

Token cache: ~/.graph_tokens.json (created with mode 600, never printed)
Credentials: ~/.secrets.yaml under GRAPH_API key (CLIENT_ID and TENANT_ID)
"""

import urllib.request
import urllib.parse
import urllib.error
import json
import os
import re
import sys
import time

TOKEN_CACHE = os.path.expanduser("~/.graph_tokens.json")
SECRETS_FILE = os.path.expanduser("~/.secrets.yaml")
SCOPE = "offline_access https://graph.microsoft.com/Mail.Send"
TIMEOUT = 30


def _post(url, fields):
    """POST a form and return the decoded JSON response (raises urllib errors)."""
    data = urllib.parse.urlencode(fields).encode()
    req = urllib.request.Request(url, data)
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        return json.loads(resp.read())


def _read_secrets():
    """Read CLIENT_ID and TENANT_ID from ~/.secrets.yaml."""
    try:
        with open(SECRETS_FILE) as f:
            content = f.read()
    except OSError as exc:
        raise SystemExit(f"Cannot read {SECRETS_FILE}: {exc.strerror}")
    match = re.search(r"^GRAPH_API:[ \t]*\n((?:[ \t]+.*\n?|[ \t]*\n)*)", content, re.MULTILINE)
    block = match.group(1) if match else ""
    values = {}
    for key in ("CLIENT_ID", "TENANT_ID"):
        found = re.search(rf"^[ \t]+{key}:[ \t]*[\"']?([^\s\"'#]+)", block, re.MULTILINE)
        if not found:
            raise SystemExit(f"Missing GRAPH_API.{key} in {SECRETS_FILE}")
        values[key] = found.group(1)
    return values["CLIENT_ID"], values["TENANT_ID"]


def _load_cache():
    """Load cached tokens from disk."""
    try:
        with open(TOKEN_CACHE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def _save_cache(data):
    """Save tokens to disk; the file is created with mode 600, never world-readable."""
    fd = os.open(TOKEN_CACHE, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    os.fchmod(fd, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(data, f)


def _token_valid(cache):
    """Check if access_token is still valid (with 5 min margin)."""
    expires_at = cache.get("expires_at", 0)
    return time.time() < (expires_at - 300)


def _refresh_token(client_id, tenant_id, refresh_token):
    """Use refresh_token to get a new access_token silently."""
    try:
        resp = _post(
            f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token",
            {
                "grant_type": "refresh_token",
                "client_id": client_id,
                "refresh_token": refresh_token,
                "scope": SCOPE,
            },
        )
    except (urllib.error.URLError, ValueError):
        return None
    if "access_token" not in resp:
        return None
    # Microsoft normally rotates the refresh_token; keep the old one if it does not.
    resp.setdefault("refresh_token", refresh_token)
    return resp


def _device_code_flow(client_id, tenant_id):
    """Authenticate via device code flow (requires browser interaction)."""
    base = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0"
    try:
        resp = _post(f"{base}/devicecode", {"client_id": client_id, "scope": SCOPE})
    except urllib.error.HTTPError as exc:
        print(f"Device code request failed: HTTP {exc.code}", file=sys.stderr)
        return None
    except urllib.error.URLError as exc:
        print(f"Cannot reach Microsoft login: {exc.reason}", file=sys.stderr)
        return None
    print(resp["message"])
    device_code = resp["device_code"]
    interval = int(resp.get("interval", 5))
    deadline = time.time() + int(resp.get("expires_in", 900))

    print("Waiting for authentication...")
    while time.time() < deadline:
        time.sleep(interval)
        try:
            tresp = _post(
                f"{base}/token",
                {
                    "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
                    "client_id": client_id,
                    "device_code": device_code,
                },
            )
        except urllib.error.HTTPError as exc:
            try:
                err = json.loads(exc.read())
            except ValueError:
                err = {}
            if err.get("error") == "authorization_pending":
                continue
            if err.get("error") == "slow_down":
                interval += 5
                continue
            print(f"Error: {err.get('error_description', f'HTTP {exc.code}')}", file=sys.stderr)
            return None
        except urllib.error.URLError as exc:
            print(f"Cannot reach Microsoft login: {exc.reason}", file=sys.stderr)
            return None
        if "access_token" in tresp:
            print("Token obtained")
            return tresp
    print("Device code expired before authentication", file=sys.stderr)
    return None


def get_token(interactive=True):
    """
    Get a valid access_token. Uses cache, refresh, or (when interactive) the
    device code flow. Returns the access_token string or raises SystemExit.
    """
    client_id, tenant_id = _read_secrets()
    cache = _load_cache()

    # 1. Reuse cached token if valid
    if _token_valid(cache):
        return cache["access_token"]

    # 2. Try refresh_token
    if cache.get("refresh_token"):
        resp = _refresh_token(client_id, tenant_id, cache["refresh_token"])
        if resp:
            resp["expires_at"] = time.time() + resp.get("expires_in", 3600)
            _save_cache(resp)
            return resp["access_token"]

    # 3. Fall back to device code flow
    if not interactive:
        raise SystemExit("No valid Graph token cached; run /mail token (python3 graph_auth.py) first")
    resp = _device_code_flow(client_id, tenant_id)
    if resp:
        resp["expires_at"] = time.time() + resp.get("expires_in", 3600)
        _save_cache(resp)
        return resp["access_token"]

    raise SystemExit("Could not obtain an access token")


def main():
    """Authenticate (if needed) and report the cache state without printing tokens."""
    get_token(interactive=True)
    cache = _load_cache()
    remaining = int((cache.get("expires_at", 0) - time.time()) / 60)
    refresh = "yes" if cache.get("refresh_token") else "no"
    print(f"Graph token cached in {TOKEN_CACHE}: access token valid for ~{remaining} min, refresh token: {refresh}")


if __name__ == "__main__":
    main()
