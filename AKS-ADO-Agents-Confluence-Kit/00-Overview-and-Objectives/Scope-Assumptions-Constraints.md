# Scope, Assumptions & Constraints

**In Scope**
- ADO agents on AKS with KEDA autoscaling and per-region pools
- Image build, scan, sign; chart templating and deployment
- Identity via AKS Workload Identity/OIDC; PAT only for registration
- Observability dashboards and SRE runbooks

**Assumptions**
- Platform team provides AKS namespaces and baseline policies
- Registry supports geo-replication (ACR) or Nexus replication
- Flux GitOps may arrive later; Phase-1 uses Helm via ADO

**Constraints**
- Namespace quotas; egress allowlists; proxy/CA requirements
- No privileged workloads in standard pools
