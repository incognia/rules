"""Reusable ADF (Atlassian Document Format) node builders, shared by Jira comments/descriptions and Confluence pages in this repo.

Import it, don't re-derive these builders in a throwaway script:
    import os, sys; sys.path.insert(0, os.path.expanduser("~/rules/scripts/atlassian"))
    from adf_lib import doc, text, p, h, bullet_list, ordered_list, li, panel, code_block, task_list, task_item, mention, table, table_row, table_cell, media_single, write_doc, write_wrapped
    from adf_lib import parse_inline, pp, lip, tc, md_table  # bulk markdown-inline -> ADF helpers, see their docstrings
    from adf_lib import status, decision_list, decision_item, expand, rule, date_node, heading  # used by /sdd-readiness comments

Origin: ops/jira/scripts (promad-cad-all). Gotchas already paid for once:
- `taskItem.content` must be INLINE nodes (text/mention), never a `paragraph` wrapper — unlike `listItem`,
  which DOES need a `paragraph`/block wrapper. `task_item()` below already gets this right.
- Confluence panel `attrs.panelType` accepts info/note/warning/error/success — this is the ADF-native way;
  there is no equivalent "success" macro in classic storage format, don't try to port that constraint here.
- The `title` param of createConfluencePage/updateConfluencePage is a plain string, never an HTML entity
  (`&amp;` renders literally) — that's a caller-side gotcha, not something this library can fix for you.
- **Jira comments/descriptions only** (confirmed NOT an issue on Confluence — `pipelines/{service}/` with
  `["strong","code"]` publishes fine there): the `code` mark cannot be combined with other marks on the
  same text node (e.g. `text("SPEC.md", ["code", "strong"])`) — the `/rest/api/3/issue/{key}/comment`
  endpoint rejects the WHOLE comment with a bare `{"errorMessages":["INVALID_INPUT"]}`, no indication of
  which node caused it. For Jira content, put `code` alone on its own text node; if you also want emphasis,
  use a *separate* adjacent text node with only `["strong"]` (or just drop the emphasis).
"""
import json
import re


_INLINE_RE = re.compile(r"`([^`]+)`|\[([^\]]+)\]\(([^)]+)\)|\*\*([^*]+)\*\*|\*([^*]+)\*")


def parse_inline(md):
    """Split a markdown-inline string into ADF text nodes, translating `code`, [text](url) links,
    **strong** and *em* spans into the matching mark/node. Inside a **strong** span, `code` and [links]
    are split out (see _strong_nodes); `code` there loses the bold on purpose, Jira-safe. Does not handle
    other nested emphasis — for anything fancier, build the text() nodes by hand instead. Meant
    for bulk-converting existing prose (e.g. porting a *_SPEC.md file to a Confluence page) without
    hand-marking every inline span.
    """
    nodes = []
    pos = 0
    for m in _INLINE_RE.finditer(md):
        if m.start() > pos:
            nodes.append(text(md[pos:m.start()]))
        code_span, link_text, link_href, strong_span, em_span = m.groups()
        if code_span is not None:
            nodes.append(text(code_span, ["code"]))
        elif link_href is not None:
            nodes.append(text(link_text, href=link_href))
        elif strong_span is not None:
            nodes.extend(_strong_nodes(strong_span))
        else:
            nodes.append(text(em_span, ["em"]))
        pos = m.end()
    if pos < len(md):
        nodes.append(text(md[pos:]))
    return nodes or [text("")]


_STRONG_INNER_RE = re.compile(r"`([^`]+)`|\[([^\]]+)\]\(([^)]+)\)")


def _strong_nodes(content):
    """Nodes for the inside of a **strong** span. Plain text carries `strong`; a `code` span inside it is
    emitted as `code` ALONE (never combined with strong: Jira rejects that mark combo, and without this
    split the backticks showed up literally in bold text); a [link](url) keeps `strong` + the link mark."""
    def plain(segment):
        # A whitespace-only segment (e.g. the single space between two `code` spans) must NOT carry the
        # strong mark: Confluence drops marked whitespace-only nodes and the two spans render glued together.
        return text(segment, ["strong"] if segment.strip() else None)

    nodes = []
    pos = 0
    for m in _STRONG_INNER_RE.finditer(content):
        if m.start() > pos:
            nodes.append(plain(content[pos:m.start()]))
        code_span, link_text, link_href = m.groups()
        if code_span is not None:
            nodes.append(text(code_span, ["code"]))
        else:
            nodes.append(text(link_text, ["strong"], href=link_href))
        pos = m.end()
    if pos < len(content):
        nodes.append(plain(content[pos:]))
    return nodes or [text(content, ["strong"])]


def pp(md):
    """A paragraph built from a single markdown-inline string via parse_inline()."""
    return {"type": "paragraph", "content": parse_inline(md)}


def lip(md):
    """A bullet/ordered list item built from a single markdown-inline string via parse_inline()."""
    return {"type": "listItem", "content": [pp(md)]}


def tc(md, header=False):
    """A table cell built from a single markdown-inline string via parse_inline()."""
    return {"type": "tableHeader" if header else "tableCell", "attrs": {}, "content": [pp(md)]}


def md_table(rows, header=True):
    """rows: list of list-of-markdown-strings (first row is the header if header=True)."""
    trows = []
    for i, row in enumerate(rows):
        is_header = header and i == 0
        trows.append({"type": "tableRow", "content": [tc(cell, header=is_header) for cell in row]})
    return {"type": "table", "attrs": {"isNumberColumnEnabled": False, "layout": "default"}, "content": trows}


def text(t, marks=None, href=None):
    node = {"type": "text", "text": t}
    m = []
    if marks:
        m += [{"type": x} for x in marks]
    if href:
        m.append({"type": "link", "attrs": {"href": href}})
    if m:
        node["marks"] = m
    return node


def mention(account_id, display_name):
    return {"type": "mention", "attrs": {"id": account_id, "text": f"@{display_name}", "accessLevel": ""}}


def p(*content):
    return {"type": "paragraph", "content": list(content)}


def h(level, t):
    return {"type": "heading", "attrs": {"level": level}, "content": [text(t)]}


def li(*content):
    """A bullet/ordered list item — content is wrapped in a paragraph, as ADF requires."""
    return {"type": "listItem", "content": [p(*content)]}


def bullet_list(items):
    return {"type": "bulletList", "content": items}


def ordered_list(items):
    return {"type": "orderedList", "content": items}


def task_item(idx, *inline_content, state="TODO"):
    """A checklist item — content must be INLINE nodes (text/mention), never a paragraph."""
    return {"type": "taskItem", "attrs": {"localId": f"task-{idx}", "state": state}, "content": list(inline_content)}


def task_list(items, local_id="checklist-1"):
    return {"type": "taskList", "attrs": {"localId": local_id}, "content": items}


def panel(panel_type, *content):
    """panel_type: info | note | warning | error | success"""
    return {"type": "panel", "attrs": {"panelType": panel_type}, "content": list(content)}


def code_block(text_, language=None):
    node = {"type": "codeBlock", "content": [{"type": "text", "text": text_}]}
    if language:
        node["attrs"] = {"language": language}
    return node


def table_cell(*content, header=False):
    return {"type": "tableHeader" if header else "tableCell", "attrs": {}, "content": [p(*content)]}


def table_row(*cells):
    return {"type": "tableRow", "content": list(cells)}


def table(header_row, *rows):
    """header_row: a tableRow built with table_cell(..., header=True) cells. rows: tableRow(...) each."""
    return {"type": "table", "attrs": {"isNumberColumnEnabled": False, "layout": "default"}, "content": [header_row, *rows]}


def media_single(file_id, collection, width=760, layout="center"):
    return {
        "type": "mediaSingle",
        "attrs": {"layout": layout},
        "content": [{"type": "media", "attrs": {"type": "file", "id": file_id, "collection": collection, "width": width}}],
    }


def doc(*content):
    return {"type": "doc", "version": 1, "content": list(content)}


def write_doc(adf_doc, path):
    """Plain ADF doc, for Confluence's contentFormat:"adf" or confluence_update_page_adf."""
    with open(path, "w") as f:
        json.dump(adf_doc, f, ensure_ascii=False, separators=(",", ":"))


def write_wrapped(adf_doc, field_name, path):
    """{field_name: doc} wrapper for jira_process_adf_content. field_name is "body" for comment/edit-comment,
    "description" for update-description — NOT a free-form label; jira-lib.sh looks up this exact key."""
    with open(path, "w") as f:
        json.dump({field_name: adf_doc}, f, ensure_ascii=False, separators=(",", ":"))

# ==================== Nodos adicionales (comentarios de /sdd-readiness) ====================


def status(label, color="neutral"):
    """Inline lozenge. color: neutral | purple | blue | red | yellow | green."""
    return {"type": "status", "attrs": {"text": label, "color": color}}


def decision_item(local_id, *inline_content, state="UNDECIDED"):
    """A decision — like taskItem, content must be INLINE nodes. state: DECIDED | UNDECIDED."""
    return {"type": "decisionItem", "attrs": {"localId": local_id, "state": state}, "content": list(inline_content)}


def decision_list(items, local_id="decisions-1"):
    return {"type": "decisionList", "attrs": {"localId": local_id}, "content": items}


def expand(title, *content):
    """Collapsible section. Cannot contain another expand or a panel with an expand inside."""
    return {"type": "expand", "attrs": {"title": title}, "content": list(content)}


def rule():
    return {"type": "rule"}


def date_node(timestamp_ms):
    """Inline date; timestamp in epoch milliseconds (UTC midnight of the day is the usual convention)."""
    return {"type": "date", "attrs": {"timestamp": str(timestamp_ms)}}


def heading(level, *content):
    """Heading with arbitrary inline content (h() only takes plain text)."""
    return {"type": "heading", "attrs": {"level": level}, "content": list(content)}


def plain_text(node):
    """Concatenated text of an ADF node and its children (text nodes plus mention labels).
    Use it to search comment bodies: inline marks split a sentence across several text nodes."""
    if isinstance(node, list):
        return "".join(plain_text(n) for n in node)
    if not isinstance(node, dict):
        return ""
    if node.get("type") == "text":
        return node.get("text", "")
    if node.get("type") == "mention":
        return node.get("attrs", {}).get("text", "")
    return "".join(plain_text(c) for c in node.get("content", []) or [])
