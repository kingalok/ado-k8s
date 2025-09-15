# AKS Azure DevOps Agent (Kustomize + Flux) — Monorepo (master branch)

This repo builds and ships a **self-hosted Azure DevOps agent** as an AKS pod using **Kustomize + Flux**.
Pipelines run on **Windows agents** and use **ACR Build**. If ACR Build fails, the pipeline attempts a **Podman** build on the agent.
Security scans (Trivy, Syft SBOM, Defender for Cloud) are **best-effort** and **do not fail** the build.

> Replace `CHANGE_ME_*` placeholders before production.
