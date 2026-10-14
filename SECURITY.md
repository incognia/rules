# Política de seguridad

## Alcance

Este repositorio es público y contiene reglas, *prompts* de razonamiento (CoT), plantillas y *scripts* de automatización. Una vulnerabilidad puede ser, entre otras cosas:

- Un *script* que exponga credenciales, ejecute código no confiable o borre datos sin querer.
- Datos sensibles publicados por error: credenciales, IP o *hosts* internos, nombres de clientes o datos de contacto personales.
- Un *workflow* de CI que conceda permisos de más o filtre secretos.

## Cómo reportar una vulnerabilidad

No abras un *issue* público. Repórtala en privado por alguno de estos medios:

1. **Reporte privado de vulnerabilidades de GitHub**: en la pestaña «Security» del repositorio, elige «Report a vulnerability».
2. **Correo electrónico**: escribe a <incognia@gmail.com> con el asunto «Seguridad: rules».

Incluye, si puedes:

- El archivo y la línea, o el *commit*, afectados.
- Los pasos para reproducir el problema.
- El impacto que esperas y, si la tienes, una propuesta de corrección.

Respondo en un plazo de siete días naturales. Si confirmo el problema, acordamos contigo la corrección y el momento de hacerla pública, y te doy crédito si así lo quieres.

## Credenciales y datos sensibles

- Las credenciales y los datos sensibles viven solo en el archivo `.env`, que no se versiona (modo 600). La plantilla pública es `.env.example`, sin valores reales.
- Los archivos versionados usan marcadores como `<client_ip>` o `{GATEWAY_IP}` en lugar de valores reales.
- El CI ejecuta gitleaks en cada *push* y *pull request* hacia `main` para detectar secretos nuevos.

## Historial de git

El historial de git **no se reescribe** para quitar datos expuestos en el pasado (decisión del 2026-10-12): la protección se aplica de aquí en adelante. Si encuentras un secreto en un *commit* antiguo, repórtalo de todos modos; la respuesta es revocarlo o rotarlo, no reescribir el historial con `git filter-repo` ni hacer *force push*.
