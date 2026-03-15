# ⚠️ Archived — room-assistant

This deployment has been archived. The room-assistant project is no longer
actively maintained and has been superseded by native Home Assistant presence
detection using mmWave sensors, BLE proxies, and the built-in
[MQTT Room integration](https://www.home-assistant.io/integrations/mqtt_room/).

The manifests are retained here for historical reference only.


# Room Assistant

Refer to https://www.room-assistant.io/

**local.yml** is defined in the configmap **cm.yaml**

If you already have your own **local.yml**, convert it to a configmap using:
```
 kubectl create cm cm-room-assistant --from-file=local.yml -o yaml --dry-run > cm.yaml
```
