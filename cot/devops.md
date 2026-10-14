---
domain: devops
task: falla de despliegue por autenticación al registry
dificultad: media
longitud_objetivo: corta
validacion: pipeline exitoso tras inyectar secreto
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Aplicar formato CoT y español mexicano (ver «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md)) y flujo en «~/rules/rulesets/COMMITTING.md» ([../rulesets/COMMITTING.md](../rulesets/COMMITTING.md))).
- Verificar prerrequisitos de CI/CD y secretos de acceso al registro (*registry*).

Pasos:

1) Acción: revisar el último *job* fallido en CI.
   Resultado: error 401 al hacer `docker pull` del registro corporativo.
2) Acción: verificar variables y secretos del *job*.
   Resultado: no existe la variable `REGISTRY_TOKEN` ni credenciales configuradas.
3) Acción: definir el secreto a nivel de repositorio y referenciarlo en el *job*.
   Resultado: `REGISTRY_TOKEN` definido; *job* actualizado para usar `docker login` con el *token*.
4) Acción: reintentar el *pipeline*.
   Resultado: `docker pull` exitoso y despliegue completado.

Conclusión:

- Solución: inyectar el secreto del *token* del registro a nivel de repositorio y autenticar antes del *pull*.
