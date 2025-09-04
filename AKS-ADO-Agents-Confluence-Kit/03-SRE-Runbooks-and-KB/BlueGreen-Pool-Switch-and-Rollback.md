# Blue/Green Pool Switch & Rollback

- Create `agents-vN` Deployment + new ADO pool
- Switch pipelines to new pool; watch success rate
- Drain and delete old Deployment/pool
- Rollback: revert pool mapping; restore previous chart/image version
