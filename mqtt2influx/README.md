# 📨 mqtt2influx

> Bridges MQTT sensor streams into InfluxDB for time-series storage and
> Grafana dashboards. Built on a custom Python container by Morty Labs.

[![mqtt2influx](https://img.shields.io/badge/mqtt2influx-latest-blue)](https://github.com/mortylabs/mqtt2influx)
[![Python](https://img.shields.io/badge/python-3.9%2B-blue?logo=python)](https://python.org)
[![MQTT](https://img.shields.io/badge/protocol-MQTT-orange)](../mqtt_broker/)
[![InfluxDB](https://img.shields.io/badge/storage-InfluxDB-orange)](../influxdb/)

---

## 📁 Files

| File | Description |
|---|---|
| [`configmap.yaml`](configmap.yaml) | MQTT topic → InfluxDB measurement mapping |
| [`secrets.yaml`](secrets.yaml) | MQTT + InfluxDB credentials — ⚠️ never commit real values |
| [`deployment.yaml`](deployment.yaml) | mqtt2influx deployment |

---

## ✅ Prerequisites

> Install k3s and MetalLB first — see the [root README](../README.md#installation-guide).
> [`influxdb`](../influxdb/) and [`mqtt_broker`](../mqtt_broker/) must be running first.

**1. Edit `secrets.yaml`** — set real credentials and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

**2. Edit `configmap.yaml`** — add your MQTT topics and corresponding InfluxDB measurement names:
```yaml
topics.txt: |
  'your/mqtt/topic'   "influx_measurement_name"
```

**3. Edit `deployment.yaml`** — set your MQTT broker and InfluxDB IPs:
```yaml
- name: INFLUX_SERVER
  value: "192.168.1.15"   # ← your InfluxDB IP
- name: MQTT_SERVER
  value: "192.168.1.15"   # ← your MQTT broker IP
- name: MQTT_PORT
  value: "1883"           # ← your MQTT broker port
```

---

## 🚀 Deploy
```bash
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl rollout status deploy/mqtt2influx
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=mqtt2influx

# Check logs for successful MQTT + InfluxDB connection
kubectl logs -l app=mqtt2influx --tail=50
```

---

## 📝 Notes

- Custom image `mortyone/mqtt2influx` — source at [mortylabs/mqtt2influx](https://github.com/mortylabs/mqtt2influx)
- `imagePullPolicy: Always` — picks up latest image builds automatically
- Edit `configmap.yaml` to match your own MQTT topics and InfluxDB measurement names
- Both MQTT and InfluxDB usernames and passwords are injected via Kubernetes Secrets
- See [mortylabs/mqtt2influx](https://github.com/mortylabs/mqtt2influx) for full configuration docs including wildcard topic support
