# 💾 NFS Persistent Storage

> Dynamic NFS-backed persistent volume provisioner for k3s.
> All stateful services (Home Assistant, InfluxDB, Grafana, MQTT, etc.)
> store their data on a dedicated NFS server — a Raspberry Pi with a 500GB SSD.

[![NFS](https://img.shields.io/badge/provisioner-nfs--subdir-blue)](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)

---

## 📁 Files

| File | Description |
|---|---|
| [`class.yaml`](class.yaml) | StorageClass — `managed-nfs-storage` |
| [`rbac.yaml`](rbac.yaml) | ServiceAccount, ClusterRole, and RoleBindings for the provisioner |
| [`deployment.yaml`](deployment.yaml) | NFS subdir external provisioner deployment |

---

## ✅ Prerequisites

> Install k3s first — see the [root README](../README.md#installation-guide).

**Set up the NFS server** on a dedicated Pi — follow the
[PiMyLifeUp NFS guide](https://pimylifeup.com/raspberry-pi-nfs/).

**Edit `deployment.yaml`** — set your NFS server IP and export path in two places:
```yaml
env:
  - name: NFS_SERVER
    value: "192.168.1.15"         # ← your NFS server IP
  - name: NFS_PATH
    value: "/home/pi/nfs/k8sdata" # ← your NFS export path
volumes:
  - name: nfs-client-root
    nfs:
      server: 192.168.1.15        # ← same IP
      path: /home/pi/nfs/k8sdata  # ← same path
```

---

## 🚀 Deploy
```bash
kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml

# Verify StorageClass is available
kubectl get storageclass
# expect: managed-nfs-storage
```

---

## 🔍 Verify
```bash
# Provisioner pod running?
kubectl get pods -l app=nfs-client-provisioner

# StorageClass registered?
kubectl get storageclass managed-nfs-storage

# Test by checking an existing PVC is bound
kubectl get pvc -A
```

---

## 📝 Notes

- Image updated from `k8s.gcr.io` → `registry.k8s.io` — the old registry was shut down in 2023
- `archiveOnDelete: false` — deleted PVCs are removed from NFS rather than archived
- `strategy: Recreate` — ensures only one provisioner runs at a time
- Each app creates its own PV/PVC — see individual app folders for `pv.yaml` files
- NFS server is a separate Raspberry Pi with a 500GB SSD — not the k3s node itself
