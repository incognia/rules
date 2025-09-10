---
domain: writing
task: aplicar correctamente las reglas de LINGUISTICS.md a un documento Markdown
dificultad: media
longitud_objetivo: media
validacion: lista de hallazgos + correcciones propuestas alineadas a es_MX y reglas tipográficas
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Regla principal: todo en español mexicano, sin calcos del inglés ni regionalismos ajenos (ver «~/rules/docs/LINGUISTICS.md» ([../../docs/LINGUISTICS.md](../../docs/LINGUISTICS.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md))).
- Recorrer de lo general a lo específico: dialecto/es_MX → evitar calcos → terminología → verbos → préstamos en cursiva → tipografía (títulos y mayúscula tras dos puntos) → comillas (texto vs código) → sutilezas de redacción → siglas → tiempos verbales → fechas/horas (CST) → nomenclatura de archivos → odios especiales → expresiones idiomáticas (uso/moderación).
- Producir hallazgos concretos y una versión corregida mínima (diff mental) cuando aplique.

Pasos:
1) Acción: verificar dialecto y regionalismos.
   Resultado: marcar peninsularismos («ordenador», «fichero», «vale»), argentinismos («piola»), colombianismos («bacano»), otros («chévere») y reemplazar por es_MX («computadora», «archivo», «está bien», «excelente»...).
2) Acción: evitar calcos del inglés frecuentes.
   Resultado: «hacer/ejecutar» (no «realizar» cuando sea calcado), «aplicar/poner en práctica» (no «implementar»), «admitir/permitir» (no «soportar»), «cambios incompatibles» (no «cambios rompedores»), «ahora» (no «actualmente»), etc.
3) Acción: normalizar terminología técnica prioritaria.
   Resultado: «IA», «TI», «computadora», «archivo», «carpeta», «aplicación», «almacenamiento», «predeterminado», «clúster», «métricas», «nodo».
4) Acción: revisar verbos técnicos.
   Resultado: «desplegar», «respaldar», «compilar», «depurar», «probar/poner a prueba», «confirmar cambios», «reflejar», «hacer clic», «descargar»; evitar -ear spanglish (commitear, deployear, buildear...).
5) Acción: préstamos técnicos (cursiva).
   Resultado: cursiva en *commit*, *pull request*, *pipeline*, *container*, *render*, *stack*, *bare-metal*.
6) Acción: tipografía de títulos y encabezados.
   COMANDO OBLIGATORIO: `grep -n "^#" archivo.md` para listar TODOS los títulos H1-H6
   Validación: Revisar cada línea encontrada individualmente y corregir Title Case
   Resultado: estilo oración (primera palabra y nombres propios con mayúscula), sin punto final; después de dos puntos, minúscula salvo nombre propio.
   CRÍTICO: No marcar este paso como completo sin documentar cada título encontrado y su corrección aplicada.
7) Acción: comillas (texto vs código).
   Resultado: «» en texto; "" solo en comentarios de scripts/código. Verificar que ejemplos de código mantengan comillas dobles.
8) Acción: sutilezas de redacción.
   Resultado: no iniciar oración con cifras; evitar cerrar párrafos con símbolos/abreviaturas (usar «por ciento», «etcétera»); reescribir cuando aplique.
9) Acción: siglas.
   Resultado: invariables (no pluralizar: VM, no VMs). Usar numerales o «instancias de VM» para claridad.
10) Acción: tiempos verbales.
    Resultado: reportes en pasado y primera persona; guías en segunda persona (imperativo/presente/futuro); evitar tercera impersonal («se configuró...»).
11) Acción: fechas y horas (CST Ciudad de México).
    Resultado: usar 24 h y TZ=America/Mexico_City; no rotular CST a una hora UTC. En CHANGELOG: solo fecha [YYYY-MM-DD].
12) Acción: nomenclatura de archivos.
    Resultado: nombres en inglés internacional; Markdown en NOMBRES_EN_MAYUSCULAS.md (extensión en minúsculas).
13) Acción: odios especiales (bloqueo explícito).
    Resultado: rechazar «librería» (por «biblioteca»), «IT», peninsularismos, verbos con -ear, Título Con Cada Palabra En Mayúscula, mayúscula tras dos puntos, pluralizar siglas, tercera persona impersonal.
14) Acción: expresiones idiomáticas mexicanas.
    Resultado: permitir en contextos informales internos; moderar en documentación oficial/corporativa; mantener es_MX.

VERIFICACIÓN OBLIGATORIA (antes de completar):
- Ejecutar: `grep -n "^#" archivo.md` y documentar cada título encontrado
- Confirmar: ninguno usa "Título Con Cada Palabra En Mayúscula"
- Listar: todos los cambios de capitalización aplicados
- Validar: uso correcto de cursivas en préstamos técnicos (*stack*, *commit*, etc.)
- Verificar: corrección de todos los calcos del inglés identificados

Conclusión:
- Entregar: (a) lista de hallazgos y reemplazos propuestos; (b) fragmentos corregidos con comillas y mayúsculas adecuadas; (c) si hay timestamps, ejemplo correcto con TZ; (d) nota si se usaron o moderaron expresiones idiomáticas.
- Referencias: «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)), «~/rules/README.md» ([../../README.md](../../README.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md)).
