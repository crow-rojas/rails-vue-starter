# ADR-006: Deploy

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

A new app should reach production in an afternoon on one rented server, without a platform bill or an account per service. The template is public, so nothing about a particular server or domain can live in it.

## Decision

- Kamal 2 on one server: kamal-proxy terminates TLS with Let's Encrypt and gives zero-downtime deploys; Thruster serves assets; Solid Queue runs inside Puma (`SOLID_QUEUE_IN_PUMA`). Images go through Kamal's local registry, so no Docker Hub or GHCR account is needed.
- Postgres 18.6 as a Kamal accessory on the same server, holding the four databases Rails expects (primary, cache, queue, cable); `db:prepare` creates them on first boot.
- Images pinned by tag and digest, so a tag moved upstream changes nothing until a commit does: the Dockerfile's Ruby and Node bases (Dependabot bumps them) and both accessories, whose backup image holds the database password, the S3 keys and `PASSPHRASE` (bumped by hand: Dependabot does not read `config/deploy.yml`). Node is copied from its official image, not built by a script fetched from a branch.
- Backups: the `ardakilic/postgres-backup-s3:18` accessory dumps the primary database daily, encrypted with `PASSPHRASE`, to any S3-compatible bucket (R2, B2, S3), keeping 14 days. Cache, queue and cable are rebuildable and not backed up.
  - `bin/kamal backup` takes one now.
  - `bin/kamal backup-drill` restores the latest into a scratch database next to production, reports its tables and users, and drops it (`script/backup_drill.sh`, uploaded into the accessory).
  - The server cannot delete them: its key is scoped to the one bucket, and the bucket is locked for exactly `BACKUP_KEEP_DAYS` ([R2 bucket lock](https://developers.cloudflare.com/r2/buckets/bucket-locks/), or [Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html) in compliance mode on S3 and B2), so someone who takes the server cannot wipe the database and its backups together. Not longer: the image prunes each backup as soon as it is `BACKUP_KEEP_DAYS` old, and on R2 a locked object makes that prune fail. On S3 and B2 Object Lock needs versioning, so the prune only hides old backups; add a lifecycle rule that expires noncurrent versions.
  - `bin/kamal restore` is the real thing: the image's `restore.sh` runs `pg_restore --clean` **over the live database**, and it can only target that database. Never use it to test a backup.
- Configuration from the environment: `config/deploy.yml` reads the host, domain, email and backup settings with `ENV.fetch`, and `.kamal/secrets` reads the secrets from the environment. Production reads `APP_HOST`, `DB_HOST`, `POSTGRES_PASSWORD`, SMTP and `SECRET_KEY_BASE`; there is no credentials file. A missing variable fails the boot, except during `assets:precompile` in the image build.
- CI builds the image on every pull request.
- A deploy needs a commit CI passed: `.kamal/hooks/pre-deploy` asks `gh` for the checks on `KAMAL_VERSION` (the commit) and stops unless every one succeeded, so push and wait for CI first. `kamal rollback` runs the hook too and is let through; `--skip-hooks` is the emergency exit.

## Verified locally against the production image

The production image was built and run against Postgres 18.6 with Kamal's container names: `/up` answered, `db:prepare` created the four databases, assets and the CSP loaded, a foreign `Host` got a 403, cookies were `Secure`, HSTS was sent, a sign-up wrote to the database and Solid Queue picked up its email job.

## Verified on a real server (2026-10-21)

Deployed with `bin/kamal setup` to a Hetzner CX23 that already ran another Kamal app, which kept serving throughout: Kamal 2.12 reused the running kamal-proxy, which now routes both domains. Let's Encrypt issued the certificate, HTTP redirected to HTTPS, a sign-up delivered its verification email through SMTP, a reported error landed in `/admin/errors` and emailed the admins, a backup reached R2 and `backup-drill` restored it.

Two things learned there: the DNS record must not go through Cloudflare's proxy (orange cloud) for the first certificate, and `KAMAL_HOST` can be an SSH config alias, which is how Kamal finds the right key. The first build of the amd64 image from an arm Mac took about nine minutes.

**On every new deploy**, check: the certificate, one email delivered, `bin/kamal backup` followed by `bin/kamal backup-drill`, and that deleting that fresh backup (on S3 and B2, its version) with the server's key is refused.

## Consequences

- One server is one point of failure; the backups are the recovery plan, which is why restoring one is part of the first deploy.
- The accessory database is not upgraded by `kamal deploy`; a Postgres major upgrade is a manual dump and restore.

## Triggers that reopen this ADR

| Topic | Reopens when |
|---|---|
| Managed database | The data outgrows a single server's disk, or point-in-time recovery is required. |
| Separate job server | Jobs slow down web requests; add a `job` role running `bin/jobs`. |
| Staging | Someone besides the owner deploys; add a Kamal destination. |
