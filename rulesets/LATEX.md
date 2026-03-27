# Reglas de generación de documentos LaTeX

Este documento define las convenciones para generar documentos LaTeX corporativos en Fedora Linux con XeLaTeX.

## Pandoc vs. LaTeX desde cero

**Pandoc puede convertir Markdown a PDF vía LaTeX, pero el resultado es mediocre e inconsistente:**
- Las tablas no llenan el ancho de página y tienen anchos de columna incorrectos.
- Los bloques de código (`listings`) dejan líneas blancas entre el fondo y el texto.
- El encabezado/pie corporativo requiere parches externos (`--include-in-header`) que se acumulan y son frágiles.
- Los errores de paquetes faltantes son difíciles de anticipar y bloquean la compilación.

**Flujo correcto:**
1. Usar el Markdown como **referencia de contenido** (texto, tablas, datos).
2. Escribir el `.tex` desde cero siguiendo este documento.
3. Compilar con `xelatex` directamente.

Pandoc solo es aceptable para borradores rápidos internos sin requisito de calidad visual.

## Motor y compilación

- **Motor obligatorio:** `xelatex` — soporta Unicode nativo, fontspec y emoji sin conversiones.
- **Compilación:** `xelatex -interaction=nonstopmode archivo.tex`
- **Verificación de errores:** usar comillas simples en `grep` para evitar problemas con `!` en zsh:
  ```bash
  xelatex -interaction=nonstopmode archivo.tex 2>&1 | grep -iE 'error|missing|not found'
  ```
- **Nota:** `grep` retorna exit code 1 cuando no encuentra coincidencias (sin errores). No confundir con fallo real.
- **Instalación de paquetes faltantes:**
  ```bash
  sudo dnf install -y 'tex(nombre.sty)'
  ```

## Fuentes

- **Cuerpo:** `Liberation Sans` (sans-serif; NO usar Liberation Serif en documentos corporativos)
- **Código:** `Liberation Mono`
- **Emoji:** `Noto Emoji` (ya instalado en Fedora vía `google-noto-emoji-fonts`)
- Configuración mínima:
  ```latex
  \usepackage{fontspec}
  \setmainfont{Liberation Sans}
  \setmonofont{Liberation Mono}
  \usepackage{newunicodechar}
  \newfontfamily\emojifont{Noto Emoji}[Renderer=HarfBuzz]
  \newunicodechar{❌}{{\emojifont ❌}}
  \newunicodechar{✅}{{\emojifont ✅}}
  ```

## Página y tipografía

- **Márgenes:** `\usepackage[margin=2cm]{geometry}`
- **Espaciado entre párrafos:** `\usepackage{parskip}` (sin sangría; espacio vertical entre párrafos)
- **Mejora tipográfica:** `\usepackage{microtype}`

## Encabezado estándar

```latex
\includegraphics[height=1.8cm]{promad-logo.png}\\
\makebox[\linewidth][r]{\footnotesize\textit{Última modificación: DD de mes de AAAA, HH:MM (CST)}}

\vspace{10pt}
{\LARGE\bfseries Título principal}\\[4pt]
{\large Subtítulo descriptivo}
\vspace{8pt}
```

**Reglas:**
- El timestamp va **debajo del logo**, alineado a la derecha con `\makebox[\linewidth][r]{...}`
- **No** usar `\hfill` al inicio de línea — no funciona en ese contexto
- Título en `\LARGE\bfseries`; subtítulo en `\large` sin negrita
- Subtítulo con mayúscula inicial (estilo oración)
- Logo siempre local (`promad-logo.png`); **nunca** usar URLs en `\includegraphics`
- Descargar imágenes con `curl -sL URL -o archivo.png` antes de compilar

## Metadatos del documento

Usar el comando `\meta` para consistencia:

```latex
\newcommand{\meta}[2]{\textbf{#1:} #2\\}
```

```latex
\meta{Fecha}{2026-03-23}
\meta{Elaborado por}{Rodrigo Álvarez — Líder DevOps, Promad}
```

## Títulos de sección

```latex
\usepackage{titlesec}
\titleformat{\section}{\large\bfseries}{}{0em}{}
\titlespacing{\section}{0pt}{14pt}{6pt}
```

- **Sin** líneas decorativas bajo los títulos (`\hrule` azul o similar)
- Las líneas de color van **en las tablas**, no en los títulos

## Tablas

**Paquetes obligatorios:**
```latex
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{array}
\renewcommand{\arraystretch}{1.35}
\setlength{\tabcolsep}{8pt}
```

**Color de bordes:** definir una vez en el preámbulo:
```latex
\arrayrulecolor{promad}   % bordes en azul PROMAD
```

**Estructura estándar** (tabla que ocupa el ancho completo):
```latex
\begin{tabularx}{\linewidth}{>{\bfseries}l X}
\toprule
\rowcolor{rowhead} Columna 1 & Columna 2 \\
\midrule
Valor A & Descripción larga que se adapta automáticamente \\
\bottomrule
\end{tabularx}
```

**Especificadores de columna recomendados:**
- `X` — columna flexible que absorbe el espacio restante
- `l` — izquierda fijo
- `c` — centrado fijo
- `>{\bfseries}l` — izquierda en negrita (para columna de parámetro)

**Reglas críticas:**
- Usar siempre `\linewidth` como ancho de tabla, **nunca** `\textwidth` dentro de minipages
- `\toprule`, `\midrule`, `\bottomrule` de `booktabs` — **no** `\hline`
- `\rowcolor{rowhead}` en la fila de encabezado para fondo gris suave

## Bloques de código

**Paquete:** `tcolorbox` — genera bloques con fondo sólido y bordes redondeados.
`listings` solo colorea línea por línea y deja espacios blancos entre ellas.

```latex
\usepackage{tcolorbox}
\tcbuselibrary{listings,skins,breakable}
\tcbset{
  codestyle/.style={
    colback=codebg,
    colframe=codebg,
    boxrule=0pt,
    arc=5pt,
    left=10pt, right=10pt, top=8pt, bottom=8pt,
    breakable,
    listing only,
    listing options={
      basicstyle=\ttfamily\small\color{codefg},
      breaklines=true,
      columns=fullflexible,
    }
  }
}
\newtcblisting{codebox}{codestyle}
```

Uso:
```latex
\begin{codebox}
apt update && apt dist-upgrade
\end{codebox}
```

## Paleta de colores corporativa

```latex
\usepackage{xcolor}
\definecolor{codebg}{HTML}{2d2d2d}    % fondo bloques de código
\definecolor{codefg}{HTML}{f8f8f2}    % texto bloques de código
\definecolor{promad}{HTML}{00B2E0}    % azul PROMAD (bordes de tabla, acentos)
\definecolor{rowhead}{HTML}{e8e8e8}   % fondo encabezado de tabla
```

## Pie de página estándar

```latex
\vfill
\noindent\rule{\linewidth}{0.4pt}
\vspace{4pt}

\textbf{Rodrigo Ernesto Álvarez Aguilera} — Líder DevOps\\
\href{mailto:ralvarez@kabatone.com}{ralvarez@kabatone.com} · Ejército Nacional 57, Miguel Hidalgo · +52 (55) 7980-9502
```

**Reglas:**
- Separador: línea delgada gris (`0.4pt`), **no** azul
- **Sin avatar** — las imágenes de perfil no se manejan bien en LaTeX sin CSS
- Contacto en una o dos líneas de texto plano

## Imágenes

- **Obligatorio:** descargar localmente antes de compilar
- **No usar URLs** en `\includegraphics` con XeLaTeX
- Verificar con `file imagen.png` que la descarga fue exitosa
- Suprimir «Figura 1»:
  ```latex
  \usepackage{caption}
  \DeclareCaptionFormat{empty}{}
  \captionsetup[figure]{format=empty,skip=0pt}
  ```

## Paquetes por instalar en Fedora (session reference)

```bash
sudo dnf install -y pandoc texlive-xetex texlive-collection-latexrecommended
sudo dnf install -y 'tex(newunicodechar.sty)'
sudo dnf install -y 'tex(framed.sty)'
sudo dnf install -y 'tex(xurl.sty)'
sudo dnf install -y 'tex(tcolorbox.sty)'
sudo dnf install -y google-noto-emoji-fonts
```

---

*Elaborado por Rodrigo Álvarez (@incognia)*
