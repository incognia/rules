---
domain: writing
task: aplicar correctamente las reglas de LINGUISTICS.md a un documento Markdown
dificultad: media
longitud_objetivo: media
validacion: lista de hallazgos + correcciones propuestas alineadas a es_MX y reglas tipográficas
---

Razonamiento:
- Seguir el formato CoT del repo y usar español mexicano (ver «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md))).
- Recorrer de lo general a lo específico: dialecto/es_MX → terminología → verbos → tipografía (títulos, comillas, mayúscula tras dos puntos) → siglas → tiempos verbales → fechas/horas (CST) → préstamos en cursiva → nomenclatura de archivos.
- Producir hallazgos concretos y una versión corregida mínima (diff mental) cuando aplique.

Pasos:
1) Acción: verificar dialecto y regionalismos.
   Resultado: marcar peninsularismos («ordenador», «fichero», «vale») o regionalismos ajenos (chévere, bacano) y reemplazar por es_MX («computadora», «archivo», «está bien»...).
2) Acción: normalizar terminología técnica prioritaria.
   Resultado: «IA» (no AI), «TI» (no IT), «computadora», «archivo», «carpeta», «aplicación», «almacenamiento», «predeterminado», «clúster».
3) Acción: revisar verbos técnicos.
   Resultado: «desplegar», «respaldar», «compilar», «depurar», «probar»/«poner a prueba», «confirmar cambios», «reflejar», «hacer clic», «descargar»; evitar -ear spanglish (commitear, deployear...).
4) Acción: tipografía de títulos y encabezados.
   Resultado: estilo oración (solo primera palabra y nombres propios con mayúscula), sin punto final, y cuidar mayúscula después de dos puntos (debe ir en minúscula salvo nombre propio).
5) Acción: comillas y préstamos.
   Resultado: «» en texto; "" solo en código/comentarios; préstamos en cursiva: *commit*, *pull request*, *pipeline*, *bare-metal*.
6) Acción: siglas.
   Resultado: invariables (3 VM), o «3 instancias de VM» si se requiere claridad.
7) Acción: tiempos verbales.
   Resultado: reportes en pasado y primera persona; guías en segunda persona (imperativo/presente/futuro); evitar tercera impersonal («se configuró...»).
8) Acción: fechas y horas (CST Ciudad de México).
   Resultado: usar 24 h y calcular local con TZ=America/Mexico_City (no rotular CST a una hora UTC). CHANGELOG: solo fecha [YYYY-MM-DD].
9) Acción: nomenclatura de archivos.
   Resultado: nombres en inglés internacional y, para Markdown, NOMBRES_EN_MAYUSCULAS.md (extensión minúscula).

Conclusión:
- Entregar: (a) lista de hallazgos y reemplazos propuestos; (b) fragmentos corregidos con comillas y mayúsculas adecuadas; (c) si hay timestamps, ejemplo correcto con TZ.
- Referencias: «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)), «~/rules/README.md» ([../../README.md](../../README.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md)).

