# Changelog

Notable changes to the template are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Apps made from the template do not receive these changes automatically; each entry says what to port.

## [Unreleased]

## [0.1.0] - 2026-10-21

The first release.

### Added

- Rails 8.1, Ruby 4.0, Inertia 3, Vue 3.5 with TypeScript, Tailwind 4 and shadcn-vue, generated with the official Inertia Rails generator, on PostgreSQL 18 with Solid Queue, Cache and Cable, using pnpm.
- Authentication: sign up, sign in, email verification, password reset, sessions and account deletion.
- English and Spanish, with the language per user or from the browser, and one set of Rails locale files for both Rails and Vue.
- `projects`, a reference resource with tests at every layer.
- The agent harness: Claude Code hooks, lefthook, `bin/check`, `bin/ci`, `bin/guard` and deny rules.
- Typed props and routes from Typelizer, checked for freshness.
- Error and job dashboards at `/admin/errors` and `/admin/jobs` for `ADMIN_EMAILS`.
- A Kamal deploy with Postgres as an accessory, daily encrypted backups to S3-compatible storage, and `bin/kamal backup-drill`.
- `bin/rename` to rename the template, `bin/merge` to merge with signed commits, and demo seeds.

### Security

- Rate limits on sign in, sign up, password reset, verification emails and every current-password check.
- A content security policy with nonces, a Permissions-Policy header, SSL in production and no account enumeration in password reset.
- Admin access requires a verified email.
- A 7-day cooldown for gems, a 1-day minimum age and a trust policy for npm packages, and Dependabot with the same cooldown.

[Unreleased]: https://github.com/crow-rojas/rails-vue-starter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/crow-rojas/rails-vue-starter/releases/tag/v0.1.0
