#!/bin/bash

# =============================================================================
# CONFLUENCE LIBRARY - Function library for the Confluence REST API (v1 and v2)
# =============================================================================
# Author: Rodrigo Álvarez
# Purpose: reusable library to publish and update pages, attach images
#          (Mermaid diagrams rendered to PNG) and post ADF footer comments in
#          Confluence, with the credentials loaded by atlassian-env.sh (the same
#          Atlassian account works for Jira and Confluence).
#
# Security notes:
#   - The credential never appears on a command line: every request goes
#     through _confluence_curl, which feeds it to curl as a config file on
#     stdin (printf is a shell builtin, so no process exposes it in `ps`).
#   - Every request uses --fail-with-body (or --fail on old curl), so HTTP
#     errors such as 401, 403 or 409 return a non-zero status while the
#     response body is still printed for diagnosis.
#   - Temporary files are created with mktemp without a suffix (BSD mktemp
#     only substitutes trailing Xs) and removed after each call.
# =============================================================================

CONFLUENCE_LIB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$CONFLUENCE_LIB_SCRIPT_DIR/atlassian-env.sh" ]]; then
    # shellcheck source=atlassian-env.sh
    source "$CONFLUENCE_LIB_SCRIPT_DIR/atlassian-env.sh"
fi

# ==================== CONFIGURATION ====================

CONFLUENCE_USER_EMAIL="${JIRA_USER_EMAIL:-${JIRA_EMAIL:-}}"
CONFLUENCE_USER_TOKEN="${JIRA_USER_TOKEN:-${JIRA_TOKEN:-}}"
CONFLUENCE_BASE="${CONFLUENCE_BASE:-}"  # required: set it in .env (https://<site>.atlassian.net/wiki)
CONFLUENCE_BASE="${CONFLUENCE_BASE%/}"

# --fail-with-body needs curl >= 7.76; fall back to --fail on older versions.
if curl --help all 2>/dev/null | grep -q -- '--fail-with-body'; then
    CONFLUENCE_CURL_FAIL_FLAG="--fail-with-body"
else
    CONFLUENCE_CURL_FAIL_FLAG="--fail"
fi

confluence_check_credentials() {
    if [[ -z "$CONFLUENCE_USER_EMAIL" || -z "$CONFLUENCE_USER_TOKEN" ]]; then
        echo "❌ Missing credentials. Set JIRA_USER_EMAIL and JIRA_USER_TOKEN in .env (the same ones used for Jira)." >&2
        return 1
    fi
    if [[ -z "$CONFLUENCE_BASE" ]]; then
        echo "❌ Missing CONFLUENCE_BASE in .env (https://<site>.atlassian.net/wiki)." >&2
        return 1
    fi
    return 0
}

# ==================== INTERNAL HELPERS ====================

# Single entry point for every HTTP request. Arguments are passed to curl.
# The credential travels on stdin as a curl config line, never in argv.
# Callers must not use stdin themselves (no --data @-).
_confluence_curl() {
    local cred="${CONFLUENCE_USER_EMAIL}:${CONFLUENCE_USER_TOKEN}"
    cred="${cred//\\/\\\\}"
    cred="${cred//\"/\\\"}"
    printf 'user = "%s"\n' "$cred" | curl -sS "$CONFLUENCE_CURL_FAIL_FLAG" --config - "$@"
}

# Create a private temporary file or directory (no suffix after the Xs).
_confluence_tmp_base() {
    local base="${TMPDIR:-/tmp}"
    printf '%s' "${base%/}"
}

_confluence_mktemp() {
    mktemp "$(_confluence_tmp_base)/confluence-$1.XXXXXX"
}

# Report a failed request on stderr and pass the status through.
_confluence_report() {
    local rc="$1" what="$2"
    if (( rc != 0 )); then
        echo "❌ Confluence request failed: $what (curl exit $rc; HTTP 409 means a version conflict, 401/403 a credential or permission problem)" >&2
    fi
    return "$rc"
}

# Send a JSON payload file and remove it afterwards.
# Usage: _confluence_send_json <METHOD> <url> <payload_file> <description>
_confluence_send_json() {
    local method="$1" url="$2" payload_file="$3" what="$4" result rc
    result=$(_confluence_curl -X "$method" -H "Content-Type: application/json" \
        --data-binary @"$payload_file" "$url")
    rc=$?
    rm -f "$payload_file"
    printf '%s\n' "$result"
    _confluence_report "$rc" "$what"
}

# GET every page of a v2 collection, following _links.next, and print
# {"results": [...], "size": N}.
_confluence_get_all() {
    local url="$1" what="$2" site tmp_dir page_file next rc n=0
    site="${CONFLUENCE_BASE%/wiki}"
    tmp_dir=$(mktemp -d "$(_confluence_tmp_base)/confluence-pages.XXXXXX") || return 1
    while [[ -n "$url" ]]; do
        n=$((n + 1))
        page_file="$tmp_dir/$(printf '%05d' "$n").json"
        _confluence_curl "$url" > "$page_file"
        rc=$?
        if (( rc != 0 )); then
            cat "$page_file"
            rm -rf "$tmp_dir"
            _confluence_report "$rc" "$what"
            return
        fi
        next=$(jq -r '._links.next // empty' "$page_file") || { rm -rf "$tmp_dir"; return 1; }
        url="${next:+$site$next}"
    done
    jq -s '{results: (map(.results // []) | add // []), size: (map(.results // [] | length) | add // 0)}' \
        "$tmp_dir"/*.json
    rc=$?
    rm -rf "$tmp_dir"
    return "$rc"
}

# Print the next version number of a page (current + 1).
_confluence_next_version() {
    local page_id="$1" page version
    if ! page=$(confluence_get_page_body "$page_id"); then
        printf '%s\n' "$page" >&2
        return 1
    fi
    if ! version=$(jq -er '.version.number' <<< "$page" 2>/dev/null); then
        echo "❌ Could not read the current version of page $page_id" >&2
        return 1
    fi
    echo $((version + 1))
}

# ==================== PAGES ====================

# Get the current body (storage/XHTML) and version.number of a page
# Usage: confluence_get_page_body '<page_id>'
confluence_get_page_body() {
    local page_id="${1:-}"
    confluence_check_credentials || return 1
    if [[ -z "$page_id" ]]; then
        echo "❌ Usage: confluence_get_page_body '<page_id>'" >&2
        return 1
    fi
    _confluence_curl "$CONFLUENCE_BASE/rest/api/content/$page_id?expand=body.storage,version"
    _confluence_report $? "get page $page_id"
}

# Replace the whole body (storage/XHTML) of an existing page
# Usage: confluence_update_page_body '<page_id>' '<title>' '<body_html_file>'
confluence_update_page_body() {
    local page_id="${1:-}" title="${2:-}" body_file="${3:-}"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || -z "$title" || ! -f "$body_file" ]]; then
        echo "❌ Usage: confluence_update_page_body '<page_id>' '<title>' '<body_html_file>'" >&2
        return 1
    fi

    local next_version payload_file
    next_version=$(_confluence_next_version "$page_id") || return 1
    # Unique temporary file per call: never a fixed path in /tmp, which a
    # concurrent session could overwrite halfway through.
    payload_file=$(_confluence_mktemp update-payload) || return 1

    if ! python3 - "$page_id" "$title" "$body_file" "$next_version" "$payload_file" << 'PYEOF'
import json, sys
page_id, title, body_file, next_version, out_path = sys.argv[1:6]
with open(body_file) as f:
    body = f.read()
payload = {
    "version": {"number": int(next_version)},
    "type": "page",
    "title": title,
    "body": {"storage": {"value": body, "representation": "storage"}},
}
with open(out_path, "w") as f:
    json.dump(payload, f)
PYEOF
    then
        rm -f "$payload_file"
        return 1
    fi

    _confluence_send_json PUT "$CONFLUENCE_BASE/rest/api/content/$page_id" "$payload_file" "update page $page_id"
}

# Replace the whole body of an existing page with native ADF (API v1,
# body.atlas_doc_format): the right path for pages already migrated to ADF.
# Build the ADF file beforehand (scripts/atlassian/adf_lib.py); it is uploaded
# from the file, never pasted as a literal argument.
# Usage: confluence_update_page_adf '<page_id>' '<title>' '<adf_file.json>'
#   adf_file.json: the full ADF document (`{"type":"doc","version":1,...}`),
#   e.g. written with adf_lib.write_doc(), NOT wrapped in {"body": ...}.
confluence_update_page_adf() {
    local page_id="${1:-}" title="${2:-}" adf_file="${3:-}"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || -z "$title" || ! -f "$adf_file" ]]; then
        echo "❌ Usage: confluence_update_page_adf '<page_id>' '<title>' '<adf_file.json>'" >&2
        return 1
    fi

    local next_version payload_file
    next_version=$(_confluence_next_version "$page_id") || return 1
    payload_file=$(_confluence_mktemp adf-payload) || return 1

    if ! python3 - "$adf_file" "$title" "$next_version" "$payload_file" << 'PYEOF'
import json, sys
adf_file, title, next_version, out_path = sys.argv[1:5]
with open(adf_file) as f:
    adf_doc = json.load(f)
payload = {
    "version": {"number": int(next_version)},
    "type": "page",
    "title": title,
    "body": {
        "atlas_doc_format": {
            "value": json.dumps(adf_doc, ensure_ascii=False),
            "representation": "atlas_doc_format",
        }
    },
}
with open(out_path, "w") as f:
    json.dump(payload, f, ensure_ascii=False)
PYEOF
    then
        rm -f "$payload_file"
        return 1
    fi

    _confluence_send_json PUT "$CONFLUENCE_BASE/rest/api/content/$page_id" "$payload_file" "update page $page_id (ADF)"
}

# Create a new page with native ADF (API v1, body.atlas_doc_format): the
# fallback when the MCP connector (createConfluencePage) is blocked on the
# instance (403 "The app is not installed on this instance").
# Usage: confluence_create_page_adf '<space_key>' '<parent_id>' '<title>' '<adf_file.json>'
#   adf_file.json: the full ADF document, NOT wrapped in {"body": ...}.
confluence_create_page_adf() {
    local space_key="${1:-}" parent_id="${2:-}" title="${3:-}" adf_file="${4:-}"
    confluence_check_credentials || return 1

    if [[ -z "$space_key" || -z "$parent_id" || -z "$title" || ! -f "$adf_file" ]]; then
        echo "❌ Usage: confluence_create_page_adf '<space_key>' '<parent_id>' '<title>' '<adf_file.json>'" >&2
        return 1
    fi

    local payload_file
    payload_file=$(_confluence_mktemp create-payload) || return 1

    if ! python3 - "$adf_file" "$title" "$space_key" "$parent_id" "$payload_file" << 'PYEOF'
import json, sys
adf_file, title, space_key, parent_id, out_path = sys.argv[1:6]
with open(adf_file) as f:
    adf_doc = json.load(f)
payload = {
    "type": "page",
    "title": title,
    "space": {"key": space_key},
    "ancestors": [{"id": str(parent_id)}],
    "body": {
        "atlas_doc_format": {
            "value": json.dumps(adf_doc, ensure_ascii=False),
            "representation": "atlas_doc_format",
        }
    },
}
with open(out_path, "w") as f:
    json.dump(payload, f, ensure_ascii=False)
PYEOF
    then
        rm -f "$payload_file"
        return 1
    fi

    _confluence_send_json POST "$CONFLUENCE_BASE/rest/api/content" "$payload_file" "create page '$title'"
}

# ==================== FOOTER COMMENTS (API v2, ADF) ====================

# List every footer comment of a page (all result pages), with ADF bodies
# Usage: confluence_get_footer_comments '<page_id>'
confluence_get_footer_comments() {
    local page_id="${1:-}"
    confluence_check_credentials || return 1
    if [[ -z "$page_id" ]]; then
        echo "❌ Usage: confluence_get_footer_comments '<page_id>'" >&2
        return 1
    fi
    _confluence_get_all "$CONFLUENCE_BASE/api/v2/pages/$page_id/footer-comments?body-format=atlas_doc_format&limit=100" \
        "footer comments of page $page_id"
}

# List every reply of a footer comment (all result pages)
# Usage: confluence_get_comment_children '<comment_id>'
confluence_get_comment_children() {
    local comment_id="${1:-}"
    confluence_check_credentials || return 1
    if [[ -z "$comment_id" ]]; then
        echo "❌ Usage: confluence_get_comment_children '<comment_id>'" >&2
        return 1
    fi
    _confluence_get_all "$CONFLUENCE_BASE/api/v2/footer-comments/$comment_id/children?body-format=atlas_doc_format&limit=100" \
        "replies of comment $comment_id"
}

# Post a new footer comment, or a reply in a thread, from an ADF file.
# Usage: confluence_add_footer_comment_adf page  '<page_id>'    '<adf_file.json>'
#        confluence_add_footer_comment_adf reply '<comment_id>' '<adf_file.json>'
#   adf_file.json: full ADF document (`{"type":"doc","version":1,...}`), e.g.
#   written with adf_lib.write_doc(); never paste the JSON as a literal argument.
confluence_add_footer_comment_adf() {
    local mode="${1:-}" target_id="${2:-}" adf_file="${3:-}"
    confluence_check_credentials || return 1

    if [[ ! "$mode" =~ ^(page|reply)$ || -z "$target_id" || ! -f "$adf_file" ]]; then
        echo "❌ Usage: confluence_add_footer_comment_adf <page|reply> '<page_id|comment_id>' '<adf_file.json>'" >&2
        return 1
    fi

    local payload_file
    payload_file=$(_confluence_mktemp comment-payload) || return 1

    if ! python3 - "$mode" "$target_id" "$adf_file" "$payload_file" << 'PYEOF'
import json, sys
mode, target_id, adf_file, out_path = sys.argv[1:5]
with open(adf_file) as f:
    adf_doc = json.load(f)
payload = {"body": {"representation": "atlas_doc_format", "value": json.dumps(adf_doc, ensure_ascii=False)}}
payload["pageId" if mode == "page" else "parentCommentId"] = str(target_id)
with open(out_path, "w") as f:
    json.dump(payload, f, ensure_ascii=False)
PYEOF
    then
        rm -f "$payload_file"
        return 1
    fi

    _confluence_send_json POST "$CONFLUENCE_BASE/api/v2/footer-comments" "$payload_file" "post $mode comment on $target_id"
}

# Find the footer-comment thread whose plain text contains a marker (by
# default, the /sdd-readiness footer).
# Usage: confluence_find_marked_comment '<page_id>' ['<marker>']
# Prints JSON: {"thread_id", "last_id", "last_created", "count"}
# The credential is passed to Python on stdin, not through its environment.
confluence_find_marked_comment() {
    local page_id="${1:-}" marker="${2:-Automated review with /sdd-readiness}"
    confluence_check_credentials || return 1
    if [[ -z "$page_id" ]]; then
        echo "❌ Usage: confluence_find_marked_comment '<page_id>' ['<marker>']" >&2
        return 1
    fi
    printf '%s\n%s\n' "$CONFLUENCE_USER_EMAIL" "$CONFLUENCE_USER_TOKEN" |
        CONFLUENCE_BASE="$CONFLUENCE_BASE" \
        python3 "$CONFLUENCE_LIB_SCRIPT_DIR/find_marked_comment.py" --credentials-stdin "$page_id" "$marker"
}

# ==================== ATTACHMENTS (IMAGES) ====================

# Upload a file as a page attachment, or add a new version of an existing
# attachment with the same file name. Uses PUT on child/attachment, which the
# v1 API documents as create-or-update (POST returns 400 when the name exists).
# Usage: confluence_upload_attachment '<page_id>' '<file_path>' ['<comment>']
confluence_upload_attachment() {
    local page_id="${1:-}" file_path="${2:-}" comment="${3:-}"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || ! -f "$file_path" ]]; then
        echo "❌ Usage: confluence_upload_attachment '<page_id>' '<file_path>' ['<comment>']" >&2
        return 1
    fi

    # --form-string keeps a comment starting with @ or < from being read as a file.
    _confluence_curl -X PUT -H "X-Atlassian-Token: no-check" \
        -F "file=@${file_path}" \
        --form-string "comment=${comment}" \
        "$CONFLUENCE_BASE/rest/api/content/$page_id/child/attachment"
    _confluence_report $? "upload attachment $(basename "$file_path") to page $page_id"
}

# ==================== PANELS (INFO/NOTE/WARNING/ERROR/SUCCESS) ====================

# Generate the native Confluence "Panel" macro in storage format (XHTML).
# NEVER hand-write <div style="background-color:...">: Confluence stores it
# but does not render it as a real panel. The macro already carries its own
# icon for each type, so never prepend an emoji.
# Usage: confluence_panel '<type>' '<inner_html_file>'
#   type: info | note | warning | error | success | tip
#   inner_html_file: HTML already wrapped in <p>...</p>
# Example: confluence_panel error snippet.html >> body.html
confluence_panel() {
    local panel_type="${1:-}" inner_file="${2:-}"
    if [[ ! "$panel_type" =~ ^(info|note|warning|error|success|tip)$ || -z "$inner_file" || ! -f "$inner_file" ]]; then
        echo "❌ Usage: confluence_panel '<info|note|warning|error|success|tip>' '<inner_html_file>'" >&2
        return 1
    fi

    python3 - "$panel_type" "$inner_file" << 'PYEOF'
import sys
panel_type, inner_file = sys.argv[1], sys.argv[2]
with open(inner_file) as f:
    inner = f.read()
print(
    f'<ac:structured-macro ac:name="{panel_type}" ac:schema-version="1">'
    f'<ac:rich-text-body>{inner}</ac:rich-text-body>'
    '</ac:structured-macro>'
)
PYEOF
}

# ==================== CODE BLOCKS ====================

# Generate the native Confluence "Code Block" macro in storage format (XHTML)
# from a plain-text file. NEVER hand-write <pre><code>: Confluence does not
# convert it to the real macro.
# Usage: confluence_code_block '<text_file>' ['<language>']
# Example: confluence_code_block snippet.yaml yaml >> body.html
confluence_code_block() {
    local text_file="${1:-}" language="${2:-}"
    if [[ -z "$text_file" || ! -f "$text_file" ]]; then
        echo "❌ Usage: confluence_code_block '<text_file>' ['<language>']" >&2
        return 1
    fi
    if [[ ! "$language" =~ ^[A-Za-z0-9+#-]*$ ]]; then
        echo "❌ Invalid language '$language' (letters, digits, +, # and - only)" >&2
        return 1
    fi

    python3 - "$text_file" "$language" << 'PYEOF'
import sys
text_file, language = sys.argv[1], sys.argv[2]
with open(text_file) as f:
    text = f.read()
text = text.replace("]]>", "]]]]><![CDATA[>")
params = f'<ac:parameter ac:name="language">{language}</ac:parameter>' if language else ""
print(
    '<ac:structured-macro ac:name="code" ac:schema-version="1">'
    f'{params}<ac:parameter ac:name="linenumbers">false</ac:parameter>'
    f'<ac:plain-text-body><![CDATA[{text}]]></ac:plain-text-body>'
    '</ac:structured-macro>'
)
PYEOF
}

# ==================== MERMAID → PNG ====================

# Render a .mmd file to .png with mermaid-cli (through npx, no global install)
# Usage: confluence_render_mermaid '<file.mmd>' '<file.png>' ['<width_px>']
CONFLUENCE_DIAGRAM_WIDTH="${CONFLUENCE_DIAGRAM_WIDTH:-760}"  # maximum column width in this space

confluence_render_mermaid() {
    local mmd_file="${1:-}" png_file="${2:-}" width="${3:-$CONFLUENCE_DIAGRAM_WIDTH}"
    if [[ -z "$mmd_file" || -z "$png_file" || ! -f "$mmd_file" || ! "$width" =~ ^[0-9]+$ ]]; then
        echo "❌ Usage: confluence_render_mermaid '<file.mmd>' '<file.png>' ['<width_px>']" >&2
        return 1
    fi
    npx --yes @mermaid-js/mermaid-cli -i "$mmd_file" -o "$png_file" -b white -w "$width"
}

# High-level helper: render a .mmd, upload it as a page attachment and print
# the <ac:image> snippet ready to paste into the body (storage format).
# Usage: confluence_mermaid_to_page '<page_id>' '<file.mmd>' '<png_name>' ['<comment>']
#   png_name: a bare file name (letters, digits, dot, underscore, hyphen).
confluence_mermaid_to_page() {
    local page_id="${1:-}" mmd_file="${2:-}" png_name="${3:-}" comment="${4:-Diagram rendered from Mermaid source}"
    if [[ -z "$page_id" || -z "$mmd_file" || ! "$png_name" =~ ^[A-Za-z0-9_][A-Za-z0-9._-]*$ ]]; then
        echo "❌ Usage: confluence_mermaid_to_page '<page_id>' '<file.mmd>' '<png_name>' ['<comment>']" >&2
        echo "   png_name must be a bare file name without slashes or special characters." >&2
        return 1
    fi

    local tmp_dir png_path result
    tmp_dir=$(mktemp -d "$(_confluence_tmp_base)/confluence-mermaid.XXXXXX") || return 1
    png_path="$tmp_dir/$png_name"

    if ! confluence_render_mermaid "$mmd_file" "$png_path"; then
        rm -rf "$tmp_dir"
        return 1
    fi
    echo "📤 Uploading $png_name to page $page_id..." >&2
    if ! result=$(confluence_upload_attachment "$page_id" "$png_path" "$comment") ||
        ! jq -e '.results[0].id' <<< "$result" > /dev/null 2>&1; then
        echo "❌ Attachment upload failed:" >&2
        printf '%s\n' "$result" >&2
        rm -rf "$tmp_dir"
        return 1
    fi
    rm -rf "$tmp_dir"
    echo "✅ Attachment uploaded. Reference to insert in the body (storage format):" >&2
    echo "<ac:image ac:width=\"${CONFLUENCE_DIAGRAM_WIDTH}\"><ri:attachment ri:filename=\"${png_name}\" /></ac:image>"
}

# Show the banner only in interactive shells, not on every CLI invocation.
if [[ $- == *i* ]]; then
    echo "📚 Confluence library loaded" >&2
    echo "💡 Functions: confluence_get_page_body, confluence_update_page_body, confluence_update_page_adf, confluence_create_page_adf, confluence_get_footer_comments, confluence_get_comment_children, confluence_add_footer_comment_adf, confluence_find_marked_comment, confluence_upload_attachment, confluence_panel, confluence_code_block, confluence_render_mermaid, confluence_mermaid_to_page" >&2
fi
