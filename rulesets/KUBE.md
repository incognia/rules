# Reglas de análisis de clústeres Kubernetes

## Propósito

Este documento define las convenciones para analizar el estado de clústeres Kubernetes desplegados sobre *bare-metal* con Istio, Kiali, Prometheus y Grafana.

## Acceso a los clústeres

### Conexión SSH

- **Usuario**: generalmente `ubuntu` (puede variar)
- **Llaves SSH**: `kone` (infra propia) o `cad` (servidores de clientes)
- **Comando**: `ssh -i ~/.ssh/<llave> <usuario>@<ip>`

### Estructura de manifiestos en el servidor

Los manifiestos se organizan por *namespace*/proyecto en el `$HOME` del usuario:

```
/home/<usuario>/kubernetes-<namespace>/
├── services/
│   ├── base/                    # Recursos base (VirtualServices de Istio)
│   │   ├── virtualservice.yaml
│   │   └── gateway.yaml
│   └── overlays/
│       └── dev/                 # Overlay de desarrollo (Deployments, Services, ConfigMaps)
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── kustomization.yaml
```

### Herramientas del *stack*

- **Kubernetes**: kubeadm, containerd
- **Service mesh**: Istio (VirtualServices, Gateway, mTLS)
- **Observabilidad**: Kiali (malla), Prometheus (métricas), Grafana (dashboards)
- **GitOps**: ArgoCD (sincronización automática)
- **CI/CD**: Jenkins (pipelines de *build*)
- **Registro**: AWS ECR (imágenes Docker)

## Comandos de diagnóstico esenciales

### Estado general del clúster

```bash
kubectl get nodes -o wide
kubectl get pods -n <namespace> -o wide
kubectl get svc -n <namespace>
kubectl get vs -n <namespace>            # VirtualServices de Istio
kubectl get dr -n <namespace>            # DestinationRules de Istio
```

### Estado de un servicio específico

```bash
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --tail=50
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20
```

### Verificaciones de salud

```bash
# Health check vía Istio Gateway
curl -s http://<gateway_ip>/<prefijo>/actuator/health

# Verificar que ArgoCD tiene el servicio sincronizado
kubectl get app -n argocd | grep <servicio>
```

### Red e Istio

```bash
kubectl get gateway -n <namespace>
kubectl get virtualservice -n <namespace> -o yaml
istioctl analyze -n <namespace>
istioctl proxy-status
```

### Recursos y métricas

```bash
kubectl top nodes
kubectl top pods -n <namespace>
```

## Puertos y URLs comunes

- **Istio Gateway**: puerto 80/443 en la IP del *load balancer* (MetalLB)
- **Kiali**: puerto 20001 (LoadBalancer o NodePort 30871). También expone 9090 (métricas internas)
- **Prometheus**: puerto 9090 (NodePort 31570)
- **Grafana**: puerto 3000 (LoadBalancer o NodePort 32716)
- **Jenkins**: `http://<ip>:8080/jenkins`
- **ArgoCD**: `https://<ip>:30443` o `http://<ip>:30080`

### Cómo obtener las IPs y puertos reales

```bash
kubectl get svc -n istio-system | grep -iE 'kiali|prometheus|grafana'
```

## Convenciones de nombres

- *Namespace*: nombre del proyecto o ambiente (ej. `stab`, `produccion`, `qa`)
- Servicios: `<nombre-servicio>` (ej. `kabat-authorization-service`)
- Prefijos Istio: `/<prefijo>` sin slash final (ej. `/kabat-auth`)
- Manifiestos: directorio `kubernetes-<namespace>/`

---

*Elaborado por Rodrigo Álvarez (@incogniadev)*
