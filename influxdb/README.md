# 📊 InfluxDB

> Time-series database powering the Morty Labs metrics stack — storing sensor readings,
> MQTT telemetry, EPever solar data, and Home Assistant history.

[![InfluxDB](https://img.shields.io/badge/InfluxDB-1.8-orange?logo=influxdb)](https://www.influxdata.com/)
[![ARM](https://img.shields.io/badge/arch-arm32v7-lightgrey)](https://hub.docker.com/r/arm32v7/influxdb)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 50M) |
| [`secrets.yaml`](secrets.yaml) | Admin credentials — ⚠️ never commit real values |
| [`svc.yaml`](svc.yaml) | LoadBalancer service — MetalLB assigns the external IP |
| [`deployment.yaml`](deployment.yaml) | InfluxDB 1.8 with HTTP auth enabled |

---

## ✅ Prerequisites

**1. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15   # ← your NFS server
  path: /home/pi/nfs/k8sdata/influxdb
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
kubectl rollout status deploy/influxdb
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=influxdb

# External IP assigned by MetalLB?
kubectl get svc influxdb

# Auth enforced? (expect 401)
curl http://<EXTERNAL-IP>:8086/query?q=SHOW+DATABASES

# Auth working? (expect database list)
curl -u admin:YOUR_PASSWORD \
  http://<EXTERNAL-IP>:8086/query?q=SHOW+DATABASES
```

---

## 📝 Notes

- Image pinned to `arm32v7/influxdb:1.8` — runs on 64-bit Pi OS via 32-bit ARM userspace
- `imagePullPolicy: IfNotPresent` — no unnecessary pulls on pod restarts
- `persistentVolumeReclaimPolicy: Retain` — data survives pod deletion
- Port `8086` is LAN-only — not exposed via ingress
