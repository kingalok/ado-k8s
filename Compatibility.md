Got it. Here’s a single, copy-paste MVP compatibility/decision table you can use while reading the AKS docs. It lists what we plan to do, alternatives, what to verify with AKS, plus sensible defaults.

Area	Our MVP stance / recommendation	Acceptable options	What to confirm in AKS docs	Defaults to propose (for quick start)	Notes / Risks

Delivery engine	Flux + Kustomize only (no Helm)	—	Flux controllers cluster- or platform-managed? Allowed CRDs (Kustomization, Image* CRDs)?	GitRepository.interval=1m, Kustomization.wait=true, prune=true, timeout=5m	Keep manifests simple; one Kustomization per region
SCM for Flux Source	Azure Repos via SSH deploy key	GitLab SSH, GitHub SSH/PAT	Allowed providers & auth methods; deploy key process	Trunk branch main, protected; CODEOWNERS	If SSH disallowed, use PAT with rotation
Flux image automation	Manual tag bumps (enable later)	Flux ImageRepo/Policy/UpdateAutomation	Is write-back to Git allowed? In which envs?	Draft YAML but disabled	Avoid accidental auto-upgrades early
Repo layout	Two repos: ado-agent-image, ado-agent-kustomize	Single mono-repo (not preferred)	Any mandated structure?	Kustomize: base/ + overlays/<region>/{std,heavy}	Clear SoC; easier ownership
Versioning & tags	SemVer; no latest	—	Any org tag policy?	Publish X.Y.Z; optionally X.Y, X	Immutability required for rollback
Namespace model	One namespace per region (namespace-as-a-service)	Shared ns (not preferred)	Request process; PSA level; who sets quotas	Name: ado-agents; PSA baseline→restricted	Avoid multi-tenant surprises
Namespace capacity	Request CPU/Mem quotas per region	—	How AKS team sizes; burst policy	Small (Dev): 8 vCPU/16Gi, Medium (Test): 14/28Gi, Large (Prod MVP): 20/40Gi	Add 20–30% headroom in ask
LimitRange defaults	Enforce shapes via defaults	—	Are LimitRanges supported per ns?	std: req 1/2Gi lim 2/4Gi, heavy: req 4/8Gi lim 6/12Gi	Prevents random sizing
Pools (logical)	Start with 2 pools: std, heavy	Later add s/m/l if needed	Naming rules; pool IDs stable	Pools named `pool-<region>-std	heavy`
Pod resources (std)	For light/medium jobs	—	Any per-pod caps?	req 1 vCPU / 2Gi; lim 2 vCPU / 4Gi; emptyDir 15Gi	Tweak after 2 weeks telemetry
Pod resources (heavy)	For restore/reindex/compression	—	Any per-pod caps?	req 4 vCPU / 8Gi; lim 6 vCPU / 12Gi; emptyDir 60Gi	Keep one warm for latency
Ephemeral storage	emptyDir for workspace	Azure Disk (if huge dumps)	Node disk limits; sizeLimit policy	As above (15Gi/60Gi)	Plan Azure Disk only when needed
KEDA (autoscaling)	One ScaledObject per pool (by ADO queue)	HPA manual (fallback)	KEDA installed? Version? RBAC in ns?	Poll=30s, Cooldown=120s, std: min=0 max=12, heavy: min=1 max=4, targetQueue=1	Confirm controller namespace/permissions
Agent registration	PAT for registration only	—	Secret engine & mount method	PAT projected at /var/run/secrets/ado	Keep TTL short; rotate often
Secrets engine	Prefer Key Vault CSI	External Secrets, Vault	Which engine is standard? Rotation?	SecretProviderClass name & mount path	No secrets in Git or variables
Runtime identity	Workload Identity (OIDC) for Azure	SP client secret (avoid)	OIDC onboarding steps & scopes	Create federated creds; test az	Removes long-lived creds
Container registry	ACR geo-rep (or Nexus replication)	Single-region registry (not ideal)	Standard registry? Immutability?	Retention ~180d; keep last 50; private link if required	Measure pull latency per region
Image policy	Scan + Sign (Cosign) + SBOM	—	Any admission verify in cluster?	Fail CI on CVSS≥9; attach SBOM to release	Prepare for cluster-side verify later
Admission / policy	Prepare for signature verify (P1)	—	Gatekeeper/Kyverno policies?	Annotate images if needed	Start in non-prod when available
Networking / egress	Deny-all + allowlist	Wider egress (not preferred)	Proxy/CA/NO_PROXY rules; endpoints list	Allow: dev.azure.com, registry, NTP/time, corporate proxy	Add corporate CA bundle if intercept
DNS / time	Use platform defaults	Custom	Need to set NTP or DNS search?	—	Time skew can break TLS; verify
Security context	Non-root, no privilege escalation, drop caps, seccomp=RuntimeDefault	—	PSA/PodSecurity admission level	Apply via Kustomize patch in base	Read-only rootfs if tools allow
RBAC	Minimal SA/Role/RoleBinding	Broader (avoid)	Any mandated roles?	SA ado-agent; Role read pods/logs	Keep cluster roles out
Observability	Use platform Grafana/Alerting	Self-host (avoid)	How to add boards/alerts	Dashboard panels: queue P95, success rate, restarts/OOM, CPU throttle, image pull latency, KEDA replicas	Link alerts to runbooks
Alerts	Actionable only	—	Alerting channel; throttling limits	P95 queue >60s (5m), OOMKilled>0, ImagePullBackOff>0, KEDA scale fail	Avoid noisy/duplicate pages
CI for image	Build → scan → SBOM → sign → push	—	Approved scanners & thresholds	Trivy/Grype; CVSS≥9 blocks	Store digest in release notes
Base image	Mirror & pin by digest	Pull public (avoid)	Mirror policy; CVE handling	Track digests; refresh monthly	Faster cold starts, deterministic
Flux health checks	Kustomization healthChecks on Deployments	None (avoid)	Any constraints on health checks	Check ado-agent-std & ado-agent-heavy	Block rollout on unhealthy
Rollout order	One primary region first (Dev cohort)	All at once (avoid)	Promotion process & approvals	Dev→Test→Prod, sequential regions	Safer blast radius
Fallback to VM	Pipeline probe + conditional rerun on VM for infra errors only	Manual reruns	Is rerun policy acceptable?	Implement one guarded retry	Don’t mask functional failures
Pilot success criteria	N green runs; queue SLA met; no Sev-1	—	SLA numbers; error budgets	P95 queue ≤60s; 2 weeks no Sev-1	Agree exit criteria with SRE
Runbooks	Concise KB with kubectl snippets	—	KB format/location	Topics: registration fail, image-pull, KEDA/HPA, OOM/throttle, proxy/DNS	Link from alerts
Access / RBAC	Least-privileged access for SRE	Broad (avoid)	Who gets kubectl; audit model	Read/exec in ns; no cluster-admin	Break-glass process defined
Change mgmt	PR approvals; env gates	Ad-hoc (avoid)	Required approvers	1 approval Dev/Test; 2 in Prod	Keep audit trail tight
DR / multi-region	Add regions in waves; ensure registry replication	Single region only	Registry replication status; failover steps	Minimal “pilot-light” in 2nd region later	Latency/data-gravity may force local pools
Windows agents (optional)	Not in MVP; plan later if needed	—	Are Windows pools available?	Base OS=Node OS (2019/2022)	Requires Azure CNI; large image size


If you want this as a CSV/Excel too, say the word and I’ll generate the file so you can drop it straight into Confluence.

