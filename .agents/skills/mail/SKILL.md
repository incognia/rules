---
name: mail
description: "Compose an OWA-compatible HTML email from templates. Usage: /mail <delivery|generic> <subject>"
---

# Compose HTML email for OWA

## Arguments

- **Type**: $0 (delivery for microservice delivery, generic for anything else)
- **Subject**: $ARGUMENTS (everything after the type — used as email topic/service name)

## Instructions

1. **Read the full CoT**: Load and follow `cot/mail.md` from line 1 to end
2. **Read the rules**: Load `rulesets/MAIL.md` for HTML constraints and color palette
3. **Select template** based on $0:
   - `delivery` → read and use `templates/mail/delivery_template.html`
   - `generic` → read and use `templates/mail/generic_template.html`
4. **Generate filename**: `YYYY-MM-DD-{subject-as-slug}.html` (date in CST)
5. **Ask the user** for the missing data:
   - For delivery: service name, prefix, version, recipient, base branch, description
   - For generic: title, recipient, sections content, box types needed
6. **Generate the HTML** replacing all placeholders with real data
7. **Select accent color** for the H1 border based on email purpose:
   - Delivery/OK → `#3498db` (blue)
   - Fix/change → `#e67e22` (orange)
   - Critical alert → `#e74c3c` (red)
   - Technical decision → `#0066cc` (dark blue)
8. **Validate OWA rules**:
   - Every colored `<td>` has BOTH `bgcolor` attribute AND `background-color` in style
   - No `<style>` blocks, no CSS classes
   - Code blocks use `<td white-space:pre-wrap>`, not `<pre>`
   - Table row striping uses inline style, not `nth-child`
9. **Save** the file in the current project's working directory

## Critical rules

- ALL styles must be inline — OWA strips `<style>` blocks and CSS classes
- `bgcolor` goes on `<td>`, NEVER only on `<table>`
- No `border-radius`, no flexbox, no grid, no media queries
- Font: `Arial,sans-serif` everywhere, `'Courier New',monospace` for code

## Examples

- `/mail delivery kabat-authorization-service` — microservice delivery email
- `/mail generic cambio de configuración Kafka` — configuration change email
- `/mail generic decisión técnica WebSocket` — technical decision email

## References

- Detailed CoT: `cot/mail.md`
- Rules: `rulesets/MAIL.md`
- Templates: `templates/mail/delivery_template.html` and `templates/mail/generic_template.html`
