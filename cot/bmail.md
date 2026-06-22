---
domain: workflow
task: redactar borradores de business email en inglés con plantillas y frases modelo del libro Business Email
dificultad: media
longitud_objetivo: media
validacion: HTML generado con placeholders completos, tono profesional y acción clara
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- El objetivo de `bmail` es acelerar redacción de correos profesionales en inglés.
- Se usarán plantillas temáticas y bancos de frases derivados de `docs/business_email.pdf`.
- La salida debe ser reutilizable como borrador editable, con estructura consistente:
  asunto claro, apertura contextual, cuerpo accionable y cierre cortés.

Pasos:
1) Acción: identificar el tipo de correo solicitado.
   - opening, enquiry, informing-good, informing-bad, apology-delay, order-status, meeting-request.
   Resultado: plantilla objetivo seleccionada.

2) Acción: recopilar datos mínimos.
   - Subject, destinatario, contexto, detalle del pedido/información, fecha límite o siguiente paso.
   Resultado: campos necesarios completos.

3) Acción: seleccionar frases modelo del banco.
   - Priorizar frases funcionales (referencing, requesting, apologising, informing).
   - Evitar copia mecánica extensa; adaptar al contexto concreto.
   Resultado: frases candidatas integradas al borrador.

4) Acción: sustituir placeholders en la plantilla HTML.
   Resultado: correo completo con estructura consistente.

5) Acción: revisar claridad y tono.
   - Una sola petición principal por correo.
   - Tono profesional, directo y cortés.
   - Cierre con acción o confirmación esperada.
   Resultado: borrador listo para revisión/envío.

6) Acción: guardar archivo con convención de nombre.
   - `YYYY-MM-DD-bmail-{template-key}-{subject-slug}.html`
   Resultado: archivo persistido en ruta acordada.

Conclusión:
- `bmail` transforma ejemplos del libro en plantillas operables.
- El enfoque es rapidez + consistencia + personalización contextual.
