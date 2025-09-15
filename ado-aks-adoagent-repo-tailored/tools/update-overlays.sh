#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-dev}"
CSV="${2:-./tools/region-pools.csv}"
ROOT="${3:-./kustomize}"

if [[ ! -f "$CSV" ]]; then echo "CSV not found: $CSV" >&2; exit 1; fi

tail -n +2 "$CSV" | while IFS=, read -r region std heavy tag; do
  region="${region//#*/}" ; region="$(echo "$region" | xargs)"
  [[ -z "$region" ]] && continue
  path="$ROOT/env/$ENV/regions/$region/kustomization.yaml"
  [[ ! -f "$path" ]] && { echo "Missing overlay: $path" >&2; continue; }
  txt="$(cat "$path")"

  [[ -n "${std:-}"  ]] && txt="$(echo "$txt" | sed -E "s/value:\s*\"?CHANGE_ME_POOLID_STD\"?/value: \"$std\"/")"
  [[ -n "${heavy:-}" ]] && txt="$(echo "$txt" | sed -E "s/value:\s*\"?CHANGE_ME_POOLID_HEAVY\"?/value: \"$heavy\"/")"
  [[ -n "${tag:-}"   ]] && txt="$(echo "$txt" | sed -E "s|(\/ado\/agent:)[^\"\s]+|\1$tag|g")"

  txt="$(echo "$txt" | sed -E "s/value:\s*\"pool-[a-z0-9-]+-std\"/value: \"pool-$region-std\"/")"
  txt="$(echo "$txt" | sed -E "s/value:\s*\"pool-[a-z0-9-]+-heavy\"/value: \"pool-$region-heavy\"/")"

  printf "%s" "$txt" > "$path"
  echo "Updated $path"
done

echo "Done. Validate with: kubectl kustomize kustomize/env/$ENV/regions/<region>"
