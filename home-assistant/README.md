# 🏡 Home Assistant

> The core of the Morty Labs smart home — automating lights, sensors, cameras,
> solar monitoring, and more. Exposed externally via Cloudflare + ingress-nginx
> with WebSocket support for the mobile app.

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-stable-41BDF5?logo=home-assistant)](https://www.home-assistant.io/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 150M) |
| [`svc.yaml`](svc.yaml) | LoadBalancer + NodePort services |
| [`deployment.yaml`](deployment.yaml) | Home Assistant with USB passthrough, music volume, and MQTT init check |
| [`ingress.yaml`](ingress.yaml) | Ingress — `ha.mortylabs.com` with TLS and WebSocket support |

---

## ✅ Prerequisites

**1. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/home-assistant
```

**2. Edit `deployment.yaml`** — set your music path if different:
```yaml
- name: music-volume
  hostPath:
    path: /home/pi/Music
```

**3. Verify USB device paths** on the Pi before deploying:
```bash
ls /dev/ttyACM*   # USB serial (RFLink, ConBee II, Z-Wave stick, etc.)
ls /dev/ttyAMA*   # UART serial
```

Update `deployment.yaml` if your devices appear on different paths.

**4. MQTT broker must be running** — the `wait-for-mqtt` init container blocks
startup until MQTT is reachable on port `1883`. Deploy
[`mqtt_broker`](../mqtt_broker/) first.

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
kubectl rollout status deploy/home-assistant
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=home-assistant

# Both services up?
kubectl get svc -l app=home-assistant

# TLS certificate issued?
kubectl get certificate

# External access via Cloudflare
curl -I https://ha.mortylabs.com
# expect: 200 OK

# Direct LAN access via NodePort (fallback)
curl -I http://<NODE-IP>:31123
# expect: 200 OK
```

---

## 🌐 Access

| Method | URL | Use case |
|---|---|---|
| External | `https://ha.mortylabs.com` | Normal access via Cloudflare + ingress |
| LAN LoadBalancer | `http://<MetalLB-IP>:80` | Local network access |
| LAN NodePort | `http://<NODE-IP>:31123` | Fallback when ingress is unavailable |

---

## 📝 Notes

- `hostNetwork: true` — required for device auto-discovery (mDNS, Zigbee, etc.)
- `privileged: true` — required for USB device passthrough
- `wait-for-mqtt` init container — prevents HA starting before MQTT is ready
- `imagePullPolicy: Always` — picks up monthly HA stable releases automatically
- WebSocket annotations on ingress — required for the HA mobile app and live UI updates
- Two services deployed — LoadBalancer for Cloudflare ingress, NodePort (`31123`) for direct LAN fallback
- Liveness probe uses generous timeouts (`initialDelaySeconds: 60`) — HA is slow to start on Pi
- Music directory mounted at `/config/www/media` — accessible via the HA media browser
- `ha.mortylabs.com` is proxied via Cloudflare — ensure the WAF rule scopes away from this subdomain to avoid blocking the HA mobile app
