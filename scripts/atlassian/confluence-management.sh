#!/bin/bash

# =============================================================================
# CONFLUENCE MANAGEMENT - Script principal usando confluence-lib.sh
# =============================================================================
# Autor: Rodrigo Álvarez
# Propósito: CLI para publicar/actualizar páginas y adjuntar imágenes
#            (diagramas Mermaid) en Confluence, y comentar en ADF. Mismo patrón que
#            jira-management.sh — siempre invocar este archivo con `bash`/`./`,
#            nunca hacer `source` directo desde un shell interactivo (zsh no
#            resuelve BASH_SOURCE igual y las credenciales no cargan).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/confluence-lib.sh" ]]; then
    source "$SCRIPT_DIR/confluence-lib.sh"
else
    echo "❌ Error: No se encuentra confluence-lib.sh en $SCRIPT_DIR" >&2
    exit 1
fi

case "$1" in
    upload-attachment)
        confluence_upload_attachment "$2" "$3" "$4"
        ;;
    update-page)
        confluence_update_page_body "$2" "$3" "$4"
        ;;
    update-page-adf)
        confluence_update_page_adf "$2" "$3" "$4"
        ;;
    create-page-adf)
        confluence_create_page_adf "$2" "$3" "$4" "$5"
        ;;
    render-mermaid)
        confluence_render_mermaid "$2" "$3"
        ;;
    code-block)
        confluence_code_block "$2" "$3"
        ;;
    panel)
        confluence_panel "$2" "$3"
        ;;
    mermaid-to-page)
        confluence_mermaid_to_page "$2" "$3" "$4" "$5"
        ;;
    get-page)
        confluence_get_page_body "$2"
        ;;
    get-comments)
        confluence_get_footer_comments "$2"
        ;;
    get-replies)
        confluence_get_comment_children "$2"
        ;;
    comment-adf)
        confluence_add_footer_comment_adf page "$2" "$3"
        ;;
    reply-adf)
        confluence_add_footer_comment_adf reply "$2" "$3"
        ;;
    find-marked)
        confluence_find_marked_comment "$2" "$3"
        ;;
    *)
        cat << 'EOF'
Uso: confluence-management.sh <comando> [args]

Comandos:
  upload-attachment '<page_id>' '<file_path>' ['<comment>']
  update-page       '<page_id>' '<title>' '<body_html_file>'   # storage/XHTML — solo para páginas aún no migradas a ADF, o diagnóstico
  update-page-adf   '<page_id>' '<title>' '<archivo_adf.json>' # ADF nativo (default) — archivo generado con scripts/adf_lib.py
  create-page-adf   '<space_key>' '<parent_id>' '<title>' '<archivo_adf.json>' # crea página nueva — fallback cuando el MCP da 403
  render-mermaid    '<archivo.mmd>' '<archivo.png>'
  code-block        '<archivo_texto>' ['<lenguaje>']   # genera el macro nativo, nunca usar <pre><code>
  panel             '<tipo>' '<archivo_html>'   # tipo: info|note|warning|error|success|tip; nunca usar <div style=...>; el macro ya trae su propio ícono, no anteponer emoji
  mermaid-to-page   '<page_id>' '<archivo.mmd>' '<nombre_png>' ['<comment>']
  get-page          '<page_id>'
  get-comments      '<page_id>'                         # comentarios al pie (API v2, body en ADF)
  get-replies       '<comment_id>'                      # respuestas de un comentario al pie
  comment-adf       '<page_id>' '<archivo_adf.json>'    # comentario al pie nuevo en ADF
  reply-adf         '<comment_id>' '<archivo_adf.json>' # respuesta en el hilo de un comentario, en ADF
  find-marked       '<page_id>' ['<marca>']             # hilo y último comentario cuyo texto plano contiene la marca (default: pie de /sdd-readiness)
EOF
        exit 1
        ;;
esac
