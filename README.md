# kubernetes overview

Here you'll find the yaml manifests for my k3s homelab running **v1.22.5+k3s1** as of 10th March 2022. 

To learn kubernetes, I wrote the yamls myself rather than blindly deploy helm charts that someone else has written. 

All deployments are running on Rancher k3s with a MetalLB Load Balancer and NGINX reverse proxy replacing Traefik. Hardware comprises Raspberry Pi 4Bs (8GB RAM), and SSD drives replacing the sdcard. The OS used is Raspbian **Bullseye 64 bit**.

For persistent storage, a Network File Server (NFS) is used. You could use your Synology Raid Controller, however my NFS server is simply a raspberry pi with an 500GB SSD drive replacing the SD Card, and automatic backups to GDrive and also github. A lot cheaper and very adequate. 



# installation - k3s

In file /boot/cmdline.txt add the following to the end of the file:
```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

Then to install k3s with the default load balancer disabled:
```
curl -sfL https://get.k3s.io | sh -s -  --disable=traefik --disable servicelb --write-kubeconfig-mode 644
```

# installation - NFS for persistent storage

Follow this tutorial to configure your pi as a NFS:
https://pimylifeup.com/raspberry-pi-nfs/

Then to setup the nfs-client-provisioner in k3s:
```
cd pv_nfs
kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
```

# installation - NGINX Ingress
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
```

# installation - MetalLB Load Balancer
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
cd metallb
vi metallb-config.yaml  #edit and set the IP address range that has been reserved on your DCHP server
kubectl apply -f metallb-config.yaml
```

# installation - enable https ingress using cert-manager & letsencrypt

**cert-manager-arm.yaml** below will install cert-manager **v1.7.1**, which is the latest version as of 10th March 2022.
```
kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
cd ingress
vi letsencrypt.yaml #update the email address!
kubectl apply -f letsencrypt.yaml
```

Remeber to open ports 80 and 443 on your firewall / router, and redirect traffic to the master node ingress ip from metallb load balancer. In this example it would be 192.168.1.110. So direct port traffic from both 80 and 443 to 192.168.1.110 respectively.

# installation - applications

for each app, deploy pv.yaml to create the persistent volume and then deployment.yaml. Remember to edit pv.yaml and enter your NFS IP address and folder. That's it :) 
