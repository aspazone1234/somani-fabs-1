#!/usr/bin/env bash
# One command to check, commit, push and (on main) deploy.
#   bash ship.sh "Add WhatsApp share button"
set -euo pipefail
cd "$(dirname "$0")"

MSG="${1:-}"
if [ -z "$MSG" ]; then
  echo 'Usage: bash ship.sh "short description of what you changed"'
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

bash check.sh

if git diff --quiet && git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git add -A
  git commit -m "$MSG"
fi

if [ "$BRANCH" = "main" ]; then
  echo ""
  echo "You are on MAIN — this goes to the LIVE shop website."
  read -r -p "Type 'live' to continue: " ok
  [ "$ok" = "live" ] || { echo "Stopped. Nothing pushed."; exit 1; }
fi

git push -u origin "$BRANCH"
echo "==> Pushed branch: $BRANCH"

if command -v gh > /dev/null 2>&1; then
  case "$BRANCH" in
    main)    WF="deploy.yml" ;;
    staging) WF="deploy-staging.yml" ;;
    *)       WF="" ;;
  esac
  if [ -n "$WF" ]; then
    echo "==> Triggering deploy ($WF)"
    gh workflow run "$WF" --ref "$BRANCH"
    sleep 6
    gh run watch --exit-status || { echo "Deploy FAILED — see logs above."; exit 1; }
    echo "==> Deployed."
  else
    echo "Feature branch pushed. Open a pull request when ready:"
    echo "  gh pr create --base staging --fill --web"
  fi
else
  echo "GitHub CLI ('gh') not installed — open the Actions tab and click 'Run workflow'."
  echo "Install it once with:  brew install gh   (Mac)  |  sudo apt install gh   (WSL/Ubuntu), then: gh auth login"
fi
