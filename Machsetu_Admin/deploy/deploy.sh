#!/usr/bin/env bash
#
# Brings the live server up to date in one go. Run on the VPS:
#
#   bash /var/www/machsetu/Machsetu_Admin/deploy/deploy.sh
#
# or from a Windows checkout with deploy.ps1 at the repo root, which also
# uploads any new settings first.
#
# 1. If .env.update is present (uploaded by deploy.ps1, never committed),
#    each KEY=value line in it is written into .env.local - replacing the old
#    value or adding a new one - and the file is then destroyed.
# 2. Pulls the latest code, installs packages, builds, and restarts PM2.
#
# Stops at the first failure, so a broken build is never restarted into.

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$APP_DIR/.env.local"
UPDATE_FILE="$APP_DIR/.env.update"

cd "$APP_DIR"

if [[ -f "$UPDATE_FILE" ]]; then
  echo "==> Applying settings from .env.update"
  umask 077
  touch "$ENV_FILE"
  work="$(mktemp)"
  cp "$ENV_FILE" "$work"

  # Uploaded from Windows, so strip carriage returns before reading.
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in '' | \#*) continue ;; esac
    key="${line%%=*}"
    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ || "$line" != *=* ]]; then
      echo "    skipped a line that is not KEY=value"
      continue
    fi
    grep -v "^${key}=" "$work" > "$work.next" || true
    printf '%s\n' "$line" >> "$work.next"
    mv "$work.next" "$work"
    echo "    set $key"
  done < <(tr -d '\r' < "$UPDATE_FILE")

  # Write back in place so .env.local keeps its owner and permissions.
  cat "$work" > "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  rm -f "$work"

  # The update held secrets; don't leave a copy lying around.
  if command -v shred > /dev/null; then shred -u "$UPDATE_FILE"; else rm -f "$UPDATE_FILE"; fi
  echo "    .env.update removed"
fi

echo "==> Pulling the latest code"
git pull --ff-only

echo "==> Installing packages"
npm i

echo "==> Building"
npm run build

echo "==> Restarting"
pm2 restart all

echo "==> Done. Live at https://machsetu.com"
