# ADR-001: Stack

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

This repository is a starting point for new apps, meant to be developed mostly by coding agents. The stack has to run locally with one command, deploy quickly with Kamal, and use current supported versions. Speed matters as much as safety: checks that take minutes get skipped, so every check has to stay fast.

## Decision

- **Backend**: Rails 8.1 on Ruby 4.0, PostgreSQL 18, Solid Queue/Cache/Cable, Minitest with fixtures.
- **Frontend**: Inertia 3 with Vue 3.5 and TypeScript, Tailwind 4 and shadcn-vue. Vue over React because its model is closer to Rails: templates, conventions and less ceremony.
- **Base**: the official [Inertia Rails generator](https://github.com/inertia-rails/generator) in Starter Kit mode (`INERTIA_FRAMEWORK=vue`, Minitest, system tests, Alba, SSR off). We follow its choices even where they are newer and less proven, such as `rails_vite` over `vite_rails`, because it is the path the Inertia Rails maintainers support. Its raw output is the first commit after the license, so every later change shows up as our own diff.
- **Types across the boundary**: Typelizer generates TypeScript types from the Alba serializers and the routes; `bin/ci` fails when they are stale.
- **Package manager**: pnpm instead of the generator's npm, for its supply-chain defaults: a one-day minimum release age and failing on unreviewed build scripts. `pnpm-workspace.yaml` adds `trustPolicy: no-downgrade` for releases younger than 30 days. Exclusions from those policies are not allowed; when a dependency asks for a version younger than a day, lower the floor of its range instead.
- **Local services**: only Postgres runs in Docker (`docker-compose.yml`). `bin/setup` writes `.env` with the first free port from 5432, so the repo runs next to other Postgres instances and every checkout gets its own container and volume.
- **Versions**: pinned in `.ruby-version`, `.node-version` and `packageManager`, recorded with their sources in `docs/research/versions.md`. No version manager is required.
- **Language**: English for everything in the repo. The UI is translated with English as the default locale and Spanish as the second.
- **License**: MIT.

## Consequences

- Upgrading the base means reading the generator's changes and porting them by hand; generated apps get no automatic upgrades.
- `config/credentials.yml.enc` is not committed: a public template cannot ship credentials encrypted with a key only its author holds. Development and test do not need them; production credentials are created with the Kamal setup.
- Because the type check runs on TypeScript 6 through `vue-tsc`, it does not get the TypeScript 7 native speedup yet (see the triggers).

## Triggers that reopen this ADR

| Topic | Reopens when |
|---|---|
| TypeScript 7 | `vue-tsc` supports it natively, or the type check gets slow enough to adopt `typescript-native-bridge` (an alias of `typescript` that runs the check on tsgo). |
| Node 26 | Node 26 becomes LTS. Node 25 and later no longer bundle corepack, which `bin/setup`, the Dockerfile and CI use to enable pnpm. |
| Rails 8.2 | It is released; Rails 8.1 gets security fixes only until 2027-10-10. |
| PostgreSQL 19 | It reaches general availability. |
| Biome | Its Vue support leaves experimental status, which could replace ESLint and Prettier with one faster tool. |
