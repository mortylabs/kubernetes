# Eclipse Mosquitto MQTT Broker

Refer to https://mosquitto.org/


# Changing the default User / Password

```
kubectl exec -it deployment/mqtt-deployment -- sh
cd mosquitto/config/
mosquitto_passwd -c mosquitto.conf mqtt_user
```
Then update your configmap so the file **mosquitto.passwd** contains the newly encrypted password
