# Reglas de *troubleshooting* en clústeres Kubernetes

## Propósito

Este documento define las convenciones para diagnosticar y resolver problemas en microservicios desplegados sobre Kubernetes con Istio.

## Metodología: de afuera hacia adentro

El diagnóstico siempre sigue este orden:

1. **Eventos** → detectar *namespaces* y recursos con fallas
2. **Pods inestables** → priorizar por reinicios
3. **Patrones de error** → identificar causa en logs
4. **Dueño** → determinar Deployment/StatefulSet afectado
5. **Red** → verificar Service, Endpoints, VirtualService
6. **Dependencias** → buscar dependencias *cross-namespace*
7. **Corrección** → proponer y validar sin desplegar

## Comandos de diagnóstico

### Eventos recientes (panorama global)

```bash
kubectl get events --all-namespaces --sort-by=.lastTimestamp | tail -50
```

### Pods con más reinicios

```bash
kubectl get pods -A --sort-by=.status.containerStatuses[0].restartCount | tail -30
```

### Describir pod problemático (eventos + dueño)

```bash
kubectl describe pod -n <namespace> <pod>
```

### Logs por etiqueta (todas las réplicas)

```bash
kubectl logs -n <namespace> -l app=<servicio> --since=60m --tail=500
```

### Verificar Service y Endpoints

```bash
kubectl get svc,ep -n <namespace> | grep -E "<servicio>|<dependencia>"
```

### Búsqueda *cross-namespace* de dependencias

```bash
# Buscar un servicio en todos los namespaces
kubectl get svc -A | grep -i <dependencia>
```

### Verificar resolución DNS desde un pod temporal

```bash
kubectl -n <namespace> run tmp --rm -it --image=busybox --restart=Never -- \
  nslookup <servicio>.<namespace>.svc.cluster.local
```

### Verificar conectividad de red

```bash
kubectl -n <namespace> run tmp --rm -it --image=busybox --restart=Never -- \
  nc -vz <servicio>.<namespace>.svc.cluster.local <puerto>
```

## Errores comunes

### `CrashLoopBackOff`

- Revisar logs del contenedor: `kubectl logs <pod> -n <namespace> --previous`
- Verificar variables de entorno y *ConfigMaps*
- Verificar que las dependencias (DB, Redis, *message broker*) estén accesibles

### `ImagePullBackOff`

- Verificar que la imagen existe en el registro (ECR, Harbor, etc.)
- Verificar *secrets* de acceso al registro: `kubectl get secret -n <namespace> | grep registry`

### Timeouts en *gateway*/ingreso

- Correlacionar con el servicio *backend*: los *timeouts* del *gateway* suelen ser síntoma de una falla aguas abajo
- Verificar VirtualService y DestinationRule de Istio

### Dependencia *cross-namespace*

- Si `REDIS_HOST=redis` (sin FQDN), resuelve a `redis.<namespace-actual>.svc.cluster.local`
- Corrección: usar FQDN completo `redis.<namespace-real>.svc.cluster.local` o crear `ExternalName` Service

## Regla de oro

**Nunca desplegar una corrección sin validar la hipótesis primero.** Usar pod temporal con `busybox` para verificar DNS y conectividad antes de modificar cualquier recurso.

---

*Elaborado por Rodrigo Álvarez (@incogniadev)*
