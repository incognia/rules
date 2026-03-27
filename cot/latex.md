---
domain: writing
task: generar un documento LaTeX corporativo limpio y compilable con XeLaTeX
dificultad: media
longitud_objetivo: media
validacion: PDF generado sin errores, tablas de ancho completo, bloques de código sólidos con bordes redondeados
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Usar XeLaTeX como motor (Unicode nativo, fontspec, emoji); nunca pdflatex para documentos corporativos.
- CRÍTICO: NO usar pandoc para conversión directa Markdown→PDF. El resultado es mediocre: tablas sin ancho consistente, bloques de código con fondo roto, encabezado/pie imposibles de controlar limpiamente. Usar el Markdown únicamente como referencia de contenido y escribir el .tex desde cero.
- El flujo es: leer el Markdown → descargar imágenes → escribir .tex → compilar → corregir paquetes faltantes → compilar de nuevo.
- Referencia completa de reglas: «~/rules/rulesets/LATEX.md» y «~/rules/rulesets/STYLING.md».
- Aplicar LINGUISTICS.md al contenido en español mexicano.

Pasos:
1) Acción: descargar imágenes localmente antes de escribir el .tex.
   CRÍTICO: XeLaTeX no puede cargar URLs en `\includegraphics`. Siempre `curl -sL URL -o archivo.png` y verificar con `file archivo.png`.
   Resultado: imágenes disponibles en el mismo directorio que el .tex.

2) Acción: escribir el preámbulo completo con los paquetes obligatorios.
   Resultado: incluir en orden — fontspec, geometry, parskip, microtype, xcolor (paleta PROMAD), booktabs, tabularx, colortbl, array, tcolorbox, graphicx, hyperref, xurl, newunicodechar, titlesec, caption.
   Configurar: `\arrayrulecolor{promad}` una vez en el preámbulo para todos los bordes de tabla.

3) Acción: escribir el encabezado estándar.
   Resultado:
   - Logo con `\includegraphics[height=1.8cm]{promad-logo.png}\\`
   - Timestamp debajo, alineado a la derecha: `\makebox[\linewidth][r]{\footnotesize\textit{...}}`
   - NO usar `\hfill` al inicio de línea (no funciona).
   - Título en `\LARGE\bfseries`; subtítulo en `\large` con mayúscula inicial.
   - Metadatos con el comando `\meta{clave}{valor}`.

4) Acción: escribir secciones con `\section{N. Título}` y tablas con `tabularx`.
   Resultado: toda tabla usa `\begin{tabularx}{\linewidth}{...}` con al menos una columna `X`.
   Encabezado de tabla con `\rowcolor{rowhead}`.
   Bordes con `\toprule`, `\midrule`, `\bottomrule` — NUNCA `\hline`.
   Sin líneas decorativas en títulos de sección.

5) Acción: escribir bloques de código con el entorno `codebox` de tcolorbox.
   CRÍTICO: NO usar `lstlisting` directamente — deja líneas blancas entre el texto y el fondo.
   Resultado: `\begin{codebox}...\end{codebox}` genera fondo sólido oscuro (#2d2d2d) con bordes redondeados (arc=5pt).

6) Acción: escribir el pie de página.
   Resultado: `\vfill` + `\noindent\rule{\linewidth}{0.4pt}` (línea gris delgada) + datos de contacto en texto plano.
   Sin avatar — no se maneja bien en LaTeX.

7) Acción: compilar y resolver paquetes faltantes.
   COMANDO: `xelatex -interaction=nonstopmode archivo.tex 2>&1 | grep -iE 'error|missing|not found'`
   CRÍTICO: usar comillas simples en el patrón de grep (zsh interpreta `!` en comillas dobles).
   Si falta un paquete: `sudo dnf install -y 'tex(nombre.sty)'`
   Repetir hasta que la salida del grep esté vacía.
   Nota: grep sin coincidencias retorna exit 1 — eso es éxito, no error.

8) Acción: verificar el PDF generado.
   Resultado: `ls -lh archivo.pdf` confirma tamaño razonable (> 50 KB para documentos con tablas).
   Compilar dos veces si el documento tiene referencias internas o tabla de contenidos.

Conclusión:
- Entregar: archivo .tex limpio + PDF generado + imágenes locales descargadas.
- Verificar: tablas de ancho completo, bloques de código con fondo sólido, timestamp alineado a la derecha, sin «Figura 1» en el logo.
- Si se detecta un paquete faltante durante la compilación, instalarlo con `dnf` y recompilar — nunca intentar omitir el paquete.
- Referencias: «~/rules/rulesets/LATEX.md» ([../rulesets/LATEX.md](../rulesets/LATEX.md)), «~/rules/rulesets/STYLING.md» ([../rulesets/STYLING.md](../rulesets/STYLING.md)) y «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)).
