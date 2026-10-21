# rails-vue-starter

A starter for new Rails apps with an Inertia + Vue frontend, PostgreSQL and Kamal, set up so coding agents can do most of the work without a human reading every line.

> **Status:** usable. Authentication, the agent harness, a security baseline, English and Spanish, a reference resource to copy, and a Kamal deploy with backups.

## Stack

Ruby 4.0, Rails 8.1, Inertia 3 with Vue 3.5 and TypeScript, Vite 8 through `rails_vite`, Tailwind 4 with shadcn-vue, PostgreSQL 18, Solid Queue/Cache/Cable, Minitest, pnpm and Kamal 2. It starts from the official [Inertia Rails generator](https://github.com/inertia-rails/generator) Vue starter kit. Exact versions and why: [`docs/research/versions.md`](docs/research/versions.md); decisions: [`docs/adr`](docs/adr).

## Getting started

You need Ruby and Node at the versions in `.ruby-version` and `.node-version` (any version manager that reads those files works), and Docker for the database. [gitleaks](https://github.com/gitleaks/gitleaks) is optional: without it, the hooks run its Docker image, which does not work inside git worktrees.

```sh
bin/setup
```

It installs dependencies and git hooks, writes `.env` with free ports for Postgres and the app, starts the database, prepares it and runs the app.

## Checks

The harness is described in [ADR-002](docs/adr/002-agent-harness.md). In short:

- `git commit` lints the staged files and scans them for secrets in about a second.
- `bin/check` runs lint, types and tests in about 11 s; Claude Code runs it after every turn.
- `bin/ci` runs everything, in about 40 s locally; `git push` and GitHub Actions run the same script.

## Deploy

One server with Docker and SSH as root, a domain pointing at it, an SMTP account and an S3-compatible bucket ([ADR-006](docs/adr/006-deploy.md)).

```sh
export KAMAL_HOST=203.0.113.10 APP_HOST=app.example.com
export MAIL_FROM=hello@example.com SMTP_ADDRESS=smtp.example.com SMTP_USERNAME=apikey
export BACKUP_S3_ENDPOINT=https://<account>.r2.cloudflarestorage.com BACKUP_S3_REGION=auto BACKUP_S3_BUCKET=my-app-backups
export SECRET_KEY_BASE=$(bin/rails secret) POSTGRES_PASSWORD=... SMTP_PASSWORD=...
export BACKUP_S3_ACCESS_KEY_ID=... BACKUP_S3_SECRET_ACCESS_KEY=... BACKUP_PASSPHRASE=...

bin/kamal setup     # first time: server, accessories, app
bin/kamal deploy    # every time after
```

Keep the secrets in a password manager rather than your shell history; `.kamal/secrets` explains how. After the first deploy, check that an email arrives and restore one backup with `bin/kamal restore`.

## License

[MIT](LICENSE)
