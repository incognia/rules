---
domain: kubernetes
task: localizar un microservicio problemático correlacionando logs y pods en varios namespaces
dificultad: alta
longitud_objetivo: media
validacion: identificar servicio/despliegue y lista de pods afectados con ventana temporal y patrón de error
---
<!-- markdownlint-disable MD041 -->

Razonamiento:

- Usar un recorrido de afuera hacia adentro: eventos recientes → *pods* inestables → patrones de error → dueño (Deployment/StatefulSet) → Service/Ingress/VirtualService.
- Mantener español mexicano y formato CoT del repo (ver «~/rules/rulesets/LINGUISTICS.md» ([../rulesets/LINGUISTICS.md](../rulesets/LINGUISTICS.md))).
- Referencia principal: «~/rules/rulesets/KUBETBS.md» ([../rulesets/KUBETBS.md](../rulesets/KUBETBS.md)).
- Registrar comandos no interactivos y usar selectores por etiquetas para abarcar réplicas.

Pasos:

1) Acción: listar eventos recientes para detectar *namespaces* y recursos con fallas.
   Resultado: `kubectl get events --all-namespaces --sort-by=.lastTimestamp | tail -n 50` muestra errores en el *namespace* «payments» (ImagePullBackOff y CrashLoopBackOff intermitentes) y *timeouts* en «checkout».
2) Acción: listar los *pods* con más reinicios para priorizar.
   Resultado: `kubectl get pods -A --sort-by=.status.containerStatuses[0].restartCount | tail -n 30` revela los *pods* `payments-api-xxxx` y `checkout-gw-yyyy` con reinicios frecuentes.
3) Acción: describir uno de los *pods* con reinicios para ver eventos y dueño (`ownerReferences`).
   Resultado: `kubectl describe pod -n payments payments-api-xxxx` indica dueño `Deployment/payments-api` y errores de conexión a `redis:6379`.
4) Acción: obtener los *logs* de todos los *pods* del microservicio por etiqueta para encontrar el patrón común.
   Resultado: `kubectl logs -n payments -l app=payments-api --since=60m --tail=500` muestra repetidamente `ERR connection refused` hacia `redis`.
5) Acción: confirmar el Service y los Endpoints del *backend* al que apunta el microservicio problemático.
   Resultado: `kubectl get svc,ep -n payments | grep -E "redis|payments"` muestra `svc/redis` sin *endpoints* (0/0), y `svc/payments-api` normal.
6) Acción: verificar el Deployment o StatefulSet del *backend* (si aplica) y sus *pods*.
   Resultado: `kubectl get deploy,statefulset -n payments | grep -i redis` no lista recursos; `kubectl get pods -n payments -l app=redis` devuelve vacío.
7) Acción: ampliar la búsqueda de Redis en todo el clúster (posible dependencia *cross-namespace*) y revisar la política de DNS.
   Resultado: `kubectl get svc -A | grep -i redis` revela `redis` en el *namespace* `infra`. `kubectl get svc -n infra redis -o yaml` confirma `clusterIP` y selector `app=redis` con *endpoints* activos.
8) Acción: verificar cómo resuelve el microservicio el nombre de *host* `redis` y si usa FQDN.
   Resultado: revisar `kubectl get deploy -n payments payments-api -o yaml | yq '.spec.template.spec.containers[].env'` muestra `REDIS_HOST=redis` (sin FQDN). Con la política DNS predeterminada, `redis` apunta a `redis.payments.svc.cluster.local`, inexistente en `payments`.
9) Acción: correlacionar con el *gateway* o *ingress* de checkout por los *timeouts*.
   Resultado: `kubectl logs -n checkout -l app=checkout-gw --since=60m --tail=500 | grep -i timeout` muestra *timeouts* al llamar a `http://payments-api.payments.svc.cluster.local` (coincide con la degradación de payments-api).
10) Acción: proponer una corrección mínima y validar la hipótesis sin desplegar.
    Resultado: usar variable `REDIS_HOST=redis.infra.svc.cluster.local` o inyectar `DNS search` adecuado; verificar conectividad con un *pod* temporal: `kubectl -n payments run tmp --rm -it --image=busybox --restart=Never -- nslookup redis.infra.svc.cluster.local && nc -vz redis.infra.svc.cluster.local 6379`.

Conclusión:

- Microservicio afectado: «payments-api» (Deployment en el *namespace* «payments»); *pods* con reinicios: `payments-api-xxxx` (y réplicas).
- Causa raíz: variable `REDIS_HOST` apunta a `redis` local del *namespace* «payments», pero el servicio Redis vive en «infra». Falla de resolución DNS/FQDN provoca `connection refused` y desencadena *timeouts* en «checkout».
- Corrección: actualizar la configuración (ConfigMap o variables) a `REDIS_HOST=redis.infra.svc.cluster.local` o crear `Service` local que haga `ExternalName` al Redis de «infra». Validar con un *pod* temporal antes de desplegar.
