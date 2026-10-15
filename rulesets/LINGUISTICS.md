# Reglas lingüísticas de español mexicano como referente

*Última modificación: 14 de octubre de 2026, 00:03 (CST)*

## Regla principal

**Todo el contenido debe escribirse en español mexicano, sin calcos del inglés ni regionalismos de otras variantes del español**

---

## Usar español mexicano

### Términos técnicos

- **«IA»** (no «AI»)
- **«Biblioteca»** (no «librería») [CRÍTICO]
- **«TI»** (no «IT»)
- **«Computadora»** (no «ordenador» ni «computador»)
- **«Archivo»** (no «fichero»)
- **«Carpeta»** (no «directorio»)
- **«Aplicación»** (no «app» ni «aplicativo»)
- **«Almacenamiento»** (no «storage»)
- **«Predeterminado»** (no «por defecto»)
- **«Clúster»** (no «cluster», con tilde en español)
- **«Métricas»** (con tilde) para datos de observabilidad

### Verbos técnicos

- **«Desplegar»** (no «deployar»)
- **«Respaldar»** (no «backupear»)
- **«Compilar»** (no «buildear»)
- **«Depurar»** (no «debugear»)
- **«Probar/Poner a prueba/Checar»** (no «testear»)
- **«Confirmar cambios»** (no «commitear»)
- **«Reflejar»** (no «mirrorear»)
- **«Hacer clic»** (no «clickear»)
- **«Descargar»** (no «bajar»)

### Préstamos técnicos: usar cursivas

- **«Hacer *commit*»** (término técnico específico)
- **«*Pull request*»** (concepto sin traducción directa)
- **«*Pipeline* de CI/CD»** («tubería» no capta el concepto)
- **«*Container*»** (cuando es concepto técnico específico)
- **«*Render*»** (proceso de renderizado)
- **«*Stack* tecnológico»** (más usado en México que «pila», que es peninsular)
- **«*bare-metal*»** (infraestructura física directa, sin equivalencia directa en español técnico)

---

## Evitar

### Calcos del inglés

- «Realizar» (perform) → «Hacer/Ejecutar/Llevar a cabo»
- «Actualmente» (currently) → «En este momento/Ahora»
- «Eventualmente» (eventually) → «Finalmente/Al final/En algún momento»
- «Soportar» (support) → «Admitir/Permitir»
- «Implementar» (implement) → «Poner en práctica/Aplicar»
- «Cambios rompedores» (breaking changes) → «Cambios incompatibles»
- «Direccionar» (directing) → «Dirigir/Llevar/Trasladar»
- «App» (application) → «Aplicación»

### Peninsularismos (España)

- «Ordenador» → «Computadora»
- «Fichero» → «Archivo»
- «Aplicativo» → «Aplicación»
- «Vale» → «Está bien/De acuerdo»
- «Tío/Chaval» → «Compa/Amigo»

### Argentinismos

- «Bárbaro/Genial» → «Excelente/Perfecto»
- «Piola» → «Bueno/Funciona bien»

### Colombianismos

- «Bacano» → «Bueno»
- «Computador» → «Computadora»

### Otros regionalismos

- «Chévere» (Venezuela) → «Excelente»
- «Pana» (Venezuela) → «Amigo»
- «Chiche» (Nicaragaua) → «Fácil»

---

## Expresiones idiomáticas mexicanas

### Expresiones técnicas y profesionales

- **«Inventar el hilo negro»/«Inventar el caldo de pollo»** (no «reinventar la rueda») - Presentar como nuevo algo que ya existe
- **«Está padre»** - Funciona excelente, está muy bien hecho (por ejemplo, «El clúster de Kubernetes está padre»)
- **«Le está echando ganas»/«Le está chingando»** - Trabaja con mucho esfuerzo y dedicación
- **«Ya quedó»** - Se completó exitosamente (por ejemplo, «El despliegue con Argo CD ya quedó»)
- **«Se la rifó»** - Hizo un trabajo excelente, se esforzó mucho
- **«No le sabe»** - No tiene conocimiento suficiente del tema (por ejemplo, «No le sabe a Istio»)
- **«Le sabe un chingo»/«Ya se la sabe»** - Tiene mucho conocimiento y experiencia (por ejemplo, «Le sabe un chingo a Proxmox» o «no le explico porque ya se la sabe»)

### Expresiones de evaluación

- **«Está chido»** - Está bien, funciona correctamente
- **«Está padre»** - Funciona muy bien
- **«Está con madre»** - Funciona muy bien, excelente calidad
- **«Está chingón»** - Funciona muy bien, excelente calidad, agradable a la vista
- **«Está perro»** - Muy bueno, impresionante
- **«Está machín»** - Muy bueno, robusto, confiable
- **«Está del nabo»** - No funciona bien, tiene problemas (y eres chavorruco)
- **«No está padre»** - No funciona bien, tiene problemas
- **«Es chafa»** - De mala calidad, deficiente
- **«Ya valió madres»** - Se rompió, falló completamente

### Expresiones de proceso y tiempo

- **«Al chile»** - Hablando en serio, siendo honesto
- **«A toda madre»** - Muy rápido, funcionando perfectamente
- **«En chinga»** - Muy rápido, con urgencia
- **«De volada»** - Muy rápido, inmediatamente
- **«Está relajado»** - Es fácil, sin complicaciones
- **«Está cañón»** - Es muy difícil o problemático
- **«Está cabrón»** - Es muy difícil o complejo (técnicamente)

### Expresiones de comprensión

- **«Ya me cayó el veinte»** - Ya entendí, ya me di cuenta
- **«Está clarísimo»** - Se entiende perfectamente
- **«No le entiendo ni madres»** - No comprendo nada del tema
- **«Está bien fácil»** - Es muy sencillo de entender o hacer

### Uso profesional de expresiones

**Apropiadas en:**

- Conversaciones informales entre colegas mexicanos (quienes las conocen) y de otras nacionalidades (para que se familiaricen con ellas)
- Mensajes y notas informales en proyectos personales (los comentarios en código van en inglés internacional (UK))
- Documentación interna de equipos mexicanos

**Moderar en:**

- Documentación oficial o formal
- Comunicación con clientes internacionales
- Presentaciones corporativas formales

---

## Reglas tipográficas

### Títulos y encabezados

**Sólo se usan mayúsculas en la letra inicial y en nombres propios**

- Correcto: «Instalación de Prometheus»
- Incorrecto: «Instalación De Prometheus»
- Correcto: «*Script* para crear VM en Proxmox VE»
- Incorrecto: «*Script* Para Crear VM En Proxmox VE»

**No se usan puntos en títulos y subtítulos**

**IMPORTANTE:** en títulos de tercer nivel (###) NO corregir las mayúsculas si ya están bien aplicadas según las reglas anteriores

*Ejemplos correctos e incorrectos de títulos de tercer nivel (###):*

- Correcto: `### Configuración de Proxmox VE` (NO cambiar)
- Correcto: `### Instalación de Docker` (NO cambiar)
- Correcto: `### Métricas de observabilidad` (NO cambiar)
- Incorrecto: `### configuración de proxmox ve` (necesita corrección)
- Incorrecto: `### Configuración De Proxmox VE` (necesita corrección)

****CRÍTICO:** después de dos puntos y seguido se escribirá con minúscula en todos los casos, excepto nombres propios (error MUY frecuente)**

*Ejemplos de mayúsculas después de dos puntos:*

- Correcto: **Regla:** los nombres de archivos deben estar en inglés
- Incorrecto: **Regla:** Los nombres de archivos deben estar en inglés

### Tiempos verbales en documentos

- Reportes y *postmortems*: usar tiempo pasado y primera persona («yo» o «nosotros» si es trabajo colectivo).
- Guías y manuales: usar segunda persona (tú) en presente/imperativo o futuro para pasos por realizar.
- En listas de pasos se puede omitir el sujeto: «Instala», «Ejecuta», «Verifica».
- Evitar construcciones impersonales en tercera persona («se configuró», «se debe instalar»).

**Ejemplos correctos para reportes (pasado, primera persona):**

- «Configuré Proxmox en el servidor»
- «Instalé Docker y desplegué los contenedores»
- «Apliqué las métricas de observabilidad»
- Incorrecto: «Se configuró Proxmox en el servidor» (tercera persona impersonal)

**Ejemplos correctos para guías (segunda persona, presente/futuro):**

- «Configura Proxmox en tu servidor»
- «Instala Docker y despliega los contenedores»
- «Debes aplicar las métricas de observabilidad»
- Incorrecto: «Se debe configurar Proxmox en el servidor» (tercera persona impersonal)

**Comprobación rápida:**

- ¿Lo hiciste ya? → describe en pasado y en primera persona.
- ¿Lo hará la persona lectora? → instruye en segunda persona (presente/imperativo o futuro).

### Fechas y horas (CST Ciudad de México)

- Usar formato de 24 horas y zona horaria de la Ciudad de México.
- Calcular la **hora local** correctamente antes de añadir el sufijo «CST». No rotular «CST» una hora calculada en UTC.
- Zona a usar: `America/Mexico_City` (UTC−06:00; sin horario de verano).
- Formatos aceptados:
  - Corto: «2025-07-28 14:30 CST»
  - Largo: «28 de julio de 2025, 14:30 (CST)»; con `LC_TIME=es_MX.UTF-8 TZ=America/Mexico_City date '+%-d de %B de %Y, %H:%M (%Z)'` (el *locale* en español garantiza el nombre del mes en español)
- Ejemplos en shell:
  - `TZ=America/Mexico_City date '+%F %H:%M %Z'`
  - `TS=$(TZ=America/Mexico_City date '+%F %H:%M %Z'); echo "$TS"`
- En *scripts* y generadores, NO confiar en la zona predeterminada del sistema: establecer `TZ=America/Mexico_City` explícitamente.

### Comillas

- **Usar comillas angulares «»** en texto Markdown
- **Conservar comillas dobles ""** en código, *scripts* y sus comentarios (que van en inglés internacional (UK))
- **Ejemplo**: «Biblioteca» (no «librería») en texto Markdown

```bash
# Directory that stores the VM backup
BACKUP_DIR="/var/backups"

# Back up the virtual machine
backup_vm() {
    echo "Starting backup..."
}
```

### Sutilezas de redacción

- **No comenzar oraciones con cifras.** Preferir redactar con palabras o reordenar la frase.
  - Incorrecto: «20 años después, sigo aquí esperando»
  - Correcto: «Después de 20 años sigo esperando»
- **Evitar terminar párrafos con símbolos o abreviaturas.** Sustituir por la palabra completa o reestructurar.
  - «Hay un déficit de 20%» → «Hay un déficit de 20 por ciento»
  - «Trajeron higos, mangos, etc.» → «Trajeron higos, mangos, etcétera» (si es posible, especificar la lista completa)
- Nota: esta práctica proviene de criterios editoriales periodísticos y se observa también en subtitulación profesional (las frases que comienzan con número se escriben con letra).

### Préstamos lingüísticos

- **Usar cursivas** para términos técnicos sin traducción directa
- **Ejemplo**: «Hacer *commit* de los cambios» (no «commitear»)
- **Criterio**: si el término técnico es universalmente usado en inglés

### Nomenclatura de archivos

- **Regla general:** los nombres de archivos, carpetas y *scripts* deberán estar en inglés internacional, incluso si el contenido del documento o *script* está redactado en español mexicano.
- **Regla específica para Markdown:** los archivos Markdown deben usar `NOMBRES_EN_MAYUSCULAS.md` (nombre en mayúsculas, extensión en minúsculas).
- **Ejemplos válidos:** `README.md`, `PHILOSOPHY.md`, `LINGUISTICS.md`, `COMMITTING.md`
- **Ejemplos inválidos:** `readme.md`, `Philosophy.md`, `LINGUISTICS.MD`
- **Justificación:** garantiza consistencia técnica, facilita la interoperabilidad en contextos multilingües y mejora la legibilidad en sistemas de archivos.

---

## Justificación

### Demográfica y cultural

- **México:** la mayor población hispanohablante nativa del mundo (más de 130 millones de habitantes).
- **España:** país pequeño con menor relevancia cultural mundial (47 millones).
- **Productos culturales:** doblaje de películas, series y videojuegos, entre otros, usan español mexicano.
- **Distribución internacional**: Netflix, Disney y otros estudios usan español mexicano como estándar.

### Criterio para el inglés

- El **español mexicano** es el referente del español por peso demográfico y cultural, no por imposición de un registro ajeno.
- Para el inglés el criterio es distinto: no se elige por dominio cultural, sino como **registro neutro de colaboración** internacional.
- **En estos repositorios:** todo lo que se redacta en inglés (mensajes de *commit*, código y comentarios en código, `CHANGELOG.md` de repositorios en inglés) usa **inglés internacional (UK)**, con ortografía británica (`-ise`, *colour*, *behaviour*, *licence*) como registro neutro de colaboración.
- **Confluence:** todo lo que se publica en Confluence (páginas y comentarios) va en inglés internacional (UK).

---

## Odios especiales

Los siguientes términos generan **rechazo particular** y deben evitarse a toda costa:

- **«Librería»** por «biblioteca» - INACEPTABLE
- **«IT»** por «TI» - usar siempre el español
- **Peninsularismos** («ordenador», «fichero») - RECHAZADOS
- **Verbos inventados con -ear** (commitear, deployear) - EVITAR
- **Títulos Con Cada Palabra En Mayúscula** - Usar solo en la primera palabra
- **Uso de mayúscula donde no corresponde** - «Lunes» por «lunes» o «Julio» por «julio» - INACEPTABLE
- **Mayúscula después de dos puntos** - «Razón: Los nombres...» por «Razón: los nombres...» - ERROR MUY FRECUENTE E INACEPTABLE
- **Pluralizar las siglas** - «VMs/VEs/ONGs» por «VM/VE/ONG» - Sin importar si es uno o 20: INACEPTABLE
- **Escribir en tercera persona** - «Se realizo/Se hizo/Se diseñó/Se configuró» en vez de «Hice/Llevé a cabo/Apliqué/Configuré» - ESPECIALMENTE INACEPTABLE

---

## Criterio de evaluación

**¿La palabra o expresión sonaría natural para un mexicano sin conocimiento de inglés?**

- Si SÍ → usar
- Si NO → buscar alternativa mexicana

---

## Aplicación

Esta regla se aplica en:

- Documentación técnica
- Mensajes para el usuario de *scripts* y herramientas
- Toda comunicación escrita en español

No se aplica al código ni a los comentarios en código, a los mensajes de *commit* ni a lo que se publica en Confluence: todo eso va en inglés internacional (UK). El `CHANGELOG.md` y las *releases* siguen el idioma principal del repositorio.

---

*Este documento fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Elaborado por Rodrigo Álvarez (@incognia)*
