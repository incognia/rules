#!/bin/bash

# =============================================================================
# CONFLUENCE MANAGEMENT - Command-line entry point for confluence-lib.sh
# =============================================================================
# Author: Rodrigo Álvarez
# Purpose: CLI to publish and update pages, attach images (Mermaid diagrams)
#          and post ADF comments in Confluence. Always run this file with
#          `bash` or `./`; never `source` it from an interactive zsh, which
#          does not resolve BASH_SOURCE the same way (credentials do not load).
# Exit status: the status of the library function (non-zero on HTTP errors).
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/confluence-lib.sh" ]]; then
    # shellcheck source=confluence-lib.sh
    source "$SCRIPT_DIR/confluence-lib.sh"
else
    echo "❌ Error: confluence-lib.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

cmd="${1:-}"
a2="${2:-}" a3="${3:-}" a4="${4:-}" a5="${5:-}"

case "$cmd" in
    upload-attachment) confluence_upload_attachment "$a2" "$a3" "$a4" ;;
    update-page)       confluence_update_page_body "$a2" "$a3" "$a4" ;;
    update-page-adf)   confluence_update_page_adf "$a2" "$a3" "$a4" ;;
    create-page-adf)   confluence_create_page_adf "$a2" "$a3" "$a4" "$a5" ;;
    render-mermaid)    confluence_render_mermaid "$a2" "$a3" "$a4" ;;
    code-block)        confluence_code_block "$a2" "$a3" ;;
    panel)             confluence_panel "$a2" "$a3" ;;
    mermaid-to-page)   confluence_mermaid_to_page "$a2" "$a3" "$a4" "$a5" ;;
    get-page)          confluence_get_page_body "$a2" ;;
    get-comments)      confluence_get_footer_comments "$a2" ;;
    get-replies)       confluence_get_comment_children "$a2" ;;
    comment-adf)       confluence_add_footer_comment_adf page "$a2" "$a3" ;;
    reply-adf)         confluence_add_footer_comment_adf reply "$a2" "$a3" ;;
    find-marked)
        if [[ -n "$a3" ]]; then
            confluence_find_marked_comment "$a2" "$a3"
        else
            confluence_find_marked_comment "$a2"
        fi
        ;;
    *)
        cat << 'EOF'
Usage: confluence-management.sh <command> [args]

Commands:
  upload-attachment '<page_id>' '<file_path>' ['<comment>']        # creates, or adds a new version if the name exists
  update-page       '<page_id>' '<title>' '<body_html_file>'       # storage/XHTML: only for pages not yet migrated to ADF, or diagnosis
  update-page-adf   '<page_id>' '<title>' '<adf_file.json>'        # native ADF (default); file built with scripts/atlassian/adf_lib.py
  create-page-adf   '<space_key>' '<parent_id>' '<title>' '<adf_file.json>' # new page; fallback when the MCP returns 403
  render-mermaid    '<file.mmd>' '<file.png>' ['<width_px>']
  code-block        '<text_file>' ['<language>']                   # native macro; never use <pre><code>
  panel             '<type>' '<html_file>'                         # type: info|note|warning|error|success|tip; never <div style=...>; no emoji
  mermaid-to-page   '<page_id>' '<file.mmd>' '<png_name>' ['<comment>']
  get-page          '<page_id>'
  get-comments      '<page_id>'                                    # all footer comments (API v2, ADF bodies), paginated
  get-replies       '<comment_id>'                                 # all replies of a footer comment, paginated
  comment-adf       '<page_id>' '<adf_file.json>'                  # new ADF footer comment
  reply-adf         '<comment_id>' '<adf_file.json>'               # ADF reply in a comment thread
  find-marked       '<page_id>' ['<marker>']                       # thread and latest comment whose plain text holds the marker (default: /sdd-readiness footer)
EOF
        exit 1
        ;;
esac
