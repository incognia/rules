---
domain: infrastructure
task: analizar estado de clúster Kubernetes vía SSH
dificultad: intermedio
longitud_objetivo: media
validacion: reporte de estado con nodos, pods, servicios, VirtualServices e Istio
---
<!-- markdownlint-disable MD041 -->

Razonamiento:
- Los clústeres corren sobre bare-metal con Istio, ArgoCD, Prometheus, Grafana y Kiali.
- El acceso es vía SSH con usuario `ubuntu` (u otro) y llave `kone` (infra propia) o `cad` (clientes).
- Los manifiestos están en `/home/<usuario>/kubernetes-<namespace>/services/`.
- Referencia principal: «~/rules/rulesets/KUBE.md» ([../rulesets/KUBE.md](../rulesets/KUBE.md)).

Pasos:
1) Acción: conectar al servidor vía SSH.
   Resultado: `ssh -i ~/.ssh/<llave> <usuario>@<ip>`
   Verificar: conexión exitosa, `kubectl` disponible.

2) Acción: verificar estado general del clúster.
   Resultado:
   - `kubectl get nodes -o wide` → todos los nodos en Ready
   - `kubectl top nodes` → uso de CPU y memoria

3) Acción: listar pods del *namespace* objetivo.
   Resultado:
   - `kubectl get pods -n <namespace> -o wide`
   - Buscar pods en estado distinto a Running/Completed
   - Si hay problemas: `kubectl describe pod <pod> -n <namespace>`

4) Acción: revisar servicios y endpoints.
   Resultado:
   - `kubectl get svc -n <namespace>`
   - `kubectl get endpoints -n <namespace>`

5) Acción: revisar VirtualServices e Istio.
   Resultado:
   - `kubectl get vs -n <namespace>`
   - `kubectl get gateway -n <namespace>`
   - `istioctl analyze -n <namespace>` (si está disponible)
   - `istioctl proxy-status` (verificar sincronización de sidecars)

6) Acción: verificar ArgoCD.
   Resultado:
   - `kubectl get app -n argocd | grep <namespace>`
   - Confirmar estado Synced y Healthy

7) Acción: revisar eventos recientes.
   Resultado:
   - `kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20`

8) Acción: revisar manifiestos en disco.
   Resultado:
   - `ls /home/<usuario>/kubernetes-<namespace>/services/overlays/dev/`
   - `ls /home/<usuario>/kubernetes-<namespace>/services/base/`

9) Acción: verificaciones de salud de servicios.
   Resultado:
   - Obtener IP del Gateway: `kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
   - `curl -s http://<gateway_ip>/<prefijo>/actuator/health`

10) Acción: verificar observabilidad.
    Descubrir IPs y puertos: `kubectl get svc -n istio-system | grep -iE 'kiali|prometheus|grafana'`
    Resultado:
    - Kiali: puerto 20001 (LoadBalancer o NodePort)
    - Prometheus: puerto 9090 (NodePort)
    - Grafana: puerto 3000 (LoadBalancer o NodePort)
    - Verificar acceso: `curl -s -o /dev/null -w "%{http_code}" http://<ip>:<puerto>`

Conclusión:
- Entregar reporte con: estado de nodos, pods problemáticos, servicios y VirtualServices, estado de ArgoCD, eventos recientes y estado de observabilidad.
- Si hay problemas, incluir logs relevantes (`kubectl logs <pod> -n <namespace> --tail=50`).
- Referencias: «~/rules/rulesets/KUBE.md» ([../rulesets/KUBE.md](../rulesets/KUBE.md)).
