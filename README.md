# kubernetes

Here you'll find the yaml manifests for my k3s homelab. 

To learn kubernetes, I chose to write the raw yamls myself rather than blindly deploy over-complicated helm charts that someone else has published. This is hands-down the best way to learn and appreciate the inner workings of kubernetes deployments :) 

All deployments are running on Rancher k3s and Raspberry Pi 4s, with 8GB memory each and a SSD drive replace the sdcard. MetalLB and NGINX reverse proxy have replaced Traefik.

curl -sfL https://get.k3s.io | sh -s -  --disable=traefik --disable servicelb --write-kubeconfig-mode 644


