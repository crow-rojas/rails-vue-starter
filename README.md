# rails-vue-starter

A starter for new Rails apps with an Inertia + Vue frontend, PostgreSQL and Kamal, set up so coding agents can do most of the work without a human reading every line.

> **Status:** early. The skeleton runs locally with authentication, the agent harness and a security baseline. i18n, a reference feature and the Kamal setup are coming in that order.

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

## License

[MIT](LICENSE)
