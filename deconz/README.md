# 🔵 deCONZ

> Zigbee gateway controller for the [ConBee II](https://phoscon.de/en/conbee2) USB dongle —
> an excellent device compatible with most Zigbee vendors including Philips Hue,
> IKEA Tradfri, Aqara, Sonoff, and more.

[![deCONZ](https://img.shields.io/badge/deCONZ-latest-blue)](https://hub.docker.com/r/deconzcommunity/deconz)
[![Zigbee](https://img.shields.io/badge/protocol-Zigbee-green)](https://zigbeealliance.org/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 20M) |
| [`svc.yaml`](svc.yaml) | LoadBalancer service — ports 80 (HTTP) and 443 (HTTPS) |
| [`deployment.yaml`](deployment.yaml) | deCONZ with ConBee II USB device passthrough |

---

## ✅ Prerequisites

**1. Plug in the ConBee II USB dongle** and verify the device path on your Pi:
```bash
ls /dev/ttyACM*
# typically /dev/ttyACM0 or /dev/ttyACM1
```

If your device appears on `ttyACM0` instead of `ttyACM1`, update both references in `deployment.yaml`:
```yaml
- name: DECONZ_DEVICE
  value: /dev/ttyACM0
```
and:
```yaml
- name: dev-ttyacm1
  hostPath:
    path: /dev/ttyACM0
```

**2. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/deconz
```

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl rollout status deploy/deconz
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=deconz

# External IP assigned by MetalLB?
kubectl get svc deconz

# deCONZ UI reachable?
# Navigate to http://<EXTERNAL-IP> in your browser
```

---

## 🏠 Home Assistant Integration

Home Assistant will **auto-discover** the deCONZ gateway on your network and prompt
you to integrate it automatically via the Integrations page. No manual configuration needed.

---

## 📝 Notes

- `hostNetwork: true` — required for Home Assistant auto-discovery to work across the LAN
- `privileged: true` — required for USB device passthrough to the ConBee II dongle
- Port `5900` — VNC access to the deCONZ visual network map (optional, LAN only)
- Typo fixed in original `svc.yaml` — port name was `ssh` (443), corrected to `https`
- Volume name normalised from `dev-ama1` to `dev-ttyacm1` for clarity

![image](https://user-images.githubusercontent.com/31904545/157637215-16745bfe-9c43-4d0c-a529-3bc51830b1cf.png)
