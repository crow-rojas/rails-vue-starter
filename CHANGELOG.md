# Changelog

Notable changes to the template are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Apps made from the template do not receive these changes automatically; each entry says what to port.

## [Unreleased]

## [0.2.0] - 2026-10-27

### Added

- An installable PWA with an offline page (ADR-007). To port: `PwaController`, `app/views/pwa`, its routes, the manifest and worker tags in `app/views/layouts/application.html.erb`, and the `networkError` listener in `app/javascript/entrypoints/inertia.ts`.
- Errors outside development render as an Inertia page in the app's language. To port: `rescue_from` in `InertiaController`, `ErrorsShowSerializer`, `pages/errors/show.vue` and the `errors` keys.
- System tests check every page with axe-core for WCAG 2 A and AA and fail when the browser logs an error. To port: `test/application_system_test_case.rb` and the `axe-core` package.
- Tests that pin the security rules: the session purge on a password change, the un-verify on an email change, `Session.expired`, and the other-user 404 for sessions. To port: `test/models/user_test.rb`, `test/models/session_test.rb` and the assertions added to the settings and sessions tests.
- `test/serializers/page_types_test.rb` checks that each page declares its serializer's type as its props.
- `.kamal/hooks/pre-deploy` refuses to deploy a commit whose checks have not passed.
- Production queries on the primary database time out after 15 seconds (`statement_timeout` in `config/database.yml`).
- `bin/setup` skips the Docker database when `DATABASE_URL` is set, and gives each worktree its own ports and Postgres container.
- Codex runs the turn-end check from `.codex/hooks.json`.
- knip fails `bin/ci` on dead frontend code.
- ADR-008 and `docs/recipes/llm.md`, the shape and the steps for LLM features.
- `.github/rulesets/main.json`, the `main` ruleset, with the README steps to apply it and turn on private vulnerability reporting in a new app.
- `bin/rename` points the links to this repository (`SECURITY.md`, the issue template config, the sidebar) at the app's `origin`, and lists what is left to do by hand.

### Changed

- The Vue pages read translations with i18n-js again, instead of the 30-line `lib/translate.ts` and its Vitest setup. Apps made from v0.1.0 can keep either; to switch back, restore `app/javascript/composables/useI18n.ts` from this release and add `i18n-js`.
- The PR size check runs in its own workflow, `.github/workflows/pr-size.yml`; `ci.yml` no longer runs on label events. See Security.
- The layouts are two files: `AppLayout.vue` and `AuthLayout.vue` absorb `layouts/app/AppSidebarLayout.vue`, `layouts/auth/AuthSimpleLayout.vue`, `AppShell.vue` and `AppContent.vue`. There is one `BreadcrumbItem` type, with an optional `href`.
- In settings, the flash toast is the only save confirmation, as in projects, and the controllers read `Current.user` directly.
- Tests read Inertia props with `inertia_rails/minitest` and assert copy through its i18n keys.
- ESLint 10 with eslint-plugin-import-x. Base and accessory images are pinned by digest, and GitHub Actions by commit SHA.

### Fixed

- Development mail links pointed at port 3000 instead of the checkout's `PORT`. To port: `config/environments/development.rb`.
- The sidebar marked no item active on a resource's show, new and edit pages. To port: `isActive` in `components/NavMain.vue`.
- `bin/guard` crashed on an untracked binary file under `test/`.
- The generated-types step blamed stale types when the Rails task itself failed.
- The jobs dashboard dropped the other locales when it loaded translations first.
- Links and dark-theme error text did not reach AA contrast.
- `bin/setup` cleared logs and tmp even with `--skip-server`.
- The gitleaks Docker fallback scanned nothing inside a git worktree. To port: mount the shared git dir in `bin/gitleaks`.
- The README's upgrade recipe merged unrelated histories; it now applies the diff between two release tags.

### Security

- A label event could turn a failed required check green: `ci.yml` re-ran on `labeled`, skipped the `ci` and `image` jobs, and GitHub counts a skipped job as passed. To port: move `pr_size` into `.github/workflows/pr-size.yml` and go back to the default `pull_request` types in `ci.yml`.
- `bin/guard` protects the check wrappers (`bin/setup`, `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`, `bin/gitleaks`), their allowlists such as `config/bundler-audit.yml`, and its own test; a deny rule keeps Claude Code from typing the human-only override trailer.
- crass 1.0.8, for GHSA-pq4g-8rxf-4g29.
- The LLM recipe looked sessions up with `find_by`, which skips the 30-day lifetime; it uses `Session.find_active` now.
- Sessions expire 30 days after sign in; before, the cookie was permanent and any session row signed its user in forever. To port: `Session::LIFETIME`, `Session.find_active` and `.expired` in `app/models/session.rb`, `start_session_for` in `ApplicationController`, the lookup in the admin constraint in `config/routes.rb`, and `clear_expired_sessions` in `config/recurring.yml`.
- The deploy decision (ADR-006) locks the backup bucket so the server cannot delete backups, and adds out-of-band alerts.

### Removed

- Active Storage, Action Mailbox, Action Text and jbuilder. The engines drew public routes such as `POST /rails/active_storage/direct_uploads` with no tables behind them. To port: delete their `require` lines in `config/application.rb`, the `active_storage.service` lines in `config/environments`, `config/storage.yml`, the storage volume in `config/deploy.yml` and the `jbuilder` gem.
- The `avatar` placeholder in `UserSerializer`, which was always `nil`, and the unused `className` prop of `AppLogoIcon`.

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

[Unreleased]: https://github.com/crow-rojas/rails-vue-starter/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/crow-rojas/rails-vue-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/crow-rojas/rails-vue-starter/releases/tag/v0.1.0
