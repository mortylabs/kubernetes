# 📡 MQTT Broker

> Mosquitto MQTT broker — the messaging backbone of the Morty Labs stack.
> Home Assistant, govee2mqtt, mqtt2influx, and all IoT sensors connect through here.

[![Mosquitto](https://img.shields.io/badge/Mosquitto-latest-purple)](https://mosquitto.org/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 20M) |
| [`configmap.yaml`](configmap.yaml) | Mosquitto config + password file |
| [`svc.yaml`](svc.yaml) | NodePort service — port `1883` / NodePort `31883` |
| [`deployment.yaml`](deployment.yaml) | Mosquitto broker with auth enabled |

---

## ✅ Prerequisites

> Install k3s and MetalLB first — see the [root README](../README.md#installation-guide).

**1. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/mqtt
```

**2. Generate a password hash** and update `configmap.yaml`:

If the broker is already running, generate the hash directly in the pod:
```bash
kubectl exec -it deployment/mqtt -- sh
cd mosquitto/config/
mosquitto_passwd -c mosquitto.passwd mqtt_user
cat mosquitto.passwd
# Copy the hash and paste into configmap.yaml, then reapply
exit
```

If deploying from scratch, use a temporary container:
```bash
docker run -it eclipse-mosquitto /bin/sh
mosquitto_passwd -c /tmp/mosquitto.passwd mqtt_user
cat /tmp/mosquitto.passwd
```

Then paste the generated hash into `configmap.yaml` and apply:
```bash
kubectl apply -f configmap.yaml
kubectl rollout restart deploy/mqtt
```

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f svc.yaml
kubectl rollout status deploy/mqtt
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=mqtt

# Service and NodePort assigned?
kubectl get svc mqtt

# Test connection from LAN (requires mosquitto-clients)
mosquitto_sub -h 192.168.1.15 -p 31883 -u mqtt_user -P YOUR_PASSWORD -t '#' -v
```

---

## 📝 Notes

- `allow_anonymous false` — authentication required, no unauthenticated connections
- `runAsUser: 1883` — Mosquitto runs as its own non-root user for security
- `defaultMode: 0600` — password file is readable only by the Mosquitto process
- NodePort `31883` exposes MQTT on the LAN — update [`mqtt2influx`](../mqtt2influx/) and [`govee2mqtt`](../govee2mqtt/) configs to match your port
- Persistence enabled — messages and state survive pod restarts via NFS
- Deployment renamed from `mqtt-deployment` to `mqtt` for consistency
