# 💡 govee2mqtt

> Bridges [Govee](https://govee.com/) smart lights and sensors to your MQTT broker,
> making them available in Home Assistant and the rest of the Morty Labs stack.

[![govee2mqtt](https://img.shields.io/badge/govee2mqtt-latest-purple)](https://github.com/wez/govee2mqtt)
[![MQTT](https://img.shields.io/badge/protocol-MQTT-orange)](../mqtt_broker/)

---

## 📁 Files

| File | Description |
|---|---|
| [`secrets.yaml`](secrets.yaml) | Govee API credentials + MQTT password — ⚠️ never commit real values |
| [`deployment.yaml`](deployment.yaml) | govee2mqtt bridge — stateless, no persistent storage needed |

---

## ✅ Prerequisites

**1. Get your Govee API key** — from the Govee Home app:
`Profile → About Us → Apply for API Key`

**2. Edit `secrets.yaml`** — set real credentials and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

**3. Edit `deployment.yaml`** — set your MQTT broker IP, port, and username:
```yaml
- name: GOVEE_MQTT_HOST
  value: "192.168.1.15"   # ← your MQTT broker IP
- name: GOVEE_MQTT_PORT
  value: "1883"           # ← your MQTT broker port
- name: GOVEE_MQTT_USER
  value: "mqtt_user"      # ← your MQTT username
```

---

## 🚀 Deploy
```bash
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl rollout status deploy/govee2mqtt
```

---

## 🔍 Verify
```bash
# Pod running?
kubectl get pods -l app=govee2mqtt

# Check logs for successful MQTT connection
kubectl logs -l app=govee2mqtt --tail=50
```

---

## 🏠 Home Assistant Integration

Once govee2mqtt is running and publishing to your MQTT broker, add the MQTT
integration in Home Assistant. Govee devices will appear automatically as
MQTT discovery entities.

---

## 📝 Notes

- Stateless — no persistent volume needed, all state lives in Govee cloud and MQTT
- `privileged: true` — required for BLE (Bluetooth Low Energy) device discovery
- `imagePullPolicy: IfNotPresent` — changed from `Always` to avoid unnecessary pulls
- `restartPolicy` removed from Deployment spec — only valid on bare Pods
- Deployment renamed from `govee2mqtt-deployment` to `govee2mqtt` for consistency
- Connects to MQTT broker on port `1883` — see [`mqtt_broker`](../mqtt_broker/) for broker setup
