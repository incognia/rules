---
domain: workflow
task: componer y enviar correo HTML compatible con OWA usando plantillas y tres modos de entrega
dificultad: media
longitud_objetivo: media
validacion: archivo HTML generado con estilos inline, bgcolor en td, sin CSS externo ni clases; entregado según el modo elegido
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Los correos se componen como HTML usando plantillas OWA con estilos *inline*.
- OWA elimina bloques `<style>`, clases CSS, `background-color` en `<table>`, `border-radius`, flexbox, grid y *media queries*.
- Todo el estilo debe ser *inline* en los `<td>`, duplicando `bgcolor` como atributo HTML.
- Las plantillas están en `~/rules/templates/mail/` (`delivery_template.html` y `generic_template.html`).
- Hay tres modos de entrega: `owa` (copiar/pegar), `mac` (AppleScript + Outlook) y `graph` (Microsoft Graph API).
- Referencia de composición: «~/rules/rulesets/MAIL.md» ([../rulesets/MAIL.md](../rulesets/MAIL.md)).
- Referencia de envío: «~/rules/MAIL.md» ([../MAIL.md](../MAIL.md)).

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

9) Acción: guardar el archivo HTML.
   - Nombre: `YYYY-MM-DD-{nombre-corto}.html` (fecha CST).
   - Ubicación: ruta indicada por el usuario, carpeta `mail/` del proyecto, o `~/mail/`.
   Resultado: archivo guardado.

10) Acción: entregar según el modo elegido.
   - **`owa`**: indica al usuario «abrir en navegador → Ctrl+A → Ctrl+C → pegar en OWA». No incluir firma (OWA la agrega).
   - **`mac`**: abre un borrador en Outlook vía AppleScript (`open newMsg`, nunca `send`). No incluir firma (Outlook la inyecta). Indicar al usuario enviar con ⌘+Enter.
   - **`graph`**: incluir firma como imagen CID *inline*. Autenticar vía *device code flow* con credenciales de `~/.secrets.yaml` (`GRAPH_API`). Enviar con `POST /me/sendMail`. Guardar también el HTML como respaldo.
   Resultado: correo entregado o borrador abierto.

Conclusión:
- El HTML resultante debe cumplir las reglas OWA (`bgcolor` en `<td>`, estilos *inline*, sin CSS externo).
- La firma solo va en el HTML cuando el modo es `graph` (como imagen CID *inline*).
- En `owa` y `mac`, Outlook agrega la firma automáticamente.
- Referencias: «~/rules/rulesets/MAIL.md» ([../rulesets/MAIL.md](../rulesets/MAIL.md)) y «~/rules/MAIL.md» ([../MAIL.md](../MAIL.md)).
