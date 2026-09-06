#!/usr/bin/env bash
# Deploy the STAGING copy. Lives in /opt/somanifabs-staging on the droplet and
# tracks the `staging` branch. Run:  cd /opt/somanifabs-staging && bash deploy/deploy-staging.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Pulling latest staging code"
git fetch --all
git reset --hard origin/staging

echo "==> Building staging containers"
docker compose -p somanifabs-staging -f docker-compose.staging.yml build

echo "==> Restarting staging"
docker compose -p somanifabs-staging -f docker-compose.staging.yml up -d

docker image prune -f

echo "==> Waiting for staging backend health"
for i in $(seq 1 30); do
  if curl -fs http://127.0.0.1:8002/health > /dev/null; then
    echo "Staging backend healthy."
    break
  fi
  sleep 2
done

curl -fs http://127.0.0.1:8002/health || {
  echo "Staging backend NOT healthy. Logs:"
  docker compose -p somanifabs-staging -f docker-compose.staging.yml logs --tail=50 backend
  exit 1
}
echo "==> Staging deploy done."
