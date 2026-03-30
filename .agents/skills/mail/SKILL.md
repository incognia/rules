---
name: mail
description: "Compose and send OWA-compatible HTML email. Usage: /mail <owa|mac|graph> <delivery|generic> <subject>"
---

# Compose and send HTML email

## Arguments

- **Mode**: $0 — delivery method:
  - `token` → authenticate and cache Graph API token (run once, lasts ~90 days)
  - `owa` → save HTML file for manual copy-paste into Outlook Web (Linux)
  - `mac` → open draft in Outlook via AppleScript with native signature (macOS)
  - `graph` → send directly via Microsoft Graph API with inline signature (any OS)
- **Type**: $1 — email type (`delivery` or `generic`) — not needed for `token` mode
- **Subject**: $ARGUMENTS — everything after type — not needed for `token` mode

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/mail.md` from line 1 to end
2. **Read the rules**: Load `~/rules/rulesets/MAIL.md` for HTML constraints and color palette
3. **Select template** based on $1:
   - `delivery` → read and use `~/rules/templates/mail/delivery_template.html`
   - `generic` → read and use `~/rules/templates/mail/generic_template.html`
4. **Generate filename**: `YYYY-MM-DD-{subject-as-slug}.html` (date in CST)
5. **Ask the user** for the missing data:
   - For delivery: service name, prefix, version, recipient email, base branch, description
   - For generic: title, recipient email, sections content, box types needed
6. **Generate the HTML** replacing all placeholders with real data
7. **Select accent color** for the H1 border based on email purpose:
   - Delivery/OK → `#3498db` (blue)
   - Fix/change → `#e67e22` (orange)
   - Critical alert → `#e74c3c` (red)
   - Technical decision → `#0066cc` (dark blue)
8. **Handle signature** based on mode ($0):
   - `owa` → do NOT include signature (Outlook adds it when sending from OWA)
   - `mac` → do NOT include signature (Outlook adds it when opening draft)
   - `graph` → include signature as inline CID image:
     ```html
     <hr style="margin:30px 0; border:none; border-top:2px solid #ecf0f1;">
     <img src="cid:firma_ralvarez" alt="Rodrigo Álvarez" width="740" style="max-width:100%; display:block;">
     ```
9. **Validate OWA rules**:
   - Every colored `<td>` has BOTH `bgcolor` attribute AND `background-color` in style
   - No `<style>` blocks, no CSS classes
   - Code blocks use `<td white-space:pre-wrap>`, not `<pre>`
   - Table row striping uses inline style, not `nth-child`
10. **Deliver** based on mode ($0):

### Mode: `token` (authenticate and cache)
1. Run `~/rules/scripts/graph_auth.py` via `get_token()`
2. If no cached token exists, prompts device code flow (browser auth)
3. Saves tokens to `~/.graph_tokens.json` (permissions 600)
4. Subsequent `graph` sends reuse the token silently for ~1 hour
5. After expiry, `graph` refreshes silently via refresh_token (~90 days)
6. Only need to run `/mail token` again if refresh_token expires

### Mode: `owa` (Linux — manual copy-paste)
1. Save the HTML file:
   - If the user specified a path, use that path
   - If a `mail/` directory exists in the project root, save there
   - Otherwise, save in `~/mail/`
2. Copy `~/rules/templates/mail/assets/ralvarez_firma.png` next to the HTML in an `assets/` subdirectory
3. Tell the user: open in browser → Ctrl+A → Ctrl+C → paste in OWA

### Mode: `mac` (macOS — AppleScript draft)
1. Save the HTML file (same logic as `owa`)
2. Open a draft in Outlook via AppleScript with subject, recipient and HTML body:
   ```applescript
   tell application "Microsoft Outlook"
       activate
       set newMsg to make new outgoing message with properties {subject:"...", content:"..."}
       make new to recipient at newMsg with properties {email address:{address:"..."}}
       open newMsg
   end tell
   ```
3. Outlook injects the native "Kabat One" signature automatically
4. Tell the user: review and send with ⌘+Enter

### Mode: `graph` (any OS — direct send via API)
1. Call `get_token()` from `~/rules/scripts/graph_auth.py` (uses cached token; if no cache, tells user to run `/mail token` first)
2. Read and base64-encode `~/rules/templates/mail/assets/ralvarez_firma_740.png`
5. Send via `POST https://graph.microsoft.com/v1.0/me/sendMail` with:
   - HTML body containing `<img src="cid:firma_ralvarez">`
   - Inline attachment with `contentId: "firma_ralvarez"` and `isInline: true`
   - `saveToSentItems: true`
6. Save the HTML file as well (same logic as `owa`) for archival

## Critical rules

- ALL styles must be inline — OWA strips `<style>` blocks and CSS classes
- `bgcolor` goes on `<td>`, NEVER only on `<table>`
- No `border-radius`, no flexbox, no grid, no media queries
- Font: `Arial,sans-serif` everywhere, `'Courier New',monospace` for code
- Graph API tokens expire in ~1 hour; if sending fails with 401, re-authenticate

## Examples

- `/mail token` — authenticate and cache Graph API token (run once)
- `/mail owa delivery kabat-authorization-service` — compose delivery email, save for OWA paste
- `/mail mac generic cambio de configuración Kafka` — compose and open draft in Outlook on macOS
- `/mail graph generic decisión técnica WebSocket` — compose and send directly via Graph API
- `/mail graph delivery kabat-notification-service` — compose and send delivery email via Graph API

## References

- Detailed CoT: `~/rules/cot/mail.md`
- HTML rules: `~/rules/rulesets/MAIL.md`
- Graph API docs: `~/rules/MAIL.md`
- API credentials: `~/.secrets.yaml` (key `GRAPH_API`)
- Templates: `~/rules/templates/mail/delivery_template.html` and `~/rules/templates/mail/generic_template.html`
- Signature image: `~/rules/templates/mail/assets/ralvarez_firma_740.png` (for `graph` mode)
