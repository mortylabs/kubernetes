# 🏠 Morty Labs — K3s Homelab

> A lightweight K3s-based Kubernetes cluster, currently running version **`v1.34.4+k3s1`** as of **25th February 2026**, tailored for a personal homelab hosting `Home Assistant`, `InfluxDB`, `Grafana`, `MQTT`, `UniFi Controller`, `Pi-hole`, `deCONZ`, and more.

[![K3s](https://img.shields.io/badge/K3s-v1.34.4%2Bk3s1-blue?logo=kubernetes)](https://k3s.io/)
[![cert-manager](https://img.shields.io/badge/cert--manager-v1.19.4-green?logo=letsencrypt)](https://cert-manager.io/)
[![MetalLB](https://img.shields.io/badge/MetalLB-v0.15.3-blue)](https://metallb.universe.tf/)
[![ingress-nginx](https://img.shields.io/badge/ingress--nginx-v1.12.0-brightgreen?logo=nginx)](https://kubernetes.github.io/ingress-nginx/)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-orange)](LICENSE)
[![Stars](https://img.shields.io/github/stars/mortylabs/kubernetes?style=social)](https://github.com/mortylabs/kubernetes/stargazers)
[![CI](https://github.com/mortylabs/kubernetes/actions/workflows/lint.yaml/badge.svg)](https://github.com/mortylabs/kubernetes/actions/workflows/lint.yaml)

![Raspberry Pi](https://img.shields.io/badge/hardware-Raspberry%20Pi%204-red?logo=raspberry-pi)
![ARM64](https://img.shields.io/badge/arch-ARM64-lightgrey)
![Cloudflare](https://img.shields.io/badge/DNS-Cloudflare-orange?logo=cloudflare)

---

## 🤔 Why This Repo Exists

To better understand Kubernetes concepts, I wrote all deployment `.yaml` files myself from scratch, instead of relying on third-party Helm charts:

- Fully orchestrated Kubernetes stack built for **Raspberry Pi**
- Ideal for self-hosted services: Home Assistant, databases, dashboards, network management, and more
- Modular and portable — spin up the same stack at home or at a remote site
- Secure by default — TLS everywhere, Cloudflare WAF in front, fail2ban on the nodes

---

## 👤 Who Is This For?

- Raspberry Pi enthusiasts wanting to run a production-grade homelab or website
- Home Assistant users who want persistent storage, TLS, and proper ingress
- Anyone learning Kubernetes who wants real working manifests, not toy examples
- DevOps engineers setting up a low-cost remote monitoring stack

---

## 🎯 What You'll End Up With

A fully working homelab cluster with:

- 🏡 Home Assistant accessible at `https://ha.yourdomain.com`
- 📊 Grafana dashboards at `https://grafana.yourdomain.com`
- 🔒 Automatic TLS certificates via Let's Encrypt
- 📡 MQTT broker for all your IoT sensors
- 🕳️ Network-wide ad blocking via Pi-hole
- ☁️ Automatic DNS updates when your home IP changes
- 💾 All data persisted on NFS — survives pod restarts and reboots

---

## 🚀 Cluster Overview

- **Kubernetes Distribution:** [Rancher K3s](https://k3s.io/)
- **Load Balancer:** [MetalLB](https://metallb.universe.tf/) v0.15.3
- **Ingress/Reverse Proxy:** [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) v1.12.0 (replacing the default Traefik)
- **TLS:** [cert-manager](https://cert-manager.io/) v1.19.4 + Let's Encrypt
- **DNS/CDN:** [Cloudflare](https://cloudflare.com) (proxy + WAF + DDNS)
- **Nodes:** Raspberry Pi 4 Model B — ARM64, 8GB RAM
- **Operating System:** Raspberry Pi OS (Bookworm) 64-bit
- **Storage:** Dedicated Raspberry Pi NFS server (SSD-based, 500GB)
- **Backups:** Automatic backups to Google Drive and GitHub

Feel free to explore, reuse, or adapt this repo for your own Kubernetes learning journey!

---

## 📦 Deployed Services

- [`home-assistant`](home-assistant/) — Core home automation hub
- [`influxdb`](influxdb/) — Time-series metrics storage
- [`grafana`](grafana/) — Metrics dashboards
- [`mqtt_broker`](mqtt_broker/) — Mosquitto MQTT broker
- [`mqtt2influx`](mqtt2influx/) — MQTT → InfluxDB bridge
- [`govee2mqtt`](govee2mqtt/) — Govee BLE lights → MQTT
- [`deconz`](deconz/) — Zigbee gateway (ConBee II)
- [`pihole`](pihole/) — Network-wide ad/DNS blocking
- [`unifi`](unifi/) — Ubiquiti UniFi Controller
- [`cloudflare-dns`](cloudflare-dns/) — Cloudflare DDNS CronJob
- [`ingress`](ingress/) — ingress-nginx + cert-manager ClusterIssuer
- [`metallb`](metallb/) — Bare-metal load balancer config
- [`pv_nfs`](pv_nfs/) — NFS persistent volume provisioner
- [`wordpress`](wordpress/) — WordPress + MariaDB

---

## 🛠 Installation — k3s

Edit `/boot/firmware/cmdline.txt` (Bookworm) or `/boot/cmdline.txt` (Bullseye) and append to the **single existing line**:
```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

Then install k3s with Traefik and the built-in service LB disabled:
```
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --disable=servicelb --write-kubeconfig-mode 644
```

---

## 🛠 Installation — NFS Persistent Storage

Follow this tutorial to configure your Pi as an NFS server:
https://pimylifeup.com/raspberry-pi-nfs/

Then deploy the NFS provisioner in k3s:
```
cd pv_nfs
kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
```

---

## 🛠 Installation — NGINX Ingress
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
```

---

## 🛠 Installation — MetalLB Load Balancer
```
cd metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
vi config.yaml  # edit and set the IP address range reserved on your DHCP server
kubectl apply -f config.yaml
```

---

## 🛠 Installation — HTTPS Ingress via cert-manager & Let's Encrypt

Below will install cert-manager **v1.19.4**, which is the latest version as of **25th February 2026**.
```
cd ingress
kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.4/cert-manager.yaml
vi letsencrypt.yaml  # update your email address
kubectl apply -f letsencrypt.yaml
```

Remember to open ports 80 and 443 on your router and forward traffic to the MetalLB ingress IP.

---

## 🛠 Installation — Applications

For each app, edit `pv.yaml` to set your NFS server IP and path, edit `secrets.yaml` to set credentials, then:
```
kubectl apply -f pv.yaml
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f svc.yaml
kubectl apply -f ingress.yaml  # if applicable
```

See each app's `README.md` for specific instructions.

---

## 🔐 Secrets Management

Each app has a `secrets.yaml` file excluded from git via `.gitignore`. Never commit real credentials. See each app folder for the specific secrets required.

---

## ☁️ Cloudflare DNS

All services are exposed via Cloudflare-proxied subdomains. DNS records are kept in sync automatically via the [`cloudflare-dns`](cloudflare-dns/) CronJob which runs every 20 minutes.

---

## ⬆️ Upgrading k3s
```
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --disable=servicelb --write-kubeconfig-mode 644
kubectl get nodes
```

Always check the [k3s release notes](https://github.com/k3s-io/k3s/releases) before upgrading.

---

Built with ☕ and mild obsession 🏴󠁧󠁢󠁳󠁣󠁴󠁿
