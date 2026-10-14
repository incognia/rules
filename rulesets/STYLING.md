# Reglas de estilo

Este documento define las convenciones de estilo para documentos Markdown en diferentes contextos.

## Estructura del documento

### Orden de secciones

1. **Metadatos y encabezado**: *tags*, logotipos y títulos principales
2. **Contenido principal**: desarrollo del tema
3. **Pie de página**: información de licencia y contacto
4. **Estilos CSS**: definiciones de apariencia (si aplica)

## HedgeDoc

Documentos Markdown para HedgeDoc (sin licencia, solo firma corporativa).

### Encabezado estándar

Todo documento HedgeDoc debe incluir el siguiente encabezado:

```markdown
---
tags: tag-1, tag-2, tag-3, tag-opcional
---

<img src="https://hedgedoc.promad.com.mx:31418/uploads/9217e5d8-2a84-4e41-9634-ea3b5a6bd45a.png" class="logo-light" alt="Kabat One logo">

<img src="https://hedgedoc.promad.com.mx:31418/uploads/e0f5ef2b-4519-48ee-bd2d-16013c7f44c4.png" class="logo-dark" alt="Kabat One logo">

# Primer encabezado nivel 1

<div style="text-align: right;"><em>Última modificación: 31 de julio de 2025, 11:59 (CST)</em></div><br>

```

**Notas importantes:**

- Los *tags* deben ser descriptivos y relevantes al contenido
- El logotipo de Kabat One es obligatorio en documentos corporativos de HedgeDoc (no en GitLab ni GitHub)
- El bloque `<div style="text-align: right;">` funciona **solo en HedgeDoc**; GitLab y GitHub eliminan los atributos `style`
- El primer encabezado debe ser claro y conciso
- La fecha de «Última modificación» debe actualizarse con la fecha y hora reales al momento de editar el documento (formato: DD de mes de AAAA, HH:MM (CST))
- **Regla de fecha única:** antes de insertar o actualizar «Última modificación», eliminar cualquier campo de fecha ya reportado (`Fecha:`, `Fecha de reporte:`, `[time=...]` u otra «Última modificación») para dejar solo uno.
- **Zona horaria obligatoria:** siempre usar CST de Ciudad de México (UTC-6), nunca UTC ni otra zona horaria

**Advertencia crítica:** no basta con añadir «CST» a una hora UTC; usa `TZ=America/Mexico_City date`, que hace la conversión (CST = UTC − 6 horas). La regla completa está en [LINGUISTICS.md](./LINGUISTICS.md#fechas-y-horas-cst-ciudad-de-méxico).

**Ejemplos de generación de la marca de tiempo (CST, 24 horas):**

```bash
# Formato corto (ISO-like): 2025-07-31 11:59 CST
TZ=America/Mexico_City date '+%F %H:%M %Z'

# Formato largo en español: 31 de julio de 2025, 11:59 (CST)
# LC_TIME=es_MX.UTF-8 asegura el nombre del mes en español; %Z ya imprime CST
LC_TIME=es_MX.UTF-8 TZ=America/Mexico_City date '+%-d de %B de %Y, %H:%M (%Z)'
```

Si `locale -a` no lista `es_MX.UTF-8`, usa `es_ES.UTF-8` o traduce a mano el nombre del mes; nunca dejes el mes en inglés. El resultado ya incluye «(CST)», así que la plantilla es `Última modificación: <resultado>`, sin agregar otro «(CST)».

### Pie de página estándar

Todo documento HedgeDoc debe concluir con el siguiente pie de página (sin licencia):

```markdown
---

![FIRMA](https://hedgedoc.promad.com.mx:31418/uploads/010e09ff-5e2d-4ba8-828b-850a1424eafa.png)

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
```

**Componentes del pie de página:**

1. **Separador**: línea horizontal
2. **Firma corporativa**: imagen de firma oficial
3. **CSS corporativo**: definición de colores y estilos de marca

### Paleta de colores corporativa

| Variable | Color | Hexadecimal | Uso |
|----------|-------|-------------|-----|
| `--midday` | Azul Kabat One | `#00A1FF` | Color principal de marca: enlaces, borde del H1 y separadores |
| `--midnight` | Azul marino | `#24326A` | Reservado (definido, sin uso en el CSS actual) |
| `--ice` | Hielo | `#C3D8F3` | Reservado (definido, sin uso en el CSS actual) |
| `--connect` | Conectar | `#31D8FF` | Enlaces al pasar el puntero (*hover*) |
| `--code` | Código | `#007EB5` | Acento secundario |
| `--deep` | Profundo | `#060E40` | Azul muy oscuro |
| `--video` | Video | `#7252D8` | Enlaces visitados |

### Reglas de formato

#### Encabezados

- Los encabezados H1 tienen borde inferior en color Midday (`--midday`)
- Usar jerarquía clara: H1 → H2 → H3 → H4
- Evitar saltar niveles de encabezado

#### Texto

- Los párrafos están justificados de forma predeterminada
- Los enlaces cambian de color al pasar el puntero (*hover*)
- Compatibilidad automática con modo claro y oscuro

#### Separadores

- Las líneas horizontales (`---`) usan el color Midday (`--midday`)
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
| *Badges* (`shields.io`) | ✅ | ✅ | ✅ |
| *Frontmatter* YAML (`---`) | ✅ (`tags:`) | ✅ (`title:`, `description:`) | ✅ (tabla horizontal) |

**Regla crítica:** al aplicar el estilo en GitLab o GitHub, eliminar o adaptar cualquier sintaxis exclusiva de HedgeDoc. El *frontmatter* `tags:` de HedgeDoc se quita; el *frontmatter* `title`/`description` de un README.md se conserva.

## Plantillas

Usar las plantillas en `templates/` como punto de partida:

- `templates/hedgedoc.md` — documento genérico para HedgeDoc
- `templates/gitlab-readme.md` — README.md para GitLab (con licencia y *badges*)
- `templates/github-readme.md` — README.md para GitHub (con licencia y *badges*)

## GitLab

Documentos Markdown para GitLab (README.md con licencia, otros documentos sin licencia).

**Encabezado README.md:** con *frontmatter* YAML (`title` y `description`), H1 y marca de tiempo en Markdown puro.

GitHub muestra el *frontmatter* como tabla horizontal. GitLab lo muestra como bloque de código formateado. Ambos lo muestran al inicio del documento.

**Encabezado de otros documentos:** sin *frontmatter*; solo H1 y marca de tiempo en Markdown puro.

```markdown
---
title: "Nombre del proyecto"
description: "Breve descripción del proyecto"
---

# Nombre del proyecto

*Última modificación: DD de mes de AAAA, HH:MM (CST)*
```

> No usar `<div style="...">`: GitLab y GitHub eliminan los atributos `style`.
> Los campos `title` y `description` son los estándar para ambas plataformas; no usar `tags` (exclusivo de HedgeDoc).
> Regla de fecha única: mantener un solo `*Última modificación: ...*`; eliminar cualquier fecha previa redundante.

**Pie de página para README.md:**

Solo *copyright*, sin firma ni CSS. El bloque va entre los marcadores `<!-- licence:start -->` y `<!-- licence:end -->` (ver [LICENSING.md](./LICENSING.md#31-pie-de-página-en-markdown-readmemd)); el año `AAAA` es el año en curso:

```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
```

Para MIT:

```markdown
---

*Este proyecto fue elaborado por Rodrigo Álvarez para Kabat One y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © AAAA, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*
```

**Pie de página para otros documentos:** ninguno.

### *Badges* en README.md

Cuando el README.md incluye licencia, debe incluir *badges* al inicio del contenido (después de la marca de tiempo y antes del primer párrafo). Si ya existen *badges*, verificar que sean correctos y estén actualizados.

***Badge* de licencia MIT:**

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

***Badge* de licencia GPLv3:**

```markdown
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
```

***Badges* adicionales recomendados según plataforma:**

GitLab:

```markdown
[![pipeline status](https://gitlab.com/<namespace>/<repo>/badges/<branch>/pipeline.svg)](https://gitlab.com/<namespace>/<repo>/-/pipelines)
[![coverage](https://gitlab.com/<namespace>/<repo>/badges/<branch>/coverage.svg)](https://gitlab.com/<namespace>/<repo>/-/commits/<branch>)
```

GitHub:

```markdown
[![CI](https://github.com/<owner>/<repo>/actions/workflows/<workflow>.yml/badge.svg)](https://github.com/<owner>/<repo>/actions)
```

**Reglas de *badges*:**

- El *badge* de licencia es obligatorio cuando se especifica `mit` o `gpl`
- Los *badges* van después de la marca de tiempo y antes del primer párrafo de contenido
- Si el README ya tiene *badges*, revisar que coincidan con la licencia y el estado actual del proyecto
- Solo incluir *badges* de CI o cobertura si el proyecto los tiene configurados

## GitHub

Documentos Markdown para GitHub (README.md con licencia, otros documentos sin licencia).

**Encabezado:** idéntico a GitLab: *frontmatter* `title`/`description` solo en README.md, H1 y marca de tiempo en Markdown puro (`*Última modificación: ...*`). Sin `<div style>` ni logotipo; los demás documentos van sin *frontmatter*.
Aplicar la misma regla de fecha única: eliminar fechas reportadas existentes antes de insertar la marca de tiempo final.

**Pie de página:** idéntico a GitLab (*copyright* solo en README.md, sin firma ni CSS).

## Buenas prácticas

### Estructura de contenido

1. **Metadatos apropiados**: usar *tags* descriptivos y relevantes
2. **Imágenes optimizadas**: preferir enlaces estables para logotipos
3. **Accesibilidad**: incluir texto alternativo en imágenes
4. **Diseño adaptable**: el CSS debe funcionar en distintos tamaños de pantalla

### Mantenimiento

- **Actualizar enlaces**: verificar periódicamente que las URLs de imágenes funcionen
- **Consistencia**: mantener el mismo formato en todos los documentos
- **Versionado**: documentar cambios importantes en el estilo

### Adaptaciones por contexto

- **Documentos técnicos**: incluir diagramas con Mermaid cuando sea necesario
- **Documentos internos**: usar el pie de página completo
- **Documentos públicos**: evaluar qué información de contacto incluir

## Validación

Antes de publicar un documento, verificar:

- [ ] HedgeDoc: encabezado con logotipos de Kabat One y *tags* apropiados
- [ ] GitLab/GitHub: README.md con *frontmatter* `title`/`description`; sin logotipo, firma ni CSS
- [ ] Estructura jerárquica correcta de encabezados
- [ ] HedgeDoc: pie de página con firma corporativa y CSS corporativo
- [ ] Enlaces e imágenes funcionando correctamente
- [ ] Formato consistente con otros documentos del proyecto
- [ ] Existe un solo campo de fecha visible (`Última modificación`), sin fechas redundantes
- [ ] Licencia solo en README.md (MIT o GPLv3)
- [ ] Plataforma correcta (HedgeDoc/GitLab/GitHub)

## Edición con herramientas de buscar y reemplazar

**Regla crítica de anclas:** cuando la herramienta de edición del agente recibe un número de línea inicial además del texto a buscar, ese texto debe comenzar en el primer carácter de la línea indicada. Las anclas que inician a mitad de línea fallan siempre, sin importar el número de línea ni la codificación del archivo.

- **Correcto**: empezar el texto a buscar desde el inicio de la línea objetivo, con suficiente contenido único hasta abarcar el fragmento a reemplazar.
- **Incorrecto**: usar como ancla un fragmento que aparece después del primer carácter de la línea.

Cuando el fragmento a reemplazar está en medio de una línea, incluir en el texto a buscar todo desde el inicio de esa línea, y en el reemplazo reproducir la línea completa con la corrección aplicada.

---

*Elaborado por Rodrigo Álvarez (@incognia)*
