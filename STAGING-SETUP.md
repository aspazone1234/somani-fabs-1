# STAGING-SETUP.md — a second copy of the app for safe testing

A full second copy of the shop app on the **same droplet**, at
`staging.somanifabs.com`, with its **own database**. You push to the `staging` branch →
it deploys there automatically. When you're happy, you merge `staging` → `main` and it
goes live to the shop.

Costs nothing extra. Uses ports 8002/3001 internally; production keeps 8001/3000.

Do this once, from your laptop for steps 1-2 and on the droplet for the rest.

---

## 1. Create the `staging` branch (on your laptop)

```bash
cd ~/code/somanifabs
git checkout main && git pull
git checkout -b staging
git push -u origin staging
```

## 2. Point the subdomain at the droplet

At your domain registrar's DNS page, add:

| Type | Name | Value | TTL |
|---|---|---|---|
| A | `staging` | `YOUR_DROPLET_IP` | 300 |

## 3. Set up the staging copy (on the droplet)

```bash
ssh root@YOUR_DROPLET_IP

# a) second checkout, tracking the staging branch
git clone -b staging https://github.com/YOUR_USERNAME/somanifabs.git /opt/somanifabs-staging
cd /opt/somanifabs-staging

# b) its own secrets, with its own DATABASE NAME
cp /opt/somanifabs/.env .env
nano .env
#    change DB_NAME=somanifabs   ->   DB_NAME=somanifabs_stage
#    (optional) different SUPER_ADMIN_PASSWORD so staff can't confuse the two
chmod 600 .env

# c) first build & start
bash deploy/deploy-staging.sh
```

## 4. Add the nginx site for staging (on the droplet)

```bash
cp /opt/somanifabs-staging/deploy/nginx-staging.conf /etc/nginx/sites-available/somanifabs-staging
ln -sf /etc/nginx/sites-available/somanifabs-staging /etc/nginx/sites-enabled/somanifabs-staging
nginx -t && systemctl reload nginx

# HTTPS for the subdomain (wait for DNS first: dig +short staging.somanifabs.com)
certbot --nginx -d staging.somanifabs.com --agree-tos -m you@email.com --redirect
```

Open <https://staging.somanifabs.com> and log in. It looks identical to the shop app but
its data is completely separate.

### Optional: keep search engines and staff out
```bash
# password-protect staging
apt-get install -y apache2-utils
htpasswd -c /etc/nginx/.htpasswd somani     # asks for a password
nano /etc/nginx/sites-available/somanifabs-staging
#   inside the `location / {` block add these two lines:
#       auth_basic "Staging";
#       auth_basic_user_file /etc/nginx/.htpasswd;
systemctl reload nginx
```

## 5. Automatic staging deploys

Already wired: `.github/workflows/deploy-staging.yml` deploys every push to the
`staging` branch using the same three GitHub secrets you already added
(`DROPLET_HOST`, `DROPLET_USER`, `DROPLET_SSH_KEY`).

Test it: GitHub → **Actions** → *Deploy STAGING to droplet* → **Run workflow**.

---

## Your new everyday flow

```bash
# 1. work on a feature branch off staging
git checkout staging && git pull
git checkout -b change/whatsapp-share
#    ... make changes, test with `bash dev.sh` on your laptop ...
git add -A && git commit -m "Add WhatsApp share button" && git push -u origin change/whatsapp-share

# 2. merge into staging (pull request on GitHub) -> auto-deploys to staging.somanifabs.com
#    Try it there like a real staff member: create a session, generate a try-on, check the LED display.

# 3. happy? promote to production:
git checkout main && git pull
git merge staging
git push                     # -> auto-deploys to somanifabs.com
```

Rule of thumb: **nothing reaches `main` unless you used it on staging first.**

## Staging commands (on the droplet)

```bash
cd /opt/somanifabs-staging
docker compose -p somanifabs-staging -f docker-compose.staging.yml ps
docker compose -p somanifabs-staging -f docker-compose.staging.yml logs -f backend
bash deploy/deploy-staging.sh                 # manual redeploy
docker compose -p somanifabs-staging -f docker-compose.staging.yml down   # stop staging
curl http://127.0.0.1:8002/health
```

## Notes
- Staging has its own LED-display secret URL — don't mix it up with the shop's.
- Staging uses the **same Gemini key**, so test generations cost real money. Generate
  sparingly there (a couple of images per change is plenty).
- If the droplet has only 1 GB RAM, run staging builds when the shop is closed; the
  2 GB swap added during setup protects you, but builds will be slow.
- Free disk space occasionally: `docker system prune -af`.
