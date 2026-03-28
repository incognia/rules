---
domain: workflow
task: componer correo HTML compatible con OWA usando plantillas del repo stab
dificultad: media
longitud_objetivo: media
validacion: archivo HTML generado con estilos inline, bgcolor en td, sin CSS externo ni clases
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Los correos se componen como HTML y se copian al portapapeles desde el navegador para pegar en OWA.
- OWA elimina bloques `<style>`, clases CSS, `background-color` en `<table>`, `border-radius`, flexbox, grid y media queries.
- Todo el estilo debe ser inline en los elementos que contienen el texto (`<td>`), duplicando `bgcolor` como atributo HTML.
- Las plantillas están en `~/rules/templates/mail/` (`delivery_template.html` y `generic_template.html`).
- Referencia principal: «~/rules/rulesets/MAIL.md» ([../rulesets/MAIL.md](../rulesets/MAIL.md)).

Pasos:
1) Acción: determinar el tipo de correo.
   - Entrega de microservicio → usar `templates/mail/delivery_template.html`
   - Cualquier otro (cambio, decisión, reporte, corrección) → usar `templates/mail/generic_template.html`
   Resultado: plantilla seleccionada.

2) Acción: copiar la plantilla con el nombre correcto.
   Resultado: `YYYY-MM-DD-{nombre-corto}.html` (fecha CST).

3) Acción: recopilar la información necesaria.
   Para entrega: NOMBRE_SERVICIO, PREFIJO, VERSION, DESTINATARIO, FECHA, RAMA_BASE, DESCRIPCION.
   Para genérico: TITULO, DESTINATARIO, FECHA y contenido de cada sección.
   Resultado: datos listos para sustituir.

4) Acción: reemplazar los *placeholders* en el HTML.
   Resultado: HTML con datos reales.

5) Acción: seleccionar el color de acento según el tipo de correo.
   - Entrega/OK → `#3498db` (azul)
   - Corrección/cambio → `#e67e22` (naranja)
   - Alerta crítica → `#e74c3c` (rojo)
   - Decisión técnica → `#0066cc` (azul oscuro)
   Resultado: color del `border-bottom` del H1 ajustado.

6) Acción: si es plantilla genérica, eliminar los componentes que no se usen.
   Componentes opcionales: caja de resumen, caja informativa, caja de atención, caja de problema, tabla de datos, bloque de código.
   Resultado: HTML limpio sin bloques vacíos.

7) Acción: si es Angular/Node.js (no Java/Spring Boot), aplicar ajustes.
   - Eliminar sección SonarQube
   - Cambiar *pipeline* a 5 *stages*
   - Docker: multi-stage Node 22 + Nginx
   - Quitar Swagger UI de la tabla de acceso
   Resultado: HTML adaptado al *stack* del servicio.

8) Acción: verificar reglas HTML críticas antes de finalizar.
   - [ ] Todos los fondos de color usan `bgcolor` en `<td>`, no en `<table>`
   - [ ] No hay bloques `<style>` ni clases CSS
   - [ ] Bloques de código usan `<td>` con `white-space:pre-wrap`, no `<pre>`
   - [ ] Filas alternas de tabla tienen `style` inline, no `nth-child`
   - [ ] Todos los estilos son inline
   Resultado: HTML validado.

9) Acción: guardar el archivo y dar instrucciones de envío.
   Resultado: «Abrir en navegador → Ctrl+A → Ctrl+C → pegar en OWA».

Conclusión:
- El archivo HTML resultante debe poder copiarse directamente del navegador a OWA sin perder formato.
- Verificar que cada `<td>` con color tenga tanto `bgcolor` como `background-color` en el `style`.
- Referencias: «~/rules/rulesets/MAIL.md» ([../rulesets/MAIL.md](../rulesets/MAIL.md)).
