# Reglas de análisis de clústeres Kubernetes

## Propósito

Este documento define las convenciones para analizar el estado de clústeres Kubernetes desplegados sobre *bare-metal* con Istio, Kiali, Prometheus y Grafana.

## Acceso a los clústeres

### Conexión SSH

- **Usuario**: generalmente `ubuntu` (puede variar)
- **Llaves SSH**: las de servidores, no las de repositorios: `faraday` (servidores personales) o `cad` (servidores laborales y de clientes); en algunos servidores laborales anteriores a esta separación sigue instalada `kone`
- **Comando**: `ssh -i ~/.ssh/<llave> <usuario>@<ip>`

### Estructura de manifiestos en el servidor

Los manifiestos se organizan por *namespace*/proyecto en el `$HOME` del usuario:

```text
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
- ***Service mesh***: Istio (VirtualServices, Gateway, mTLS)
- **Observabilidad**: Kiali (malla), Prometheus (métricas), Grafana (*dashboards*)
- **GitOps**: Argo CD (sincronización automática)
- **CI/CD**: Jenkins (*pipelines* de *build*)
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
# Health check through the Istio gateway
curl -s http://<gateway_ip>/<prefijo>/actuator/health

# Check that Argo CD has the service in sync
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

## Puertos y URL comunes

- **Istio Gateway**: puerto 80/443 en la IP del *load balancer* (MetalLB)
- **Kiali**: puerto 20001 (LoadBalancer o NodePort). También expone 9090 (métricas internas)
- **Prometheus**: puerto 9090 (NodePort)
- **Grafana**: puerto 3000 (LoadBalancer o NodePort)
- **Jenkins**: `http://<ip>:8080/jenkins`
- **Argo CD**: por NodePort, con HTTPS o HTTP

Los NodePort reales cambian por clúster y no se escriben aquí: se consultan con el comando de abajo.

### Cómo obtener las IP y los puertos reales

```bash
kubectl get svc -n istio-system | grep -iE 'kiali|prometheus|grafana'
```

## Convenciones de nombres

- *Namespace*: nombre del proyecto o ambiente (por ejemplo, `produccion`, `qa`)
- Servicios: `<nombre-servicio>` (por ejemplo, `<empresa>-authorization-service`)
- Prefijos Istio: `/<prefijo>` sin diagonal final (por ejemplo, `/<empresa>-auth`)
- Manifiestos: carpeta `kubernetes-<namespace>/`

---

*Elaborado por Rodrigo Álvarez (@incogniadev)*
