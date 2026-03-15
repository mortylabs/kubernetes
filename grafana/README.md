# 📈 Grafana

> Dashboards for the Morty Labs metrics stack — visualising InfluxDB time-series data
> from Home Assistant, MQTT sensors, EPever solar, and more.

[![Grafana](https://img.shields.io/badge/Grafana-11.4.0-orange?logo=grafana)](https://grafana.com/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 50M) |
| [`secrets.yaml`](secrets.yaml) | Admin credentials — ⚠️ never commit real values |
| [`svc.yaml`](svc.yaml) | LoadBalancer service — MetalLB assigns the external IP |
| [`deployment.yaml`](deployment.yaml) | Grafana 11.4.0 with admin auth and subdomain config |
| [`ingress.yaml`](ingress.yaml) | Ingress rule — `grafana.mortylabs.com` with TLS via cert-manager |

---

## ✅ Prerequisites

**1. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/grafana
```

**2. Edit `secrets.yaml`** — set real credentials and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f secrets.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
kubectl rollout status deploy/grafana
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=grafana

# External IP assigned by MetalLB?
kubectl get svc grafana

# TLS certificate issued?
kubectl get certificate

# UI reachable?
curl -I https://grafana.mortylabs.com
# expect: 302 redirect to /login
```

---

## 📝 Notes

- Image pinned to `grafana/grafana:11.4.0` — update tag deliberately, not via `latest`
- Admin credentials injected via Kubernetes Secret — not hardcoded in the manifest
- `GF_SECURITY_ALLOW_EMBEDDING=true` — required for Grafana panels embedded in Home Assistant
- Plugin `grafana-simple-json-datasource` auto-installed on first start
- NodePort service removed — ingress-nginx via MetalLB handles all external routing
