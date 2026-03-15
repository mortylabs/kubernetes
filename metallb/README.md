# ⚖️ MetalLB

> Bare-metal load balancer for k3s — assigns external IPs to LoadBalancer
> services from a reserved pool on your LAN.

[![MetalLB](https://img.shields.io/badge/MetalLB-v0.15.3-blue)](https://metallb.universe.tf/)

---

## 📁 Files

| File | Description |
|---|---|
| [`config.yaml`](config.yaml) | IP address pool + L2 advertisement config |

---

## ✅ Prerequisites

> Install k3s first — see the [root README](../README.md#installation-guide).

Reserve a static IP range on your router's DHCP server — these IPs must be
**excluded from the DHCP pool** so your router never assigns them to other devices.

---

## 🚀 Deploy
```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml

# Wait for pods to be ready
kubectl -n metallb-system wait --for=condition=Ready pod --all --timeout=120s

# Edit config.yaml — set your reserved IP range
vi config.yaml

# Apply the pool config
kubectl apply -f config.yaml
```

---

## 🔍 Verify
```bash
# Pods running?
kubectl get pods -n metallb-system

# Pool configured?
kubectl get ipaddresspool -n metallb-system

# IP assigned to a service?
kubectl get svc -A | grep LoadBalancer
```

---

## 📝 Notes

- IP range `192.168.1.100-192.168.1.109` — 10 IPs, adjust to match your network
- `L2Advertisement` — uses ARP to advertise IPs on the LAN, no BGP needed
- MetalLB replaces the default k3s `servicelb` — ensure k3s was installed with `--disable=servicelb`
- One IP is consumed per LoadBalancer service — 10 IPs covers the full homelab stack comfortably
