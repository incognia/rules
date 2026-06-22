---
name: bmail
description: "Compose structured business-email drafts in English from curated templates and phrase banks from Business Email (book). Use this whenever the user asks for enquiry, informing, request, complaint, apology, order-status, or meeting-style business emails."
---

# Compose business-email drafts from curated templates

## Arguments
- **Template key**: $0
  - `opening` → opening and referencing email
  - `enquiry` → asking for information / quotation / availability
  - `informing-good` → positive update or confirmation
  - `informing-bad` → negative update or limitation
  - `apology-delay` → apology and delay explanation
  - `order-status` → confirmation, status, delay or refund
  - `meeting-request` → request to schedule a call/meeting
- **Subject**: $ARGUMENTS — everything after template key

## Instructions
0. **No arguments guard**: If $0 is missing, print:
   ```
   Usage: /bmail <template-key> <subject>

   Template keys:
     opening
     enquiry
     informing-good
     informing-bad
     apology-delay
     order-status
     meeting-request

   Examples:
     /bmail enquiry Request for Catalogue
     /bmail informing-good Brochure Dispatch Confirmation
     /bmail apology-delay Delay in Delivery - Ref 64783
   ```
   Stop immediately.
1. Read and follow `~/rules/cot/bmail.md`.
2. Read `~/rules/rulesets/BMAIL.md`.
3. Select template by $0:
   - `opening` → `~/rules/templates/bmail/opening_reference_template.html`
   - `enquiry` → `~/rules/templates/bmail/enquiry_template.html`
   - `informing-good` → `~/rules/templates/bmail/informing_good_news_template.html`
   - `informing-bad` → `~/rules/templates/bmail/informing_bad_news_template.html`
   - `apology-delay` → `~/rules/templates/bmail/apology_delay_template.html`
   - `order-status` → `~/rules/templates/bmail/order_status_template.html`
   - `meeting-request` → `~/rules/templates/bmail/meeting_request_template.html`
4. Ask the user for missing fields required by the selected template (recipient, company, context, action requested, dates, order refs, deadlines).
5. Generate HTML by replacing all placeholders and preserving phrase-bank examples where useful.
6. Save output as `YYYY-MM-DD-bmail-{template-key}-{subject-slug}.html`:
   - Use user-provided path if specified.
   - Else use `mail/` in current project if it exists.
   - Else save in current directory.
7. Validate quality before finalizing:
   - Subject is specific and action-oriented.
   - Opening references context clearly.
   - One clear primary request/action.
   - Closing is polite and includes next step.
8. Return:
   - Output file path
   - Final subject
   - 3-line summary of tone and intent

## References
- CoT: `~/rules/cot/bmail.md`
- Ruleset: `~/rules/rulesets/BMAIL.md`
- Templates: `~/rules/templates/bmail/`
- Source material: `./docs/business_email.pdf`
