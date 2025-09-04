#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ADO_URL:-}" || -z "${ADO_POOL:-}" ]]; then
  echo "Missing ADO_URL or ADO_POOL"
  exit 1
fi

cd /home/vsts/agent
./bin/installdependencies.sh || true

./config.sh --unattended   --url "$ADO_URL"   --pool "$ADO_POOL"   --agent "$(hostname)"   --work "_work"   --auth pat   --token "$(cat /var/run/secrets/ado/pat)"   --replace

trap "./config.sh remove --unattended --auth pat --token $(cat /var/run/secrets/ado/pat)" EXIT

./run.sh
