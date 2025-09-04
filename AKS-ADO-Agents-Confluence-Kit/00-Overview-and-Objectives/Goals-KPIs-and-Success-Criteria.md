# Goals, KPIs & Success Criteria

**Objective:** Replace VM-based Azure DevOps (ADO) agents with AKS-based, scalable, secure, and supportable agents.

**Primary KPIs**
- P50/P95 queue wait time per region
- Pipeline success rate and MTTR
- Cost per 100 jobs and cluster utilization
- Patch velocity (time to remediate critical CVEs)

**Success Criteria**
- Zero “missing package” incidents post-cutover
- Region-by-region dual-run and clean cutover
- Signed images/charts with SBOM and policy admission
- Right-sized pools (S/M/L) validated by 2 weeks of telemetry
