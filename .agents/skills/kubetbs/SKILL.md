---
name: kubetbs
description: "Troubleshoot a problematic microservice in Kubernetes by correlating events, logs and pods across namespaces. Usage: /kubetbs <key> <user> <host_ip> <namespace> <service>"
---

# Kubernetes troubleshooting

## Arguments

- **Key**: $0 (SSH key: incognia, faraday, kone, cad)
- **User**: $1 (SSH user, e.g. ubuntu)
- **Host IP**: $2 (server IP)
- **Namespace**: $3 (namespace where the problem is)
- **Service**: $4 (problematic service name, optional — if omitted, detect automatically)

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/kubetbs.md` from line 1 to end
2. **Read the rules**: Load `~/rules/rulesets/KUBETBS.md` for methodology and common errors
3. **Connect via SSH**: `ssh -i ~/.ssh/$0 $1@$2` — check `~/.ssh/config` for custom port
4. **Events**: `kubectl get events -n $3 --sort-by=.lastTimestamp | tail -30`
5. **Pods with restarts**: `kubectl get pods -n $3 --sort-by=.status.containerStatuses[0].restartCount | tail -20`
6. **If $4 was provided**, focus on that service. Otherwise, pick the pod with most restarts.
7. **Describe pod**: `kubectl describe pod -n $3 <pod>` — identify owner and error
8. **Logs by label**: `kubectl logs -n $3 -l app=$4 --since=60m --tail=500`
9. **Check Service/Endpoints**: `kubectl get svc,ep -n $3 | grep -E "$4|<dependency>"`
10. **Cross-namespace search**: `kubectl get svc -A | grep -i <dependency>` if dependency not found locally
11. **DNS verification**: `kubectl -n $3 run tmp --rm -it --image=busybox --restart=Never -- nslookup <dependency>.<namespace>.svc.cluster.local`
12. **Propose fix**: describe correction WITHOUT deploying. Validate with temporary pod first.

## Critical rule

**Never deploy a fix without validating the hypothesis first.** Use temporary busybox pod for DNS and connectivity checks.

## Examples

- `/kubetbs kone ubuntu 30.30.40.90 sinaloa-qa ms-macroevento` — troubleshoot specific service
- `/kubetbs kone ubuntu 30.30.40.90 michoacan-qa` — auto-detect problematic service
- `/kubetbs cad ubuntu 10.0.1.50 produccion payments-api` — client server

## References

- Detailed CoT: `~/rules/cot/kubetbs.md`
- Rules: `~/rules/rulesets/KUBETBS.md`
- Cluster analysis: `/kube` skill for general health first
