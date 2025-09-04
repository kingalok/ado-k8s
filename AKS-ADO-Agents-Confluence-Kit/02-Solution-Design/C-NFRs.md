# Non-Functional Requirements

- Availability: 99.9% per region; P95 queue wait < N seconds during business hours
- Security: PSA baseline/restricted; signed images/charts; OIDC only for cloud access
- Performance: meet S/M/L throughput targets; autoscale within 2 minutes on burst
- Compliance: SBOM for all images; CVE gating at build/admission
