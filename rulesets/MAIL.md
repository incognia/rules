# Reglas de composición de correos HTML para Outlook Web (OWA)

## Propósito

Este documento define las reglas para componer correos HTML que se copian desde el navegador y se pegan en Outlook Web App (OWA). Las restricciones existen porque OWA elimina gran parte del CSS al pegar.

## Plantillas disponibles

Las plantillas viven en `templates/mail/` de este repositorio:

- **`delivery_template.html`** — entrega de microservicio (Java/Spring Boot). Tiene 7 *placeholders* para reemplazar.
- **`generic_template.html`** — cualquier otro tipo: cambios de configuración, decisiones técnicas, reportes, correcciones.

## Flujo de trabajo

1. Copiar la plantilla con nombre `YYYY-MM-DD-{nombre-corto}.html`
2. Reemplazar los *placeholders*
3. Entregar según el modo elegido:
   - **`owa`**: abrir en navegador → `Ctrl+A` → `Ctrl+C` → pegar en OWA. Outlook agrega la firma al enviar.
   - **`mac`**: abrir borrador en Outlook vía AppleScript. Outlook inyecta la firma «Kabat One». Enviar con ⌘+Enter.
   - **`graph`**: enviar vía Microsoft Graph API con firma como imagen CID *inline*. Ver `~/rules/MAIL.md` para la configuración.

> Invocación con *skill*: `/mail <owa|mac|graph> <delivery|generic> <asunto>`

## Reglas HTML críticas

### Fondos de color: `bgcolor` en `<td>`, nunca solo en `<table>`

OWA solo captura el `background-color` del `<td>` que contiene el texto. Además, duplicar como atributo HTML `bgcolor`.

```html
<!-- CORRECTO -->
<td bgcolor="#d4edda" style="background-color:#d4edda; padding:15px;">Contenido</td>

<!-- INCORRECTO — el fondo no se copia -->
<table style="background-color:#d4edda;"><tr><td>Contenido</td></tr></table>
```

### Estructura del contenedor

Tabla exterior (fondo gris `#f0f0f0`) → tabla interior (fondo blanco `#ffffff`, max 800px). Los fondos van en los `<td>`.

### Cajas de color

El borde izquierdo va en `<table>` (`border-left:4px solid`), el fondo en `<td>` (`bgcolor` + `background-color`).

### Bloques de código

No usar `<pre>` (pierde fondo al copiarse). Usar `<td>` con `white-space:pre-wrap`.

### Código *inline*

`<code>` con estilos *inline* funciona: `background-color:#f4f4f4; padding:2px 5px; font-family:'Courier New',monospace;`

### Tablas de datos

Filas alternas: agregar `style="background-color:#f9f9f9;"` manualmente en cada `<tr>` par. CSS `nth-child` no funciona al copiar.

### Imágenes

`<img>` con `style="max-width:100%; display:block;"`.

## Lo que OWA elimina o ignora

- Bloques `<style>` completos
- Clases CSS
- `background-color` en `<table>` (no en `<td>`)
- `border-radius`
- `overflow-x:auto`
- `tr:nth-child(even)`
- Flexbox, Grid
- `position:absolute`
- *Media queries*

## Paleta de colores

### Colores de acento (borde inferior del H1)

- Entrega / estado OK → `#3498db` azul
- Corrección / cambio → `#e67e22` naranja
- Alerta crítica → `#e74c3c` rojo
- Decisión técnica → `#0066cc` azul oscuro

### Cajas

- *Success* (verde): borde `#28a745`, fondo `#d4edda`
- *Info* (azul): borde `#3498db`, fondo `#ecf0f1`
- *Warning* (amarillo): borde `#ffc107`, fondo `#fff3cd`
- *Danger* (rojo): borde `#dc3545`, fondo `#f8d7da`
- Decisión (azul oscuro): borde `#0066cc`, fondo `#e8f4f8`

### Otros

- Código: fondo `#f4f4f4`
- Encabezado tabla: fondo `#3498db`, texto blanco
- Fila par tabla: `#f9f9f9`

## *Placeholders* de la plantilla de entrega

- `{NOMBRE_SERVICIO}` — nombre completo del microservicio
- `{PREFIJO}` — prefijo de ruta sin slash inicial
- `{VERSION}` — versión desplegada
- `{DESTINATARIO}` — nombre del desarrollador
- `{FECHA}` — fecha en formato largo (ej. 21 de marzo de 2026)
- `{RAMA_BASE}` — rama de origen (main, DEV-1.1, etc.)
- `{DESCRIPCION}` — una oración sobre qué hace el servicio

## Ajustes para Angular/Node.js

- Eliminar sección «Análisis de código (SonarQube)»
- *Pipeline*: 5 *stages* (sin compilar ni SonarQube)
- Docker: cambiar a *multi-stage* Node 22 + Nginx
- Quitar fila de Swagger UI en tabla de acceso
- Tiempo estimado: 5-8 min *build* + 3 min ArgoCD

## Envío vía Microsoft Graph API

Para el modo `graph`, consulta la documentación completa en `~/rules/MAIL.md`. Incluye:

- Registro de la aplicación en Microsoft Entra
- Permisos de API (delegados: `Mail.Send`, `email`, `User.Read`)
- Autenticación por *device code flow*
- Envío con firma *inline* (adjunto CID)
- Credenciales en `~/.secrets.yaml` (clave `GRAPH_API`)

---

*Elaborado por Rodrigo Álvarez (@incogniadev)*
