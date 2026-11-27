---
tags: tag-1, tag-2, tag-3
---

<img src="{HEDGEDOC_LOGO_LIGHT_URL}" class="logo-light" alt="Kabat One logo">

<img src="{HEDGEDOC_LOGO_DARK_URL}" class="logo-dark" alt="Kabat One logo">

# Título del documento

<div style="text-align: right;"><em>Última modificación: DD de mes de AAAA, HH:MM (CST)</em></div><br>

Breve descripción del propósito de este documento.

## Sección principal

Contenido.

### Subsección

Contenido.

---

![FIRMA]({HEDGEDOC_SIGNATURE_URL})

[//]: # (CSS Corporativo)

<style>
  @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&family=Space+Grotesk:wght@300;400;500;600;700&display=swap');
  :root {
    --midday: #00A1FF;
    --midnight: #24326A;
    --ice: #C3D8F3;
    --connect: #31D8FF;
    --code: #007EB5;
    --deep: #060E40;
    --video: #7252D8;
  }
  a {
    color: var(--midday);
  }
  a:visited {
    color: var(--video);
  }
  a:hover {
    color: var(--connect);
    text-decoration: none;
  }
  .markdown-body {
    font-family: 'Space Grotesk', sans-serif;
  }
  .markdown-body h1,
  .markdown-body h2,
  .markdown-body h3,
  .markdown-body h4 {
    font-family: 'Montserrat', sans-serif;
  }
  .markdown-body h1 {
    border-bottom: 1px solid var(--midday);
  }
  .markdown-body p {
    text-align: justify;
  }
  .markdown-body hr {
    height: 1px;
    background-color: var(--midday);
  }
  .logo-dark {
    display: none;
  }
  .night .logo-light {
    display: none;
  }
  .night .logo-dark {
    display: block;
  }
</style>
