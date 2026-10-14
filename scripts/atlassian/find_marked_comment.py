"""Find the footer-comment thread on a Confluence page whose plain text contains a marker.

Used by /sdd-readiness to locate its previous evaluation. The marker is matched against the
comment's plain text (all text nodes joined), never against the raw ADF JSON: a footer such as
"Automated review with " + code("/sdd-readiness") is split across nodes and would not match.

Usage:
    CONFLUENCE_BASE=... python3 find_marked_comment.py --credentials-stdin <page_id> ["<marker>"]
        reads the e-mail and the API token as two lines on stdin (what confluence-lib.sh does,
        so the token never appears in argv or in the process environment), or
    CONFLUENCE_BASE=... CONFLUENCE_USER_EMAIL=... CONFLUENCE_USER_TOKEN=... \
        python3 find_marked_comment.py <page_id> ["<marker>"]

Prints JSON: {"thread_id": <root comment id of the latest marked comment, or null>,
"last_id": <latest marked comment or reply>, "last_created": <ISO timestamp>,
"count": <marked comments found>}.
"""
import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from adf_lib import plain_text  # noqa: E402

DEFAULT_MARKER = "Automated review with /sdd-readiness"
TIMEOUT = 30


def fail(message):
    print(f"find_marked_comment: {message}", file=sys.stderr)
    sys.exit(2)


class Client:
    def __init__(self, base, user, token):
        self.base = base.rstrip("/")
        self.site = self.base[: -len("/wiki")] if self.base.endswith("/wiki") else self.base
        self.auth = base64.b64encode(f"{user}:{token}".encode()).decode()

    def get(self, url):
        req = urllib.request.Request(
            url, headers={"Authorization": f"Basic {self.auth}", "Accept": "application/json"}
        )
        try:
            with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
                return json.load(resp)
        except urllib.error.HTTPError as exc:
            fail(f"HTTP {exc.code} from Confluence for {url.split('?')[0]}")
        except urllib.error.URLError as exc:
            fail(f"cannot reach Confluence: {exc.reason}")
        except json.JSONDecodeError:
            fail("Confluence returned a response that is not JSON")

    def comments(self, url):
        while url:
            data = self.get(url)
            yield from data.get("results", [])
            nxt = data.get("_links", {}).get("next")
            url = (self.site + nxt) if nxt else None


def is_marked(comment, marker):
    value = comment.get("body", {}).get("atlas_doc_format", {}).get("value") or "{}"
    try:
        return marker in plain_text(json.loads(value))
    except json.JSONDecodeError:
        return False


def created(comment):
    return comment.get("version", {}).get("createdAt", "")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--credentials-stdin", action="store_true",
                        help="read e-mail and API token as two lines on stdin")
    parser.add_argument("page_id")
    parser.add_argument("marker", nargs="?", default=DEFAULT_MARKER)
    args = parser.parse_args()

    base = os.environ.get("CONFLUENCE_BASE", "")
    if args.credentials_stdin:
        lines = sys.stdin.read().splitlines()
        user, token = (lines + ["", ""])[:2]
    else:
        user = os.environ.get("CONFLUENCE_USER_EMAIL", "")
        token = os.environ.get("CONFLUENCE_USER_TOKEN", "")
    if not base or not user or not token:
        fail("missing CONFLUENCE_BASE or credentials (see scripts/atlassian/atlassian-env.sh)")

    client = Client(base, user, token)
    query = "body-format=atlas_doc_format&limit=100"
    # (comment, root id) pairs, so the thread is the one holding the latest marked comment.
    marked = []
    for root in client.comments(f"{client.base}/api/v2/pages/{args.page_id}/footer-comments?{query}"):
        if not is_marked(root, args.marker):
            continue
        marked.append((root, root["id"]))
        children = client.comments(f"{client.base}/api/v2/footer-comments/{root['id']}/children?{query}")
        marked += [(c, root["id"]) for c in children if is_marked(c, args.marker)]
    marked.sort(key=lambda pair: created(pair[0]))
    last, thread_id = marked[-1] if marked else ({}, None)
    print(json.dumps({
        "thread_id": thread_id,
        "last_id": last.get("id"),
        "last_created": last.get("version", {}).get("createdAt"),
        "count": len(marked),
    }))


if __name__ == "__main__":
    main()
