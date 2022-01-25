# Room Assistant

Refer to https://www.room-assistant.io/

**local.yml** is defined in the configmap **cm.yaml**

If you already have your own **local.yml**, convert it to a configmap using:
```
 kubectl create cm cm-room-assistant --from-file=local.yml -o yaml --dry-run > cm.yaml
```
