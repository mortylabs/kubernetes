# 🏠 Domoticz

> Lightweight home automation system running in k3s — monitoring and controlling
> lights, switches, sensors, and more via a simple web interface.

[![Domoticz](https://img.shields.io/badge/Domoticz-latest-blue)](https://www.domoticz.com/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 500M) |
| [`svc.yaml`](svc.yaml) | LoadBalancer service — LAN access only, no ingress |
| [`deployment.yaml`](deployment.yaml) | Domoticz with liveness/readiness probes and NFS-backed config |

---

## ✅ Prerequisites

**Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/k8sdata/domoticz
```

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl rollout status deploy/domoticz
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=domoticz

# External IP assigned by MetalLB?
kubectl get svc domoticz

# UI reachable? (LAN only)
# Navigate to http://<EXTERNAL-IP>:8080 in your browser
```

---

## 📝 Why Run Domoticz in Kubernetes?

Domoticz is typically installed as a bare-metal binary — it's lightweight and needs
no containers. Running it in k3s gives you:

- **Automatic restarts** via liveness/readiness probes
- **Persistent config** on NFS — survives pod restarts and node reboots
- **Consistent deployment** alongside the rest of the homelab stack

> LAN access only — Domoticz is not exposed via ingress or Cloudflare.
> Access via `http://<MetalLB-IP>:8080` from your local network.

---

## 📝 Notes

- Image: `demydiuk/domoticz` — a community ARM-compatible image
- Config and Lua scripts are stored on separate NFS subpaths (`config/` and `lua/`)
- NodePort removed from original — MetalLB LoadBalancer handles external IP assignment
- Deployment renamed from `domoticz-deployment` to `domoticz` for consistency with other apps
