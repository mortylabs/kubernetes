kubectl rollout restart deployment/room-assistant
#kubectl scale --replicas=0 deployment/room-assistant
#kubectl scale --replicas=1 deployment/room-assistant
sleep 10
kubectl logs deployment/room-assistant -f
