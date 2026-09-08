#!/usr/bin/env bash
# Pre-flight check. Run BEFORE you push anything:  bash check.sh
# Catches the two things that break deploys: backend import errors and frontend build errors.
set -uo pipefail
cd "$(dirname "$0")"
fail=0

echo "==> Checking backend imports"
PY=python3
[ -x .venv/bin/python ] && PY=.venv/bin/python
if (cd backend && "../$PY" -c "import server" 2>/tmp/somani_backend_check.log || "$PY" -c "import server" 2>/tmp/somani_backend_check.log); then
  echo "    OK"
else
  echo "    FAILED:"; tail -20 /tmp/somani_backend_check.log; fail=1
fi

echo "==> Building frontend (warnings treated as errors, like the server does)"
if (cd frontend && CI=true yarn build > /tmp/somani_frontend_check.log 2>&1); then
  echo "    OK"
  rm -rf frontend/build
else
  echo "    FAILED:"; tail -30 /tmp/somani_frontend_check.log; fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo ""
  echo "DO NOT PUSH. Fix the errors above (paste them to your coding agent) and run check.sh again."
  exit 1
fi

echo ""
echo "All checks passed. Safe to push."
