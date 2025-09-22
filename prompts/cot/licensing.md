# CoT: Aplicación automática de licenciamiento

## Contexto
Este Chain of Thought aplica automáticamente el licenciamiento apropiado a un proyecto basándose en las reglas definidas en `../../docs/LICENSING.md`. Determina si el proyecto es personal (GPL) o laboral (MIT) analizando el contenido del README.md.

## Razonamiento

### 1. Análisis del README.md
- **Objetivo:** Determinar la naturaleza del proyecto (personal vs laboral)
- **Indicadores laborales:** Menciones de "Promad", "empresa", "trabajo", correo corporativo (@promad.com.mx)
- **Indicadores personales:** Menciones de usuario personal (@incognia), correo personal (@gmail.com), proyectos de aprendizaje o experimentación

### 2. Selección de licencia
- **Proyectos laborales:** MIT License (permisiva, facilita adopción comercial)
- **Proyectos personales:** GNU GPLv3 (copyleft, mantiene el código libre)

### 3. Aplicación de licenciamiento
- Crear archivo LICENSE con texto completo
- Agregar footer apropiado al README.md
- Validar consistencia con el contexto del proyecto

## Pasos

### Paso 1: Validar existencia del README.md
```bash
if [[ -f "README.md" ]]; then
    echo "✓ README.md encontrado, analizando contenido..."
else
    echo "✗ README.md no encontrado. Creando README básico..."
    # Solicitar información del proyecto para crear README
fi
```

### Paso 2: Analizar naturaleza del proyecto
```bash
# Buscar indicadores laborales
LABORAL_INDICATORS=$(grep -i "promad\|@promad\.com\.mx\|empresa\|corporat\|business" README.md | wc -l)

# Buscar indicadores personales  
PERSONAL_INDICATORS=$(grep -i "@incognia\|@gmail\.com\|personal\|experimento\|aprendizaje\|github\.com/incognia" README.md | wc -l)

if [[ $LABORAL_INDICATORS -gt 0 ]]; then
    PROJECT_TYPE="laboral"
    LICENSE_TYPE="MIT"
    echo "🏢 Proyecto laboral detectado - Aplicando MIT License"
elif [[ $PERSONAL_INDICATORS -gt 0 ]]; then
    PROJECT_TYPE="personal" 
    LICENSE_TYPE="GPLv3"
    echo "👤 Proyecto personal detectado - Aplicando GPL v3"
else
    # Solicitar confirmación manual
    echo "❓ Tipo de proyecto ambiguo. ¿Es personal (p) o laboral (l)?"
fi
```

### Paso 3: Generar archivo LICENSE
```bash
CURRENT_YEAR=$(date +%Y)

if [[ "$LICENSE_TYPE" == "MIT" ]]; then
    # Crear MIT License
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Promad Business Solutions

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
    
elif [[ "$LICENSE_TYPE" == "GPLv3" ]]; then
    # Descargar GPL v3 completa
    curl -s https://www.gnu.org/licenses/gpl-3.0.txt > LICENSE
fi
```

### Paso 4: Agregar footer al README.md
```bash
# Remover footer existente si existe
sed -i '/^---$/,$d' README.md

# Agregar nuevo footer según tipo de proyecto
if [[ "$PROJECT_TYPE" == "laboral" ]]; then
    cat >> README.md << 'EOF'

---

*Este proyecto fue elaborado por Rodrigo Álvarez para Promad Business Solutions y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*
EOF

elif [[ "$PROJECT_TYPE" == "personal" ]]; then
    cat >> README.md << 'EOF'

---

*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
EOF
fi
```

### Paso 5: Validar aplicación
```bash
echo "📋 Validando aplicación de licenciamiento..."

# Verificar archivo LICENSE creado
if [[ -f "LICENSE" ]]; then
    echo "✓ Archivo LICENSE creado correctamente"
    head -3 LICENSE
else
    echo "✗ Error: Archivo LICENSE no fue creado"
fi

# Verificar footer en README.md
if grep -q "Copyright.*2025.*Rodrigo" README.md; then
    echo "✓ Footer de licenciamiento agregado al README.md"
else
    echo "✗ Error: Footer no fue agregado correctamente"
fi

# Mostrar resumen
echo ""
echo "📄 Resumen de licenciamiento aplicado:"
echo "Tipo de proyecto: $PROJECT_TYPE"
echo "Licencia aplicada: $LICENSE_TYPE"
echo "Año de copyright: $CURRENT_YEAR"
```

## Conclusión

Este CoT automatiza la aplicación de licenciamiento siguiendo las reglas establecidas:

1. **Detección automática:** Analiza el README.md para determinar la naturaleza del proyecto
2. **Aplicación consistente:** Usa las plantillas predefinidas según el tipo de proyecto
3. **Validación:** Verifica que los archivos se hayan creado correctamente
4. **Flexibilidad:** Permite intervención manual cuando la detección es ambigua

**Uso:** Ejecutar desde la raíz de cualquier proyecto que tenga README.md para aplicar automáticamente el licenciamiento apropiado.

**Requisitos:** README.md existente en el directorio actual, acceso a internet para descargar GPL v3.