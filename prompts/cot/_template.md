---
domain: devops
task: diagnostico de despliegue fallido
dificultad: media
longitud_objetivo: corta
validacion: salida de comando coincide con estado esperado
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Identificar el punto de falla en el pipeline de despliegue.
- Verificar prerequisitos y dependencias en orden lógico.
- Referencias de estilo y flujo: «~/rules/docs/LINGUISTICS.md» ([../../docs/LINGUISTICS.md](../../docs/LINGUISTICS.md)), «~/rules/docs/COMMITTING.md» ([../../docs/COMMITTING.md](../../docs/COMMITTING.md)) y «~/rules/README.md» ([../../README.md](../../README.md)).

Pasos:
1) Acción: revisar logs de CI en último job fallido.
   Resultado: error de autenticación al acceder al registro de contenedores.
2) Acción: verificar variable de entorno del token de acceso.
   Resultado: variable no definida en el entorno del runner.
3) Acción: consultar documentación interna para provisión de secretos.
   Resultado: el secreto debe inyectarse a nivel de repositorio.

Conclusión:
- Solución: definir el token como secreto del repositorio y referenciarlo en el job; reintentar el pipeline.

