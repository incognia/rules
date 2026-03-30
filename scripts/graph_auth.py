#!/usr/bin/env python3
"""
Microsoft Graph API authentication with token caching.

Usage:
    import graph_auth
    token = graph_auth.get_token()

Token lifecycle:
    1. Reuse cached access_token if still valid
    2. Use refresh_token to get a new access_token silently (~90 days)
    3. Fall back to device code flow only if refresh_token expired

Token cache: ~/.graph_tokens.json
Credentials: ~/.secrets.yaml under GRAPH_API key
"""

import urllib.request
import urllib.parse
import urllib.error
import json
import os
import re
import time

TOKEN_CACHE = os.path.expanduser("~/.graph_tokens.json")
SECRETS_FILE = os.path.expanduser("~/.secrets.yaml")
SCOPE = "https://graph.microsoft.com/Mail.Send"


def _read_secrets():
    """Read CLIENT_ID and TENANT_ID from ~/.secrets.yaml."""
    with open(SECRETS_FILE) as f:
        content = f.read()
    block = content.split("GRAPH_API:")[1].split("\n\n")[0]
    client_id = re.search(r"CLIENT_ID:\s*(\S+)", block).group(1)
    tenant_id = re.search(r"TENANT_ID:\s*(\S+)", block).group(1)
    return client_id, tenant_id


def _load_cache():
    """Load cached tokens from disk."""
    if os.path.exists(TOKEN_CACHE):
        with open(TOKEN_CACHE) as f:
            return json.load(f)
    return {}


def _save_cache(data):
    """Save tokens to disk."""
    with open(TOKEN_CACHE, "w") as f:
        json.dump(data, f)
    os.chmod(TOKEN_CACHE, 0o600)


def _token_valid(cache):
    """Check if access_token is still valid (with 5 min margin)."""
    expires_at = cache.get("expires_at", 0)
    return time.time() < (expires_at - 300)


def _refresh_token(client_id, tenant_id, refresh_token):
    """Use refresh_token to get a new access_token silently."""
    data = urllib.parse.urlencode({
        "grant_type": "refresh_token",
        "client_id": client_id,
        "refresh_token": refresh_token,
        "scope": SCOPE,
    }).encode()
    req = urllib.request.Request(
        f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token", data
    )
    try:
        resp = json.loads(urllib.request.urlopen(req).read())
        if "access_token" in resp:
            return resp
    except urllib.error.HTTPError:
        pass
    return None


def _device_code_flow(client_id, tenant_id):
    """Authenticate via device code flow (requires browser interaction)."""
    data = urllib.parse.urlencode({
        "client_id": client_id,
        "scope": SCOPE,
    }).encode()
    req = urllib.request.Request(
        f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/devicecode", data
    )
    resp = json.loads(urllib.request.urlopen(req).read())
    print(resp["message"])
    device_code = resp["device_code"]
    interval = resp.get("interval", 5)

    print("Esperando autenticación...")
    for _ in range(60):
        time.sleep(interval)
        try:
            tdata = urllib.parse.urlencode({
                "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
                "client_id": client_id,
                "device_code": device_code,
            }).encode()
            treq = urllib.request.Request(
                f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token",
                tdata,
            )
            tresp = json.loads(urllib.request.urlopen(treq).read())
            if "access_token" in tresp:
                print("Token obtenido OK")
                return tresp
        except urllib.error.HTTPError as e:
            err = json.loads(e.read())
            if err.get("error") == "authorization_pending":
                continue
            print(f"Error: {err.get('error_description', '')}")
            break
    return None


def get_token():
    """
    Get a valid access_token. Uses cache, refresh, or device code flow.
    Returns the access_token string or raises SystemExit on failure.
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
    resp = _device_code_flow(client_id, tenant_id)
    if resp:
        resp["expires_at"] = time.time() + resp.get("expires_in", 3600)
        _save_cache(resp)
        return resp["access_token"]

    raise SystemExit("No se pudo obtener token de acceso")
