This yaml creates 4 secrets (username/password) for 4 google sub-domains, and then runs a cronjob every 5 minutes to update Google Domains DNS with the external IP address of your broadband provider. A curl container is used to run the update command to Google Domains, it's image size is 4MB at the time of writing, so pretty small and light-weight. :) 

The subdomains being updated in Google Domains DNS are:
uk.yourdomain.com (this could be your wordpress ingress)
unifi.yourdomain.com (Ubiquiti Unifi Controller)
ha.yourdomain.com  (Home Assistant)
pihole.yourdomain.com (PiHole)

Obviously delete the ones you don't need.
