# Reglas de redacción para `bmail`

## Propósito
Definir estándares para generar borradores de business email en inglés usando plantillas y frases funcionales inspiradas en `docs/business_email.pdf`.

## Estructura base obligatoria
Todo correo generado debe incluir:
1. **Subject** específico y accionable.
2. **Opening** con referencia contextual.
3. **Core message** con información concreta.
4. **Action request** clara (si aplica).
5. **Polite close** con siguiente paso.

## Tono y estilo
- Profesional y cortés, sin lenguaje ambiguo.
- Oraciones cortas y directas.
- Evitar párrafos largos; preferir bloques de 2-4 líneas.
- Usar verbos de acción: confirm, send, review, advise, clarify.

## Reglas de contenido
- Un correo = una intención principal.
- Incluir referencia (order ref, invoice, fecha o reunión) cuando exista.
- Si hay retraso/problema, incluir:
  - reconocimiento del problema,
  - disculpa,
  - causa breve,
  - acción correctiva,
  - nuevo compromiso temporal.

## Frases modelo recomendadas (del libro)
- “Thank you for your email of 14 June.”
- “I am writing in reference to your advertisement in yesterday's New York Times.”
- “I am writing with reference to your enquiry of 6 November.”
- “Please could you confirm the deadline?”
- “Would you please email me further information about...”
- “We regret to inform you that....”
- “Unfortunately, we are unable to…”
- “Please accept my apologies for this.”
- “Once again please accept my apologies for any inconvenience caused.”

## Placeholders estándar
Usar placeholders en MAYÚSCULAS con llaves:
- `{SUBJECT}`
- `{RECIPIENT_NAME}`
- `{RECIPIENT_COMPANY}`
- `{REFERENCE}`
- `{CONTEXT}`
- `{MAIN_REQUEST}`
- `{DETAILS}`
- `{DEADLINE}`
- `{NEXT_STEP}`
- `{SENDER_NAME}`
- `{SENDER_ROLE}`

## Plantillas disponibles
- `opening_reference_template.html`
- `enquiry_template.html`
- `informing_good_news_template.html`
- `informing_bad_news_template.html`
- `apology_delay_template.html`
- `order_status_template.html`
- `meeting_request_template.html`
