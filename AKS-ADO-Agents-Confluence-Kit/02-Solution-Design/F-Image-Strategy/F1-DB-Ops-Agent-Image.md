# F1 DB-Ops Agent Image

- Base: minimal supported Linux + ADO agent
- Tools: psql/pg_dump/pg_restore, pgBackRest, az cli, jq, curl, gzip
- Policy: bake tools; do not apt-get at runtime
- Self-update: enabled/pinned depending on policy
