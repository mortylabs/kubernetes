# 🕳️ Pi-hole

> Network-wide ad and DNS blocking for the Morty Labs homelab.
> Runs as a DNS server on the LAN — point your router's DHCP DNS at the
> MetalLB IP to block ads on every device without any client configuration.

[![Pi-hole](https://img.shields.io/badge/Pi--hole-latest-red)](https://pi-hole.net/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

---

## 📁 Files

| File | Description |
|---|---|
| [`pv.yaml`](pv.yaml) | PersistentVolume + PersistentVolumeClaim (NFS-backed, 300M) |
| [`secrets.yaml`](secrets.yaml) | Admin web UI password — ⚠️ never commit real values |
| [`svc.yaml`](svc.yaml) | Two LoadBalancer services sharing one IP (TCP + UDP for DNS) |
| [`deployment.yaml`](deployment.yaml) | Pi-hole deployment |
| [`ingress.yaml`](ingress.yaml) | Ingress — `pihole.mortylabs.com` with TLS via cert-manager |

---

## ✅ Prerequisites

> Install k3s and MetalLB first — see the [root README](../README.md#installation-guide).

**1. Edit `pv.yaml`** — set your NFS server IP and export path:
```yaml
nfs:
  server: 192.168.1.15
  path: /home/pi/nfs/k8sdata/pihole
```

**2. Edit `secrets.yaml`** — set real credentials and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

**3. Reserve a static IP** for Pi-hole in your MetalLB pool — Pi-hole works best
with a predictable IP since you'll point your router's DNS at it. Uncomment and
set `loadBalancerIP` in `svc.yaml` if needed.

---

## 🚀 Deploy
```bash
kubectl apply -f pv.yaml
kubectl apply -f secrets.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
kubectl rollout status deploy/pihole
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=pihole

# Both services share the same external IP?
kubectl get svc -l app=pihole

# DNS working?
nslookup google.com <EXTERNAL-IP>

# Admin UI reachable?
curl -I https://pihole.mortylabs.com
```

---

## 🌐 Router Configuration

Point your router's primary DNS to the Pi-hole MetalLB IP to enable
network-wide blocking on all devices:
```
Primary DNS:   <Pi-hole MetalLB IP>
Secondary DNS: 8.8.8.8  (fallback if Pi-hole is unavailable)
```

---

## 📝 Notes

- Two services required — Kubernetes cannot mix TCP and UDP in a single LoadBalancer service
- `metallb.universe.tf/allow-shared-ip: "pihole"` — ensures both services share the same IP
- `externalTrafficPolicy: Local` — preserves client IPs in Pi-hole query logs
- Bug fixed — original `app.yaml` referenced `mariadb-pass` secret instead of `pihole-pass`
- `app.yaml` split into `deployment.yaml` and `secrets.yaml` for consistency
