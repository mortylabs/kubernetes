# kubernetes overview

Here you'll find the yaml manifests for my k3s homelab. 

All deployments are running on Rancher k3s but with a MetalLB load balancer and NGINX reverse proxy replacing Traefik. Hardware comprises Raspberry Pi 4Bs (8GB RAM), and SSD drives replacing the sdcard, all running the Raspbian Buster operating system. 

For persistent storage, a Network File Server (NFS) is used. Really it's just a raspberry pi with a SSD drive acting as a NFS. When Raspbian OS 64 bit is released I'll switch to LongHorn (no working image available for Raspbian Buster 32-bit)

To learn kubernetes, I decided to write some deployment yamls myself rather than blindly deploy helm charts that someone else has written. 


# installation - k3s
```
curl -sfL https://get.k3s.io | sh -s -  --disable=traefik --disable servicelb --write-kubeconfig-mode 644
```

# installation - NGINX Ingress
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
```

# installation - MetalLB Load Balancer
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
cd metallb
vi metallb-config.yaml  #edit and set the IP address range that has been reserved on your DCHP server
kubectl apply -f metallb-config.yaml
```

# installation - enable https ingress using cert-manager & letsencrypt
```
kubectl create namespace cert-manager
cd ingress
kubectl apply -f cert-manager-arm.yaml
vi letsencrypt.yaml #update the email address!
kubectl apply -f letsencrypt.yaml
```


# installation - NFS

Follow this tutorial to configure your pi as a NFS:
https://pimylifeup.com/raspberry-pi-nfs/

Then to setup the nfs-client-provisioner in k3s:
```
cd pv_nfs
kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
```
