# 📡 UniFi Controller

> Ubiquiti UniFi Network Controller — managing all Morty Labs WiFi access points
> and network infrastructure. Deployed on both UK and SA sites from the same manifests.

[![UniFi](https://img.shields.io/badge/UniFi-latest-blue)](https://github.com/linuxserver/docker-unifi-network-application)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 350M) |
| [`svc.yaml`](svc.yaml) | Two LoadBalancer services sharing one IP (TCP + UDP) |
| [`deployment.yaml`](deployment.yaml) | UniFi controller with host networking |
| [`ingress.yaml`](ingress.yaml) | Ingress — `unifi.mortylabs.com` with TLS via cert-manager |

---

## ✅ Prerequisites

> Install k3s and MetalLB first — see the [root README](../README.md#installation-guide).

**Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/unifi
```

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
kubectl rollout status deploy/unifi
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=unifi

# Both services share the same external IP?
kubectl get svc -l app=unifi

# TLS certificate issued?
kubectl get certificate

# UI reachable?
curl -Ik https://unifi.mortylabs.com
# expect: 200 OK
```

---

## 📝 Notes

- `hostNetwork: true` — required for UniFi device discovery (L2 broadcast)
- `dnsPolicy: ClusterFirstWithHostNet` — required when using hostNetwork
- Two services required — Kubernetes cannot mix TCP and UDP in a single LoadBalancer service
- `metallb.universe.tf/allow-shared-ip: uckey` — both services share the same MetalLB IP
- `nginx.ingress.kubernetes.io/backend-protocol: HTTPS` — UniFi controller uses HTTPS internally
- Image updated from `unifi-controller` to `unifi-network-application` — the old image was deprecated by LinuxServer.io
- Port names cleaned up — `unknown2`/`unknown3` renamed to `l2-redirect`/`hotspot-redirect`
- Same manifests used for both UK and SA sites — only the NFS path differs in `pv.yaml`
- `restartPolicy` removed from Deployment spec — only valid on bare Pods
