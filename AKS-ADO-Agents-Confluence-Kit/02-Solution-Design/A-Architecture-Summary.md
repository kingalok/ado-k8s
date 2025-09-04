# Architecture Summary (One-Pager)

- Per-region AKS namespace `ns: ado-agents` with PSA baseline/restricted, NetworkPolicies, quotas.
- One agent per Pod; pools by S/M/L classes; KEDA scales by pending ADO jobs.
- Images built, scanned, signed; charts parameterize pools & limits; region promotion via Helm (Phase-1) then Flux (Phase-2).
- Identity: PAT only for registration; runtime Azure access via Workload Identity (OIDC) service connections.
