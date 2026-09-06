#!/usr/bin/env bash
# Start the whole app on YOUR LAPTOP with one command:
#   bash dev.sh
# Backend -> http://localhost:8001   Frontend -> http://localhost:3000
# Stop everything with Ctrl+C.
set -euo pipefail
cd "$(dirname "$0")"

command -v python3 >/dev/null || { echo "ERROR: python3 not installed."; exit 1; }
command -v node    >/dev/null || { echo "ERROR: node not installed."; exit 1; }
command -v yarn    >/dev/null || { echo "ERROR: yarn not installed. Run: npm install -g yarn"; exit 1; }

if [ ! -f backend/.env ]; then
  cp deploy/env.example backend/.env
  echo ""
  echo "=================================================================="
  echo " Created backend/.env  ->  OPEN IT AND FILL IN YOUR DEV VALUES NOW"
  echo " IMPORTANT: use your DEV database, e.g. DB_NAME=somanifabs_dev"
  echo " Never point your laptop at the live shop database."
  echo "=================================================================="
  exit 1
fi

if grep -q "DB_NAME=somanifabs$" backend/.env; then
  echo "WARNING: backend/.env has DB_NAME=somanifabs (the LIVE database name)."
  read -r -p "Type 'yes' only if you really want that: " ok
  [ "$ok" = "yes" ] || { echo "Change DB_NAME to somanifabs_dev in backend/.env and rerun."; exit 1; }
fi

if [ ! -f frontend/.env ]; then
  printf 'REACT_APP_BACKEND_URL=http://localhost:8001\n' > frontend/.env
  echo "==> Created frontend/.env (points to local backend)"
fi

echo "==> Setting up Python environment"
[ -d .venv ] || python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
pip install -q --upgrade pip
pip install -q -r backend/requirements.prod.txt

echo "==> Installing frontend packages (first run takes a few minutes)"
(cd frontend && yarn install --silent)

cleanup() { echo ""; echo "==> Stopping..."; kill 0 2>/dev/null || true; }
trap cleanup EXIT INT TERM

echo "==> Starting backend on http://localhost:8001"
(cd backend && "../.venv/bin/uvicorn" server:app --reload --port 8001) &

sleep 3
echo "==> Starting frontend on http://localhost:3000"
(cd frontend && yarn start) &

wait
