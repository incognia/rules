#!/bin/bash

# =============================================================================
# CONFLUENCE LIBRARY - Biblioteca de funciones para Confluence REST API v1
# =============================================================================
# Autor: Rodrigo Álvarez
# Propósito: Biblioteca reutilizable para publicar/actualizar páginas y
#            adjuntar imágenes (diagramas Mermaid renderizados a PNG) en
#            Confluence, y publicar comentarios al pie en ADF, con las
#            credenciales de atlassian-env.sh (misma cuenta Atlassian, válida
#            para Jira y Confluence). Origen: ops/jira/scripts (promad-cad-all).
# =============================================================================

CONFLUENCE_LIB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$CONFLUENCE_LIB_SCRIPT_DIR/atlassian-env.sh" ]]; then
    # shellcheck disable=SC1090
    source "$CONFLUENCE_LIB_SCRIPT_DIR/atlassian-env.sh"
fi

# ==================== CONFIGURACIÓN ====================

CONFLUENCE_USER_EMAIL="${JIRA_USER_EMAIL:-${JIRA_EMAIL:-}}"
CONFLUENCE_USER_TOKEN="${JIRA_USER_TOKEN:-${JIRA_TOKEN:-}}"
CONFLUENCE_BASE="${CONFLUENCE_BASE:-https://avite.atlassian.net/wiki}"

confluence_check_credentials() {
    if [[ -z "$CONFLUENCE_USER_EMAIL" || -z "$CONFLUENCE_USER_TOKEN" ]]; then
        echo "❌ Credenciales faltantes. Define JIRA_USER_EMAIL y JIRA_USER_TOKEN en .env (mismas usadas para Jira)." >&2
        return 1
    fi
    return 0
}

# ==================== PÁGINAS ====================

# Obtiene el body (storage/XHTML) y version.number actuales de una página
# Uso: confluence_get_page_body '<page_id>'
confluence_get_page_body() {
    local page_id="$1"
    confluence_check_credentials || return 1
    curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        "$CONFLUENCE_BASE/rest/api/content/$page_id?expand=body.storage,version"
}

# Reemplaza por completo el body (storage/XHTML) de una página existente
# Uso: confluence_update_page_body '<page_id>' '<title>' '<body_html_file>'
confluence_update_page_body() {
    local page_id="$1" title="$2" body_file="$3"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || -z "$title" || ! -f "$body_file" ]]; then
        echo "❌ Uso: confluence_update_page_body '<page_id>' '<title>' '<body_html_file>'" >&2
        return 1
    fi

    local current_version
    current_version=$(confluence_get_page_body "$page_id" | jq -r '.version.number')
    if [[ -z "$current_version" || "$current_version" == "null" ]]; then
        echo "❌ No se pudo leer la versión actual de la página $page_id" >&2
        return 1
    fi
    local next_version=$((current_version + 1))

    # Archivo temporal único por invocación — NUNCA una ruta fija en /tmp:
    # otras sesiones concurrentes en esta máquina pueden pisarla a medio
    # proceso (mismo problema ya documentado con /tmp/commit-msg.txt),
    # causando que el PUT mande contenido/versión de otra página o quede
    # en carrera y Confluence responda 200 con el estado viejo sin cambios.
    local payload_file
    payload_file=$(mktemp "${TMPDIR:-/tmp}/confluence-update-payload.XXXXXX.json")

    python3 - "$page_id" "$title" "$body_file" "$next_version" "$payload_file" << 'PYEOF'
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

    local result
    result=$(curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        -X PUT -H "Content-Type: application/json" \
        --data @"$payload_file" \
        "$CONFLUENCE_BASE/rest/api/content/$page_id")
    rm -f "$payload_file"
    echo "$result"
}

# Reemplaza por completo el body de una página existente usando la representación
# ADF nativa (API v1, body.atlas_doc_format) — la ruta correcta para actualizar el
# contenido de una página ya migrada a ADF (ver "Formato de contenido: ADF" en
# AGENTS.md). El archivo ADF se genera de antemano (con scripts/adf_lib.py) y se
# sube tal cual vía curl --data @archivo: nunca pegar el JSON completo como
# argumento literal de una tool call, arriesga transcripción manual en páginas
# grandes y puede chocar con el truncamiento de salidas largas de la terminal.
# Uso: confluence_update_page_adf '<page_id>' '<title>' '<archivo_adf.json>'
#   archivo_adf.json: el documento ADF completo (`{"type":"doc","version":1,...}`),
#   p.ej. escrito con adf_lib.write_doc() — NO envuelto en {"body": ...}.
confluence_update_page_adf() {
    local page_id="$1" title="$2" adf_file="$3"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || -z "$title" || ! -f "$adf_file" ]]; then
        echo "❌ Uso: confluence_update_page_adf '<page_id>' '<title>' '<archivo_adf.json>'" >&2
        return 1
    fi

    local current_version
    current_version=$(confluence_get_page_body "$page_id" | jq -r '.version.number')
    if [[ -z "$current_version" || "$current_version" == "null" ]]; then
        echo "❌ No se pudo leer la versión actual de la página $page_id" >&2
        return 1
    fi
    local next_version=$((current_version + 1))

    local payload_file
    payload_file=$(mktemp "${TMPDIR:-/tmp}/confluence-adf-payload.XXXXXX.json")

    python3 - "$adf_file" "$title" "$next_version" "$payload_file" << 'PYEOF'
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

    local result
    result=$(curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        -X PUT -H "Content-Type: application/json" \
        --data @"$payload_file" \
        "$CONFLUENCE_BASE/rest/api/content/$page_id")
    rm -f "$payload_file"
    echo "$result"
}

# Crea una página nueva usando la representación ADF nativa (API v1, body.atlas_doc_format) —
# la ruta correcta cuando el conector MCP (createConfluencePage) está bloqueado en la instancia
# (403 "The app is not installed on this instance", ya confirmado en avite.atlassian.net).
# Uso: confluence_create_page_adf '<space_key>' '<parent_id>' '<title>' '<archivo_adf.json>'
#   archivo_adf.json: el documento ADF completo, p.ej. escrito con adf_lib.write_doc() —
#   NO envuelto en {"body": ...}.
confluence_create_page_adf() {
    local space_key="$1" parent_id="$2" title="$3" adf_file="$4"
    confluence_check_credentials || return 1

    if [[ -z "$space_key" || -z "$parent_id" || -z "$title" || ! -f "$adf_file" ]]; then
        echo "❌ Uso: confluence_create_page_adf '<space_key>' '<parent_id>' '<title>' '<archivo_adf.json>'" >&2
        return 1
    fi

    local payload_file
    payload_file=$(mktemp "${TMPDIR:-/tmp}/confluence-create-payload.XXXXXX.json")

    python3 - "$adf_file" "$title" "$space_key" "$parent_id" "$payload_file" << 'PYEOF'
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

    local result
    result=$(curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        -X POST -H "Content-Type: application/json" \
        --data @"$payload_file" \
        "$CONFLUENCE_BASE/rest/api/content")
    rm -f "$payload_file"
    echo "$result"
}

# ==================== COMENTARIOS AL PIE (API v2, ADF) ====================

# Lista los comentarios al pie de una página, con su body en ADF
# Uso: confluence_get_footer_comments '<page_id>'
confluence_get_footer_comments() {
    local page_id="$1"
    confluence_check_credentials || return 1
    if [[ -z "$page_id" ]]; then
        echo "❌ Uso: confluence_get_footer_comments '<page_id>'" >&2
        return 1
    fi
    curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        "$CONFLUENCE_BASE/api/v2/pages/$page_id/footer-comments?body-format=atlas_doc_format&limit=100"
}

# Lista las respuestas de un comentario al pie
# Uso: confluence_get_comment_children '<comment_id>'
confluence_get_comment_children() {
    local comment_id="$1"
    confluence_check_credentials || return 1
    if [[ -z "$comment_id" ]]; then
        echo "❌ Uso: confluence_get_comment_children '<comment_id>'" >&2
        return 1
    fi
    curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        "$CONFLUENCE_BASE/api/v2/footer-comments/$comment_id/children?body-format=atlas_doc_format&limit=100"
}

# Publica un comentario al pie nuevo, o una respuesta en un hilo, a partir de un archivo ADF.
# Uso: confluence_add_footer_comment_adf page  '<page_id>'    '<archivo_adf.json>'
#      confluence_add_footer_comment_adf reply '<comment_id>' '<archivo_adf.json>'
#   archivo_adf.json: documento ADF completo (`{"type":"doc","version":1,...}`), p. ej. escrito con
#   adf_lib.write_doc(); nunca pegar el JSON como argumento literal.
confluence_add_footer_comment_adf() {
    local mode="$1" target_id="$2" adf_file="$3"
    confluence_check_credentials || return 1

    if [[ ! "$mode" =~ ^(page|reply)$ || -z "$target_id" || ! -f "$adf_file" ]]; then
        echo "❌ Uso: confluence_add_footer_comment_adf <page|reply> '<page_id|comment_id>' '<archivo_adf.json>'" >&2
        return 1
    fi

    local payload_file
    payload_file=$(mktemp "${TMPDIR:-/tmp}/confluence-comment-payload.XXXXXX.json")

    python3 - "$mode" "$target_id" "$adf_file" "$payload_file" << 'PYEOF'
import json, sys
mode, target_id, adf_file, out_path = sys.argv[1:5]
with open(adf_file) as f:
    adf_doc = json.load(f)
payload = {"body": {"representation": "atlas_doc_format", "value": json.dumps(adf_doc, ensure_ascii=False)}}
payload["pageId" if mode == "page" else "parentCommentId"] = str(target_id)
with open(out_path, "w") as f:
    json.dump(payload, f, ensure_ascii=False)
PYEOF

    local result
    result=$(curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        -X POST -H "Content-Type: application/json" \
        --data @"$payload_file" \
        "$CONFLUENCE_BASE/api/v2/footer-comments")
    rm -f "$payload_file"
    echo "$result"
}

# ==================== ADJUNTOS (IMÁGENES) ====================

# Sube un archivo como adjunto de una página (o reemplaza uno existente del mismo nombre)
# Uso: confluence_upload_attachment '<page_id>' '<file_path>' ['<comment>']
confluence_upload_attachment() {
    local page_id="$1" file_path="$2" comment="${3:-}"
    confluence_check_credentials || return 1

    if [[ -z "$page_id" || ! -f "$file_path" ]]; then
        echo "❌ Uso: confluence_upload_attachment '<page_id>' '<file_path>' ['<comment>']" >&2
        return 1
    fi

    curl -s -u "$CONFLUENCE_USER_EMAIL:$CONFLUENCE_USER_TOKEN" \
        -X POST -H "X-Atlassian-Token: no-check" \
        -F "file=@${file_path}" \
        -F "comment=${comment}" \
        "$CONFLUENCE_BASE/rest/api/content/$page_id/child/attachment"
}

# ==================== PANELES (INFO/NOTE/WARNING/ERROR/SUCCESS) ====================

# Genera el macro nativo de Confluence "Panel" en formato storage (XHTML).
# NUNCA usar <div style="background-color:...">...</div> a mano — Confluence
# lo guarda tal cual (normaliza el CSS) pero NO lo renderiza con el look real
# de un panel (sin ícono, sin las esquinas/friso del macro nativo).
# El macro YA trae su propio ícono según el tipo (ⓧ error, ⚠ warning, etc.)
# — NUNCA anteponer un emoji a mano, queda duplicado/redundante (confirmado
# con captura de pantalla el 2026-09-19).
# Uso: confluence_panel '<tipo>' '<archivo_html_interno>'
#   tipo: info | note | warning | error | success | tip
#   archivo_html_interno: HTML ya envuelto en <p>...</p> (puede tener <strong>, <code>, <a>, etc.)
# Ejemplo: confluence_panel error /tmp/snippet.html >> body.html
confluence_panel() {
    local panel_type="$1" inner_file="$2"
    if [[ -z "$panel_type" || -z "$inner_file" || ! -f "$inner_file" ]]; then
        echo "❌ Uso: confluence_panel '<tipo>' '<archivo_html_interno>'" >&2
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

# ==================== BLOQUES DE CÓDIGO ====================

# Genera el macro nativo de Confluence "Code Block" en formato storage (XHTML),
# a partir de un archivo de texto plano. NUNCA usar <pre><code>...</code></pre>
# a mano — Confluence NO lo convierte al macro real, lo renderiza como texto
# preformateado con word-wrap feo en vez de scroll horizontal/resaltado.
# Uso: confluence_code_block '<archivo_texto>' ['<lenguaje>']
# Ejemplo: confluence_code_block /tmp/snippet.yaml yaml >> body.html
confluence_code_block() {
    local text_file="$1" language="${2:-}"
    if [[ -z "$text_file" || ! -f "$text_file" ]]; then
        echo "❌ Uso: confluence_code_block '<archivo_texto>' ['<lenguaje>']" >&2
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

# Renderiza un archivo .mmd a .png usando mermaid-cli (vía npx, sin instalación global)
# Uso: confluence_render_mermaid '<archivo.mmd>' '<archivo.png>'
CONFLUENCE_DIAGRAM_WIDTH="${CONFLUENCE_DIAGRAM_WIDTH:-760}"  # ancho máximo de columna en este espacio (AC1)

confluence_render_mermaid() {
    local mmd_file="$1" png_file="$2" width="${3:-$CONFLUENCE_DIAGRAM_WIDTH}"
    if [[ -z "$mmd_file" || -z "$png_file" || ! -f "$mmd_file" ]]; then
        echo "❌ Uso: confluence_render_mermaid '<archivo.mmd>' '<archivo.png>' ['<ancho_px>']" >&2
        return 1
    fi
    npx --yes @mermaid-js/mermaid-cli -i "$mmd_file" -o "$png_file" -b white -w "$width"
}

# Helper de alto nivel: renderiza un .mmd, lo sube como adjunto a una página,
# e imprime el snippet <ac:image> listo para pegar en el body (storage format)
# Uso: confluence_mermaid_to_page '<page_id>' '<archivo.mmd>' '<nombre_png>' ['<comment>']
confluence_mermaid_to_page() {
    local page_id="$1" mmd_file="$2" png_name="$3" comment="${4:-Diagram rendered from Mermaid source}"
    local png_path="/tmp/${png_name}"

    confluence_render_mermaid "$mmd_file" "$png_path" || return 1
    echo "📤 Subiendo $png_name a la página $page_id..." >&2
    local result
    result=$(confluence_upload_attachment "$page_id" "$png_path" "$comment")
    echo "$result" | jq -e '.results[0].id' > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "❌ Error al subir el adjunto:" >&2
        echo "$result" >&2
        return 1
    fi
    echo "✅ Adjunto subido. Referencia para insertar en el body (storage format):" >&2
    echo "<ac:image ac:width=\"${CONFLUENCE_DIAGRAM_WIDTH}\"><ri:attachment ri:filename=\"${png_name}\" /></ac:image>"
}

echo "📚 Confluence Library cargada exitosamente" >&2
echo "💡 Funciones: confluence_get_page_body, confluence_update_page_body, confluence_update_page_adf, confluence_create_page_adf, confluence_get_footer_comments, confluence_get_comment_children, confluence_add_footer_comment_adf, confluence_upload_attachment, confluence_panel, confluence_code_block, confluence_render_mermaid, confluence_mermaid_to_page" >&2
