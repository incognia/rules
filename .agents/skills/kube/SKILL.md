---
name: kube
description: "Analyze Kubernetes cluster state via SSH. Usage: /kube <key> <user> <host_ip> <namespace>"
---

# Kubernetes cluster analysis

## Arguments

- **Key**: $0 (SSH key name in ~/.ssh/: incognia, faraday, kone, cad)
- **User**: $1 (SSH user, e.g. ubuntu, root, admin)
- **Host IP**: $2 (server IP address)
- **Namespace**: $3 (Kubernetes namespace to analyze)

## Instructions

1. **Read the full CoT**: Load and follow `cot/kube.md` from line 1 to end
2. **Read the rules**: Load `rulesets/KUBE.md` for conventions and commands
3. **Connect via SSH**: `ssh -i ~/.ssh/$0 $1@$2` — check `~/.ssh/config` for custom port
4. **Cluster health**:
   - `kubectl get nodes -o wide`
   - `kubectl top nodes` (skip if Metrics API unavailable)
5. **Namespace analysis** ($3):
   - `kubectl get pods -n $3 -o wide`
   - `kubectl get svc -n $3`
   - `kubectl get vs -n $3`
   - `kubectl get events -n $3 --sort-by='.lastTimestamp' | tail -20`
6. **Istio status**:
   - `kubectl get gateway -n $3`
   - `istioctl analyze -n $3` (if available)
   - `istioctl proxy-status`
7. **ArgoCD**:
   - `kubectl get app -n argocd | grep $3`
8. **Manifests on disk**:
   - `ls /home/$1/kubernetes-$3/services/overlays/dev/`
   - `ls /home/$1/kubernetes-$3/services/base/`
9. **Health checks**:
   - Get Gateway IP: `kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
   - Test endpoints via Gateway
10. **Observability**:
    - Kiali: port 20001
    - Prometheus: port 9090
    - Grafana: port 3000
11. **Report**: Summarize findings — nodes, problematic pods, services, VirtualServices, ArgoCD sync, recent events, observability

## Examples

- `/kube kone ubuntu 192.168.10.70 stab` — infra server, stab namespace
- `/kube kone ubuntu 30.30.40.90 sinaloa-qa` — client server via kone
- `/kube cad admin 10.0.1.50 produccion` — client server via cad

## References

- Detailed CoT: `cot/kube.md`
- Rules: `rulesets/KUBE.md`
