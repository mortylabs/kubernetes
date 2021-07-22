# Usage

This yaml will update Google Domains DNS with the external IP address given to you by your broadband provider. This example updates 5 sub-domains:
  - ha.yourdomain.com      (Home Assistant)
  - unifi.yourdomain.com   (Ubiquiti Unifi Controller)
  - uk.yourdomain.com      (UK-based wordpress website)
  - pihole.yourdomain.com  (PiHole)
  - grafana.yourdomain.com 

Five secrets (username/password) are created to hold the credentials for each of the five google sub-domains, and then a cronjob runs every 5 minutes to update Google Domains DNS with your external IP address. This is done using 5 containers, one for each sub-domain. 

Each container runs the same curl image, the image size is 4MB at the time of writing, so pretty small and light-weight. :) 

When encoding credentials in BASE64 from the cmdline, sometimes a newline char is added, which corrupts the secret. To get around this:

`echo -n 'mypassword' | base64`


