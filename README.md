# rails-vue-starter

A starter for new Rails apps with an Inertia + Vue frontend, PostgreSQL and Kamal, set up so coding agents can do most of the work without a human reading every line.

> **Status:** early. The skeleton runs locally with authentication. The agent harness, i18n, security baseline, a reference feature and the Kamal setup are coming in that order.

## Stack

Ruby 4.0, Rails 8.1, Inertia 3 with Vue 3.5 and TypeScript, Vite 8 through `rails_vite`, Tailwind 4 with shadcn-vue, PostgreSQL 18, Solid Queue/Cache/Cable, Minitest, pnpm and Kamal 2. It starts from the official [Inertia Rails generator](https://github.com/inertia-rails/generator) Vue starter kit. Exact versions and why: [`docs/research/versions.md`](docs/research/versions.md); decisions: [`docs/adr`](docs/adr).

## Getting started

You need Ruby and Node at the versions in `.ruby-version` and `.node-version` (any version manager that reads those files works), and Docker for the database.

```sh
bin/setup
```

It installs dependencies, writes `.env` with a free port for Postgres, starts the database, prepares it and runs the app at http://localhost:3000.

Run every check with `bin/ci`.

## License

[MIT](LICENSE)
