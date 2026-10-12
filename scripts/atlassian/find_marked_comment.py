"""Find the footer-comment thread on a Confluence page whose plain text contains a marker.

Used by /sdd-readiness to locate its previous evaluation. The marker is matched against the
comment's plain text (all text nodes joined), never against the raw ADF JSON: a footer such as
"Automated review with " + code("/sdd-readiness") is split across nodes and would not match.

Usage (credentials come from the environment, see atlassian-env.sh):
    CONFLUENCE_BASE=... CONFLUENCE_USER_EMAIL=... CONFLUENCE_USER_TOKEN=... \
        python3 find_marked_comment.py <page_id> ["<marker>"]

Prints JSON: {"thread_id": <root comment id or null>, "last_id": <latest marked comment or reply>,
"last_created": <ISO timestamp>, "count": <marked comments found>}.
"""
import base64
import json
import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from adf_lib import plain_text  # noqa: E402

DEFAULT_MARKER = "Automated review with /sdd-readiness"


def get(url):
    user = os.environ["CONFLUENCE_USER_EMAIL"]
    token = os.environ["CONFLUENCE_USER_TOKEN"]
    auth = base64.b64encode(f"{user}:{token}".encode()).decode()
    req = urllib.request.Request(url, headers={"Authorization": f"Basic {auth}", "Accept": "application/json"})
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)


def comments(url):
    base = os.environ["CONFLUENCE_BASE"].rstrip("/")
    site = base[: -len("/wiki")] if base.endswith("/wiki") else base
    while url:
        data = get(url)
        yield from data.get("results", [])
        nxt = data.get("_links", {}).get("next")
        url = (site + nxt) if nxt else None


def is_marked(comment, marker):
    value = comment.get("body", {}).get("atlas_doc_format", {}).get("value") or "{}"
    return marker in plain_text(json.loads(value))


def main():
    page_id = sys.argv[1]
    marker = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_MARKER
    base = os.environ["CONFLUENCE_BASE"].rstrip("/")
    query = "body-format=atlas_doc_format&limit=100"
    marked = []
    thread_id = None
    for root in comments(f"{base}/api/v2/pages/{page_id}/footer-comments?{query}"):
        if not is_marked(root, marker):
            continue
        thread_id = thread_id or root["id"]
        marked.append(root)
        marked += [c for c in comments(f"{base}/api/v2/footer-comments/{root['id']}/children?{query}")
                   if is_marked(c, marker)]
    marked.sort(key=lambda c: c.get("version", {}).get("createdAt", ""))
    last = marked[-1] if marked else {}
    print(json.dumps({
        "thread_id": thread_id,
        "last_id": last.get("id"),
        "last_created": last.get("version", {}).get("createdAt"),
        "count": len(marked),
    }))


if __name__ == "__main__":
    main()
