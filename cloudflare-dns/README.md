# ☁️ Cloudflare DDNS

> Keeps Cloudflare DNS A records in sync with your dynamic home IP address.
> Runs as a Kubernetes CronJob every 20 minutes — no third-party DDNS service needed.

[![Cloudflare](https://img.shields.io/badge/Cloudflare-DDNS-orange?logo=cloudflare)](https://cloudflare.com/)

---

## 📁 Files

| File | Description |
|---|---|
| [`secrets.yaml`](secrets.yaml) | Cloudflare API token — ⚠️ never commit real values |
| [`cronjob.yaml`](cronjob.yaml) | CronJob — updates DNS A records every 20 minutes |

---

## ✅ Prerequisites

> Install k3s first — see the [root README](../README.md#installation-guide).

**1. Create a Cloudflare API token:**
- Go to `https://dash.cloudflare.com/profile/api-tokens`
- Click **Create Token** → use the **Edit zone DNS** template
- Scope it to your specific zone(s)
- Copy the token into `secrets.yaml`

**2. Find your Zone ID and DNS Record IDs:**
```bash
# Get Zone ID — shown in Cloudflare dashboard under your domain > Overview > API

# Get DNS Record IDs
curl https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records \
  -H "Authorization: Bearer <API_TOKEN>" | python3 -m json.tool | grep -E '"id"|"name"'
```

**3. Edit `cronjob.yaml`** — replace `CHANGEME_ZONE_ID` and `CHANGEME_RECORD_ID` for each container.

**4. Add one container per DNS record** you want to keep updated — copy an existing container block and update the `name`, zone ID, and record ID.

**5. Edit `secrets.yaml`** and add to `.gitignore`:
```bash
echo "**/secrets.yaml" >> ../../.gitignore
```

---

## 🚀 Deploy
```bash
kubectl apply -f secrets.yaml
kubectl apply -f cronjob.yaml

# Verify CronJob created
kubectl get cronjob ddns-cloudflare
```

---

## 🔍 Verify
```bash
# CronJob scheduled?
kubectl get cronjob ddns-cloudflare

# Trigger a manual run to test
kubectl create job --from=cronjob/ddns-cloudflare ddns-test

# Check the job logs
kubectl logs -l job-name=ddns-test
# expect: Cloudflare API responses with "success": true
```

---

## 📝 Notes

- Runs every 20 minutes — adjust `schedule` in `cronjob.yaml` if needed
- `successfulJobsHistoryLimit: 1` — keeps only the last successful job for debugging
- API token injected via Kubernetes Secret — not hardcoded in the manifest
- Add one container per DNS record — each container independently fetches the public IP and updates its record
- Public IP fetched via `https://api.ipify.org` — no dependencies, works behind NAT
- Replaces the old `google-domains-dns` folder — Google Domains was discontinued in 2023
