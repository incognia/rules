---
domain: workflow
task: aplicar el licenciamiento correcto (GPLv3 personal o MIT laboral) con archivo LICENSE y pie de README
dificultad: baja
longitud_objetivo: media
validacion: LICENSE creado con el texto completo y el año en curso; pie del README presente una sola vez, sin borrar contenido ajeno
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Aplicar las reglas de «~/rules/rulesets/LICENSING.md» ([../rulesets/LICENSING.md](../rulesets/LICENSING.md)): proyectos personales (`@incognia`) con GNU GPLv3 y proyectos laborales (`@incogniadev`, Kabat One) con MIT.
- Detectar el contexto con indicadores del README y, si es ambiguo, preguntar al usuario en vez de adivinar.
- Indicadores laborales: «Kabat One», `@kabatone.com`, `@incogniadev` o, en repositorios antiguos, «Promad» (`@promad.com.mx`). Indicadores personales: `@incognia`, `incognia@gmail.com`, `github.com/incognia`, proyectos de aprendizaje o experimentación.
- El año del *copyright* siempre se calcula con `date +%Y`; nunca se escribe fijo.
- El pie del README se delimita con marcadores HTML (`<!-- licence:start -->` y `<!-- licence:end -->`) para poder reemplazarlo sin tocar el resto del archivo. Nunca borrar rangos que empiecen en el primer `---`, porque ese separador también abre el *frontmatter* YAML y aparece en el cuerpo.
- Los comandos deben funcionar con BSD (macOS) y GNU: nada de `sed -i` sin sufijo; editar con `awk` a un archivo temporal y `mv`.

Pasos:

1) Acción: validar que existe `README.md` en la raíz del proyecto.
   Resultado: `test -f README.md`. Si no existe, pedir al usuario los datos del proyecto y crear un README básico antes de continuar.

2) Acción: detectar el contexto del proyecto.
   Resultado:

   ```bash
   LABORAL=$(grep -ciE 'kabat|@kabatone\.com|@incogniadev|promad|@promad\.com\.mx' README.md || true)
   PERSONAL=$(grep -ciE '@incognia([^d]|$)|incognia@gmail\.com|github\.com/incognia([^d]|$)' README.md || true)
   if [ "$LABORAL" -gt 0 ] && [ "$PERSONAL" -eq 0 ]; then
       PROJECT_TYPE=laboral; LICENSE_TYPE=MIT
   elif [ "$PERSONAL" -gt 0 ] && [ "$LABORAL" -eq 0 ]; then
       PROJECT_TYPE=personal; LICENSE_TYPE=GPLv3
   else
       echo "Contexto ambiguo: pregunta al usuario si es personal o laboral." >&2
   fi
   ```

   Si hay indicadores de ambos tipos o de ninguno, detenerse y preguntar.

3) Acción: crear el archivo `LICENSE` con el año en curso.
   Resultado:

   ```bash
   CURRENT_YEAR=$(date +%Y)
   if [ "$LICENSE_TYPE" = "MIT" ]; then
       cat > LICENSE <<EOF
   MIT License

   Copyright (c) ${CURRENT_YEAR}, Kabat One

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
   EOF
   else
       curl -fsSL https://www.gnu.org/licenses/gpl-3.0.txt -o LICENSE
   fi
   ```

   El *heredoc* va sin comillas (`<<EOF`) para que `${CURRENT_YEAR}` se expanda; el texto de la licencia no contiene otras variables. Si `LICENSE` ya existe, mostrar la diferencia y pedir confirmación antes de reemplazarlo.

4) Acción: escribir el pie del README entre marcadores, sin borrar nada más.
   Resultado: generar el pie en un archivo temporal y reemplazar solo el bloque marcado, o agregarlo al final si no existe:

   ```bash
   FOOTER=$(mktemp)
   if [ "$PROJECT_TYPE" = "laboral" ]; then
       cat > "$FOOTER" <<EOF
   <!-- licence:start -->

   ---

   *Este proyecto fue elaborado por Rodrigo Álvarez para Kabat One y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

   *Copyright © ${CURRENT_YEAR}, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*

   <!-- licence:end -->
   EOF
   else
       cat > "$FOOTER" <<EOF
   <!-- licence:start -->

   ---

   *Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

   *Copyright © ${CURRENT_YEAR}, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*

   <!-- licence:end -->
   EOF
   fi

   if grep -q '^<!-- licence:start -->$' README.md; then
       TMP=$(mktemp)
       awk -v footer="$FOOTER" '
           /^<!-- licence:start -->$/ { while ((getline line < footer) > 0) print line; close(footer); skip = 1; next }
           /^<!-- licence:end -->$/   { skip = 0; next }
           !skip { print }
       ' README.md > "$TMP" && mv "$TMP" README.md
   elif grep -q '^\*Este proyecto fue elaborado por' README.md; then
       echo "README.md ya tiene un pie de licencia sin marcadores: muéstralo al usuario y pide confirmación antes de cambiarlo." >&2
   else
       { echo; cat "$FOOTER"; } >> README.md
   fi
   rm -f "$FOOTER"
   ```

   Si el README ya tiene un pie sin marcadores (proyectos anteriores a esta regla), no borrarlo de forma automática: mostrar las líneas al usuario, y con su confirmación sustituir solo esas líneas por el bloque marcado.

5) Acción: validar el resultado.
   Resultado:
   - `head -3 LICENSE` muestra la licencia correcta y, en MIT, `Copyright (c) <año en curso>, Kabat One`.
   - `grep -c '^<!-- licence:start -->$' README.md` devuelve `1` (un solo pie).
   - `grep -q "Copyright.*${CURRENT_YEAR}.*Rodrigo" README.md` encuentra el *copyright* del año en curso.
   - `git --no-pager diff --stat README.md` confirma que solo cambió el pie.

Conclusión:

- El proyecto queda con `LICENSE` completo (GPLv3 personal o MIT laboral) y un único pie de licencia en el README, con el año calculado por `date +%Y`.
- Ningún paso borra contenido del README fuera del bloque marcado; ante un pie sin marcadores o un contexto ambiguo, se pregunta al usuario.
- Requisitos: `README.md` en el directorio actual y acceso a internet para descargar la GPLv3.
- Referencias: «~/rules/rulesets/LICENSING.md» ([../rulesets/LICENSING.md](../rulesets/LICENSING.md)) y «~/rules/rulesets/ATTRIBUTION.md» ([../rulesets/ATTRIBUTION.md](../rulesets/ATTRIBUTION.md)).
