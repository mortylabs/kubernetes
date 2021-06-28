# kubernetes overview

Here you'll find the yaml manifests for my k3s homelab. 

To learn kubernetes, I chose to write the raw yamls myself rather than blindly deploy over-complicated helm charts that someone else has published. This is hands-down the best way to learn and appreciate the inner workings of kubernetes deployments :) 

All deployments are running on Rancher k3s and Raspberry Pi 4s, with 8GB memory each and
a SSD drive replace the sdcard. MetalLB and NGINX reverse proxy have replaced Traefik.

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
vi metallb-config.yaml  _**# edit and set the IP address range that has been reserved on your DCHP server ```**_
kubectl apply -f metallb-config.yaml
```
# installation - enable https ingress using cert-manager & letsenceypt

```
kubectl create namespace cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml
cd ingress
vi letsencrypt.yaml _**#update the email address!**_
kubectl apply -f letsencrypt.yaml
```
