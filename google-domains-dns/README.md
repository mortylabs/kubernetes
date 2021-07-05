# Usage

This yaml will update Google Domains DNS with your boardband external IP address. This example updates 4 sub-domains:
  - uk.yourdomain.com      (this could be your wordpress ingress)
  - unifi.yourdomain.com   (Ubiquiti Unifi Controller)
  - ha.yourdomain.com      (Home Assistant)
  - pihole.yourdomain.com  (PiHole)

Four secrets (username/password) are created to hold the credentials for each of the 4 google sub-domains, and then a cronjob runs every 5 minutes to update Google Domains DNS with the external IP address allocated to you by your broadband provider. This is done with 4 containers, one for each sub-domain. 

Each container runs the same curl image, the image size is 4MB at the time of writing, so pretty small and light-weight. :) 

Obviously delete the sub-domains you don't need.
