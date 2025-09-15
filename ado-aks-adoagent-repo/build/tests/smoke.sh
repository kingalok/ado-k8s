#!/usr/bin/env bash
set -euo pipefail
echo "[smoke] which psql: $(which psql || true)"
echo "[smoke] az version: $(az version | jq -r '."azure-cli"' 2>/dev/null || echo 'n/a')"
echo "[smoke] done"
