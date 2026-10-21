# ADR-006: Deploy

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

A new app should reach production in an afternoon on one rented server, without a platform bill or an account per service. The template is public, so nothing about a particular server or domain can live in it.

## Decision

- **Kamal 2 on one server**: kamal-proxy terminates TLS with Let's Encrypt and gives zero-downtime deploys; Thruster serves assets; Solid Queue runs inside Puma (`SOLID_QUEUE_IN_PUMA`). Images go through Kamal's local registry, so no Docker Hub or GHCR account is needed.
- **Postgres 18.6 as a Kamal accessory** on the same server, holding the four databases Rails expects (primary, cache, queue, cable); `db:prepare` creates them on first boot.
- **Backups**: the `ardakilic/postgres-backup-s3:18` accessory dumps the primary database daily, encrypted with `PASSPHRASE`, to any S3-compatible bucket (R2, B2, S3), keeping 14 days. `bin/kamal restore` restores the latest. Cache, queue and cable are rebuildable and not backed up.
- **Configuration from the environment**: `config/deploy.yml` reads the host, domain, email and backup settings with `ENV.fetch`, and `.kamal/secrets` reads the secrets from the environment. Production reads `APP_HOST`, `DB_HOST`, `POSTGRES_PASSWORD`, SMTP and `SECRET_KEY_BASE`; there is no credentials file. A missing variable fails the boot, except during `assets:precompile` in the image build.
- **CI builds the image** on every pull request.

## Verified before the first deploy

The production image was built and run against Postgres 18.6 with Kamal's container names: `/up` answered, `db:prepare` created the four databases, assets and the CSP loaded, a foreign `Host` got a 403, cookies were `Secure`, HSTS was sent, a sign-up wrote to the database and Solid Queue picked up its email job.

Not verified without a real server and bucket, so **do it on the first deploy**: the TLS certificate, an email actually delivered, and one backup restored with `bin/kamal restore` into a scratch database.

## Consequences

- One server is one point of failure; the backups are the recovery plan, which is why restoring one is part of the first deploy.
- The accessory database is not upgraded by `kamal deploy`; a Postgres major upgrade is a manual dump and restore.

## Triggers that reopen this ADR

| Topic | Reopens when |
|---|---|
| Managed database | The data outgrows a single server's disk, or point-in-time recovery is required. |
| Separate job server | Jobs slow down web requests; add a `job` role running `bin/jobs`. |
| Staging | Someone besides the owner deploys; add a Kamal destination. |
