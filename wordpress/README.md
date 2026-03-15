# 📝 WordPress

> WordPress + MariaDB stack running in k3s — previously used to serve
> `mortylabs.com` and `andrewmorty.com`. No longer actively deployed but
> retained as a reference for running WordPress on Kubernetes.

[![WordPress](https://img.shields.io/badge/WordPress-latest-blue?logo=wordpress)](https://wordpress.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-latest-blue)](https://mariadb.org/)
[![NFS](https://img.shields.io/badge/storage-NFS-blue)](../pv_nfs/)

> ⚠️ **Not currently deployed** — retained as a reference implementation.
> The Morty Labs website has since migrated to a Hugo static site on k3s.

---

## 📁 Files

| File | Description |
|---|---|
| [`pv_mariadb.yaml`](pv_mariadb.yaml) | PersistentVolume + PVC for MariaDB (NFS-backed, 500M) |
| [`pv_wordpress.yaml`](pv_wordpress.yaml) | PersistentVolume + PVC for WordPress (NFS-backed, 300M) |
| [`secrets.yaml`](secrets.yaml) | MariaDB root password — ⚠️ never commit real values |
| [`svc_maria.yaml`](svc_maria.yaml) | ClusterIP service for MariaDB (internal only) |
| [`svc_wordpress.yaml`](svc_wordpress.yaml) | ClusterIP service for WordPress frontend |
| [`deployment_maria.yaml`](deployment_maria.yaml) | MariaDB deployment with resource limits |
| [`deployment_wordpress.yaml`](deployment_wordpress.yaml) | WordPress deployment with liveness/readiness probes |
| [`ingress.yaml`](ingress.yaml) | Ingress — multi-domain TLS via cert-manager |

---

## ✅ Prerequisites

> Install k3s, MetalLB, ingress-nginx, and NFS provisioner first — see the [root README](../README.md#installation-guide).

**1. Create the namespace:**
```bash
kubectl create namespace wordpress
```

**2. Edit `pv_mariadb.yaml` and `pv_wordpress.yaml`** — set your NFS server IP and paths.

**3. Edit `secrets.yaml`** — set a strong password and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

**4. Edit `ingress.yaml`** — replace `mortylabs.com` and `andrewmorty.com` with your domains.

---

## 🚀 Deploy
```bash
kubectl create namespace wordpress
kubectl apply -f pv_mariadb.yaml
kubectl apply -f pv_wordpress.yaml
kubectl apply -f secrets.yaml
kubectl apply -f svc_maria.yaml
kubectl apply -f svc_wordpress.yaml
kubectl apply -f deployment_maria.yaml
kubectl apply -f deployment_wordpress.yaml
kubectl apply -f ingress.yaml

kubectl rollout status deploy/wordpress-mariadb -n wordpress
kubectl rollout status deploy/wordpress -n wordpress
```

---

## 🔍 Verify
```bash
# Pods running?
kubectl get pods -n wordpress

# Services up?
kubectl get svc -n wordpress

# TLS certificate issued?
kubectl get certificate -n wordpress

# Site reachable?
curl -I https://mortylabs.com
```

---

## 📝 Notes

- WordPress and MariaDB run in a dedicated `wordpress` namespace
- MariaDB is ClusterIP only — not exposed outside the cluster
- Resource limits set on both deployments — important on a Pi 4 with limited RAM
- Liveness/readiness probes on `/wp-login.php` — gives WordPress time to start (60s delay)
- `strategy: Recreate` on both deployments — avoids two instances trying to write to the same NFS volume simultaneously
- `restartPolicy` removed from both Deployments — only valid on bare Pods
