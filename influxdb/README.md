# InfluxDB

Time-series database used to store all homelab metrics — sensor readings, MQTT telemetry,
EPever solar data, and Home Assistant history.

## Files

| File | Description |
|---|---|
| `pv.yaml` | PersistentVolume and PersistentVolumeClaim (NFS-backed, 50M) |
| `secrets.yaml` | Admin credentials — **never commit real values, add to `.gitignore`** |
| `svc.yaml` | LoadBalancer service — MetalLB assigns the external IP |
| `deployment.yaml` | InfluxDB 1.8 deployment with HTTP auth enabled |

## Prerequisites

Create the secret before deploying (or apply `secrets.yaml` with real values):
```bash
kubectl create secret generic influxdb-auth \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='YOUR_STRONG_PASSWORD'
```

Edit `pv.yaml` and set:
- `spec.nfs.server` — IP of your NFS server
- `spec.nfs.path` — export path on the NFS server

## Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f secrets.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl rollout status deploy/influxdb
```

## Verify
```bash
# Check pod is running
kubectl get pods -l app=influxdb

# Check external IP assigned by MetalLB
kubectl get svc influxdb

# Confirm auth is enforced (expect 401)
curl http://<EXTERNAL-IP>:8086/query?q=SHOW+DATABASES

# Confirm auth works
curl -u admin:YOUR_STRONG_PASSWORD \
  http://<EXTERNAL-IP>:8086/query?q=SHOW+DATABASES
```

## Notes

- Image pinned to `arm32v7/influxdb:1.8` — runs on 64-bit Pi OS via 32-bit ARM userspace
- `imagePullPolicy: IfNotPresent` — avoids unnecessary pulls on pod restarts
- `persistentVolumeReclaimPolicy: Retain` — data survives pod deletion
- Port `8086` is the InfluxDB HTTP API — not exposed via ingress, LAN-only
