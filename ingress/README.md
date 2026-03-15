# 🔐 Ingress + TLS

> NGINX ingress controller with automatic TLS certificate provisioning via
> cert-manager and Let's Encrypt. All external services route through here.

[![cert-manager](https://img.shields.io/badge/cert--manager-v1.19.4-green)](https://cert-manager.io/)
[![Let's Encrypt](https://img.shields.io/badge/TLS-Let's%20Encrypt-blue)](https://letsencrypt.org/)

---

## 📁 Files

| File | Description |
|---|---|
| [`letsencrypt.yaml`](letsencrypt.yaml) | `ClusterIssuer` — Let's Encrypt ACME HTTP-01 solver via NGINX |

---

## 🚀 Deploy

> Install ingress-nginx and cert-manager first — see the [root README](../README.md#installation-guide) for instructions.
```bash
# Edit letsencrypt.yaml — set your email address first
vi letsencrypt.yaml
kubectl apply -f letsencrypt.yaml
kubectl get clusterissuer letsencrypt-prod
# expect: READY = True
```

---

## 📝 Notes

- `ClusterIssuer` is cluster-scoped — one issuer serves all namespaces
- Ports **80 and 443** must be forwarded to the MetalLB ingress IP for ACME HTTP-01 to work
- API version `cert-manager.io/v1` — requires cert-manager v1.0.0 or later
