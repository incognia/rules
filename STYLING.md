# Reglas de estilo

Este documento define las convenciones de estilo para documentos Markdown en diferentes contextos.

## Estructura del documento

### Orden de secciones

1. **Metadatos y encabezado** - Tags, logos y títulos principales
2. **Contenido principal** - Desarrollo del tema
3. **Pie de página** - Información de licencia y contacto
4. **Estilos CSS** - Definiciones de apariencia (si aplica)

## Personal

*Por definir...*

## Laboral

### Encabezado estándar

Todo documento laboral debe incluir el siguiente encabezado:

```markdown
---
tags: tag-1, tag-2, tag-3, tag-opcional
---

![PROMAD logo](https://hedgedoc.promad.com.mx:31418/uploads/eac9bca0-66f5-463e-9ccb-8813341a549c.png)

# Primer encabezado nivel 1

<div style="text-align: right;"><em>Última modificación: 31 de julio de 2025, 11:59 (CST)</em></div><br>

```

**Notas importantes:**
- Los tags deben ser descriptivos y relevantes al contenido
- El logo de PROMAD es obligatorio en documentos corporativos
- El primer encabezado debe ser claro y conciso
- La fecha de "Última modificación" debe actualizarse con la fecha y hora real al momento de editar el documento (formato: DD de mes de AAAA, HH:MM (CST))

### Pie de página estándar

Todo documento laboral debe concluir con el siguiente pie de página:

```markdown
---

[Información de licencia generada automáticamente desde LICENSING.md]

---

## Contacto

[//]: # (CSS Contacto) 

<style>
  .avatar {
    border-radius: 50%;
  }
  
  .markdown-body i {
    color: var(--electric);
  }
</style>

<table>
  <tr>
    <td rowspan='5' colspan='1'>
      <img src="https://1.gravatar.com/avatar/e51a2b0e2b142d574963de682099716c?s=160" class="avatar">
    </td>
    <td>
      <b>Rodrigo Ernesto Álvarez Aguilera</b>
    </td>
  </tr>
  <tr>
    <td>Ingeniero DevOps</td>
  </tr>
  <tr>
    <td>
      <i class="fa fa-envelope"></i>
      <a href="mailto:ralvarez@promad.com.mx">ralvarez@promad.com.mx</a>
    </td>
  </tr>
  <tr>
    <td>
      <i class="fa fa-briefcase"></i>
      Ejército Nacional 57, Miguel Hidalgo
    </td>
  </tr>
  <tr>
    <td>
      <i class="fa fa-phone"></i>
      +52 (55) 7980-9502
    </td>
  </tr>
</table>

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

1. **Separador de licencia** - Línea horizontal con información de licencia (debe reemplazarse con el contenido real del archivo LICENSING.md del proyecto)
2. **Sección de contacto** - Información personal y profesional
3. **Avatar circular** - Imagen de perfil con bordes redondeados
4. **Datos de contacto** - Email, dirección y teléfono con iconos
5. **CSS corporativo** - Definición de colores y estilos de marca

### Paleta de colores corporativa

| Variable | Color | Hexadecimal | Uso |
|----------|--------|-------------|-----|
| `--promad` | Azul Promad | `#00B2E0` | Color principal de marca |
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

- [ ] Encabezado con logo y tags apropiados
- [ ] Estructura jerárquica correcta de encabezados
- [ ] Pie de página con información de contacto actualizada
- [ ] CSS corporativo incluido y funcional
- [ ] Enlaces e imágenes funcionando correctamente
- [ ] Formato consistente con otros documentos del proyecto
