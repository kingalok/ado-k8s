# AKS Azure DevOps Agent (Kustomize + Flux) — Tailored starter

This variant is pre-populated with dev and prod region overlays:

- Dev regions: weu, neu, uks, eus
- Prod regions: weu, neu, uks, eus, scu, eun, cus, sea

Use the CSV-driven script in `tools/` to inject **pool IDs** and **image tags** into all overlays in one go.
