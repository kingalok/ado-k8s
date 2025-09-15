#!/usr/bin/env bash
set -euo pipefail

pat_file="/var/run/secrets/ado/token"
if [[ ! -f "${pat_file}" ]]; then
  echo "[entrypoint] PAT token file not found at ${pat_file}"
  exit 1
fi

export VSO_AGENT_IGNORE=AZP_TOKEN,AZP_URL,AZP_POOL,AZP_AGENT_NAME,AZP_WORK
export AZP_URL="${ADO_URL}"
export AZP_POOL="${ADO_POOL}"
export AZP_AGENT_NAME="${ADO_AGENT_NAME:-$(hostname)}"
export AZP_WORK="${ADO_WORK}"

cleanup() {
  echo "[entrypoint] Caught signal, removing agent..."
  ./config.sh remove --acceptTeeEula --auth pat --token "$(cat ${pat_file})" || true
  exit 0
}

trap 'cleanup' TERM INT

cd /azp
./config.sh --unattended   --acceptTeeEula   --url "${AZP_URL}"   --auth pat   --token "$(cat ${pat_file})"   --pool "${AZP_POOL}"   --agent "${AZP_AGENT_NAME}"   --work "${AZP_WORK}"

./run.sh &
wait $!
cleanup
