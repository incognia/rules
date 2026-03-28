# Reglas de estilo

Este documento define las convenciones de estilo para documentos Markdown en diferentes contextos.

## Estructura del documento

### Orden de secciones

1. **Metadatos y encabezado** - Tags, logos y títulos principales
2. **Contenido principal** - Desarrollo del tema
3. **Pie de página** - Información de licencia y contacto
4. **Estilos CSS** - Definiciones de apariencia (si aplica)

## Hedgedoc

Documentos Markdown para HedgeDoc (sin licencia, solo firma corporativa).

### Encabezado estándar

Todo documento HedgeDoc debe incluir el siguiente encabezado:

```markdown
---
tags: tag-1, tag-2, tag-3, tag-opcional
---

![Kabat One logo](https://hedgedoc.promad.com.mx:31418/uploads/aaa5198c-248f-4642-8c67-00f6edde677a.png)

# Primer encabezado nivel 1

<div style="text-align: right;"><em>Última modificación: 31 de julio de 2025, 11:59 (CST)</em></div><br>

```

**Notas importantes:**
- Los tags deben ser descriptivos y relevantes al contenido
- El logo de Kabat One es obligatorio en documentos corporativos
- El bloque `<div style="text-align: right;">` funciona **solo en HedgeDoc**; GitLab y GitHub eliminan los atributos `style`
- El primer encabezado debe ser claro y conciso
- La fecha de "Última modificación" debe actualizarse con la fecha y hora real al momento de editar el documento (formato: DD de mes de AAAA, HH:MM (CST))
- **Zona horaria obligatoria:** siempre usar CST de Ciudad de México (UTC-6), nunca UTC ni otra zona horaria

⚠️ **ADVERTENCIA CRÍTICA:** Para generar timestamps CST correctos, NO es suficiente añadir "CST" a una fecha UTC. Debes restar 6 horas a UTC para obtener la fecha CST correcta. Por ejemplo, si UTC es 22:21, CST debe ser 16:21 (22:21 - 6 horas = 16:21). Usar `TZ="America/Mexico_City" date` garantiza la conversión automática.

**Ejemplos de generación de timestamp (CST, 24 horas):**

```bash
# Formato corto (ISO-like): 2025-07-31 11:59 CST
TZ=America/Mexico_City date '+%F %H:%M %Z'

# Formato largo en español: 31 de julio de 2025, 11:59 (CST)
LC_TIME=es_MX.UTF-8 TZ=America/Mexico_City date '+%d de %B de %Y, %H:%M (%Z)'
```

### Pie de página estándar

Todo documento HedgeDoc debe concluir con el siguiente pie de página (sin licencia):

```markdown
---

![FIRMA](https://hedgedoc.promad.com.mx:31418/uploads/f8e2dc04-bbf8-41b7-9443-17b483f19beb.png)

[//]: # (CSS Corporativo)

<style>
  :root {
    --promad: #00B2E0;
    --midnight: #0E1821;
    --electric: #116dff;
    --lavender: #a5b7ea;
  }
  a {
    color: var(--midnight);
  }
  .night a {
    color: var(--promad);
  }

  a:hover {
    color: var(--promad);
    text-decoration: none;
  }
  .night a:hover {
    color: var(--lavender);
    text-decoration: none;
  }

  body {
    color: var(--midnight);
  }
  .markdown-body h1 {
    border-bottom: 1px solid var(--promad);
  }
  .markdown-body p {
    text-align: justify;
  }
  .markdown-body hr {
    height: 1px;
    background-color: var(--promad);
  }
</style>
```

**Componentes del pie de página:**

1. **Separador** - Línea horizontal
2. **Firma corporativa** - Imagen de firma oficial
3. **CSS corporativo** - Definición de colores y estilos de marca

### Paleta de colores corporativa

| Variable | Color | Hexadecimal | Uso |
|----------|-------|-------------|-----|
| `--promad` | Azul Kabat One | `#00B2E0` | Color principal de marca |
| `--midnight` | Medianoche | `#0E1821` | Texto principal (modo claro) |
| `--electric` | Azul eléctrico | `#116dff` | Acentos y elementos secundarios |
| `--lavender` | Lavanda | `#a5b7ea` | Hover en modo oscuro |

### Reglas de formato

#### Encabezados

- Los encabezados H1 tienen borde inferior en color PROMAD
- Usar jerarquía clara: H1 → H2 → H3 → H4
- Evitar saltar niveles de encabezado

#### Texto

- Los párrafos están justificados por defecto
- Enlaces cambian de color al hacer hover
- Soporte automático para modo claro y oscuro

#### Separadores

- Las líneas horizontales (`---`) usan el color PROMAD
- Altura fija de 1px para consistencia visual

## Diferencias de sintaxis por plataforma

HedgeDoc admite extensiones que **no funcionan** en GitLab ni GitHub:

| Característica | HedgeDoc | GitLab | GitHub |
|---|---|---|---|
| `[TOC]` tabla de contenidos | ✅ | ❌ | ❌ |
| `:::` bloques admonition (`:::info`, `:::warning`, etc.) | ✅ | ❌ | ❌ |
| `[name=Autor]` metadato de autor | ✅ | ❌ | ❌ |
| `[time=fecha]` metadato de fecha | ✅ | ❌ | ❌ |
| `[color=#hex]` color de texto | ✅ | ❌ | ❌ |
| Bloques `mermaid` nativos | ✅ | ✅ | ✅ |
| CSS inline (`<style>`) | ✅ | ❌ (ignorado) | ❌ (ignorado) |
| HTML arbitrario | ✅ | parcial | parcial |
| Badges (`shields.io`) | ✅ | ✅ | ✅ |
| Frontmatter YAML (`---`) | ✅ (`tags:`) | ✅ (`title:`, `description:`) | ✅ (tabla horizontal) |

**Regla crítica:** Al aplicar styling en GitLab o GitHub, eliminar o adaptar cualquier sintaxis exclusiva de HedgeDoc.

## Plantillas

Usar las plantillas en `templates/` como punto de partida:

- `templates/hedgedoc.md` — Documento genérico para HedgeDoc
- `templates/gitlab-readme.md` — README.md para GitLab (con licencia y badges)
- `templates/github-readme.md` — README.md para GitHub (con licencia y badges)

## GitLab

Documentos Markdown para GitLab (README.md con licencia, otros documentos sin licencia).

**Encabezado README.md:** Con frontmatter YAML (`title` + `description`) + H1 + timestamp en Markdown puro.

GitHub renderiza el frontmatter como tabla horizontal. GitLab lo renderiza como bloque de código formateado. Ambos lo muestran al inicio del documento.

**Encabezado otros documentos:** Sin frontmatter. Solo H1 + timestamp en Markdown puro.

```markdown
---
title: "Nombre del proyecto"
description: "Breve descripción del proyecto"
---

# Nombre del proyecto

*Última modificación: DD de mes de AAAA, HH:MM (CST)*
```

> ⚠️ No usar `<div style="...">` — GitLab y GitHub eliminan atributos `style`.
> Los campos `title` y `description` son los estándar para ambas plataformas; no usar `tags` (exclusivo de HedgeDoc).

**Pie de página para README.md:**

Solo copyright. Sin firma, sin CSS:

```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
```

Para MIT:

```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez para Promad Business Solutions y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*
```

**Pie de página para otros documentos:** Sin footer.

### Badges en README.md

Cuando el README.md incluye licencia, debe incluir badges al inicio del contenido (después del timestamp y antes del primer párrafo). Si ya existen badges, verificar que sean correctos y estén actualizados.

**Badge de licencia MIT:**
```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

**Badge de licencia GPLv3:**
```markdown
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
```

**Badges adicionales recomendados según plataforma:**

GitLab:
```markdown
[![pipeline status](https://gitlab.com/<namespace>/<repo>/badges/<branch>/pipeline.svg)](https://gitlab.com/<namespace>/<repo>/-/pipelines)
[![coverage](https://gitlab.com/<namespace>/<repo>/badges/<branch>/coverage.svg)](https://gitlab.com/<namespace>/<repo>/-/commits/<branch>)
```

GitHub:
```markdown
[![CI](https://github.com/<owner>/<repo>/actions/workflows/<workflow>.yml/badge.svg)](https://github.com/<owner>/<repo>/actions)
```

**Reglas de badges:**
- El badge de licencia es obligatorio cuando se especifica `mit` o `gpl`
- Los badges van después del timestamp y antes del primer párrafo de contenido
- Si el README ya tiene badges, revisar que coincidan con la licencia y el estado actual del proyecto
- Solo incluir badges de CI/cobertura si el proyecto los tiene configurados

## GitHub

Documentos Markdown para GitHub (README.md con licencia, otros documentos sin licencia).

**Encabezado:** Idéntico a GitLab: H1 + timestamp en Markdown puro (`*Última modificación: ...*`). Sin `<div style>`, sin logo, sin frontmatter YAML.

**Pie de página:** Idéntico a GitLab (copyright solo en README.md, sin firma ni CSS).

## Mejores prácticas

### Estructura de contenido

1. **Metadatos apropiados**: Usar tags descriptivos y relevantes
2. **Imágenes optimizadas**: Preferir enlaces estables para logos
3. **Accesibilidad**: Incluir texto alternativo en imágenes
4. **Responsive**: El CSS debe funcionar en diferentes tamaños de pantalla

### Mantenimiento

- **Actualizar enlaces**: Verificar periódicamente que las URLs de imágenes funcionen
- **Consistencia**: Mantener el mismo formato en todos los documentos
- **Versionado**: Documentar cambios importantes en el estilo

### Adaptaciones por contexto

- **Documentos técnicos**: Incluir diagramas con mermaid cuando sea necesario
- **Documentos internos**: Usar el pie de página completo
- **Documentos públicos**: Evaluar qué información de contacto incluir

## Validación

Antes de publicar un documento, verificar:

- [ ] Encabezado con logo Kabat One y tags apropiados
- [ ] Estructura jerárquica correcta de encabezados
- [ ] Pie de página con firma corporativa
- [ ] CSS corporativo incluido y funcional (si aplica)
- [ ] Enlaces e imágenes funcionando correctamente
- [ ] Formato consistente con otros documentos del proyecto
- [ ] Licencia solo en README.md (MIT o GPLv3)
- [ ] Plataforma correcta (HedgeDoc/GitLab/GitHub)

---

*Elaborado por Rodrigo Álvarez (@incognia)*
