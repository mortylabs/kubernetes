# MortyLabs Kubernetes K3s Homelab

> A lightweight K3s-based Kubernetes cluster, currently running version **`v1.31.6+k3s1`** as of **14 March 2025**, which is tailored for my personal homelab that hosts `Home Assistant`, `InfluxDB`, `Grafana`, `MQTT`, `UniFi Controller`, `MongoDB`, `Wordpress`, and more.

[![K3s](https://img.shields.io/badge/K3s-v1.31.6--k3s1-blue.svg)]()
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)]()

## 🤔Why This Repo Exists

To better understand Kubernetes concepts, I wrote all deployment `.yaml` files myself from scratch, instead of relying solely on third-party Helm charts, for a simple stack:

- fully orchestrated Kubernetes stack built for **Raspberry Pi**
- Ideal for self-hosted services: Home Assistant, databases, dashboards, network management, etc.
- Modular and portable—spin up the same stack at home, office, or remote sites

---
## 🚀 **Cluster Overview**

- **Kubernetes Distribution:** [Rancher K3s](https://k3s.io/)
- **Load Balancer:** [MetalLB](https://metallb.universe.tf/)
- **Ingress/Reverse Proxy:** [NGINX](https://kubernetes.github.io/ingress-nginx/) (replacing the default Traefik ingress controller)
- **Nodes:** Raspberry Pi 4 Model B (ARM64, 8GB RAM)
- **Operating System:** Raspbian Bullseye 64-bit
- **Storage and Backups:**
  - Persistent storage via dedicated Raspberry Pi NFS server (SSD-based, 500GB)
  - Automatic backups to [Google Drive](https://drive.google.com/) and [GitHub](https://github.com)

Feel free to explore, reuse, or adapt this repo for your own Kubernetes learning journey!

---

# installation - k3s

In file /boot/cmdline.txt add the following to the end of the file:
```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

Then to install k3s with the default load balancer disabled:
```
curl -sfL https://get.k3s.io | sh -s -  --disable=traefik --disable servicelb --write-kubeconfig-mode 644
```

# installation - NFS for persistent storage

Follow this tutorial to configure your pi as a NFS:
https://pimylifeup.com/raspberry-pi-nfs/

Then to setup the nfs-client-provisioner in k3s:
```
cd pv_nfs
kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
```

# installation - NGINX Ingress
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
```

# installation - MetalLB Load Balancer
```
cd metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
vi config.yaml  #edit and set the IP address range that has been reserved on your DCHP server
kubectl apply -f config.yaml
```

# installation - enable https ingress using cert-manager & letsencrypt

Below will install cert-manager **v1.17.0**, which is the latest version as of **14th March 2025.**
```
cd ingress
kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
vi letsencrypt.yaml #update the email address!
kubectl apply -f letsencrypt.yaml
```

Remeber to open ports 80 and 443 on your firewall / router, and redirect traffic to the master node ingress ip from metallb load balancer. In this example it would be 192.168.1.110. So direct port traffic from both 80 and 443 to 192.168.1.110 respectively.

# installation - applications

for each app, deploy **pv.yaml** to create the persistent volume and then **deployment.yaml**. Remember to edit pv.yaml and enter your NFS IP address and folder. That's it :) 
