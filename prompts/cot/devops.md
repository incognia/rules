---
domain: devops
task: falla de despliegue por autenticación al registry
dificultad: media
longitud_objetivo: corta
validacion: pipeline exitoso tras inyectar secreto
---

Razonamiento:
- Aplicar formato CoT y español mexicano (ver «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)), «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md)) y flujo en «~/rules/COMMITTING.md» ([../../COMMITTING.md](../../COMMITTING.md))).
- Verificar prerequisitos de CI/CD y secretos de acceso al registry.

Pasos:
1) Acción: revisar el último job fallido en CI.
   Resultado: error 401 al hacer docker pull del registry corporativo.
2) Acción: verificar variables/secretos del job.
   Resultado: no existe variable REGISTRY_TOKEN ni credenciales configuradas.
3) Acción: definir secreto a nivel de repositorio y referenciarlo en el job.
   Resultado: REGISTRY_TOKEN definido; job actualizado para usar docker login con token.
4) Acción: reintentar pipeline.
   Resultado: docker pull exitoso y despliegue completado.

Conclusión:
- Solución: inyectar secreto del token de registry a nivel de repositorio y autenticar antes del pull.

