# Pinned versions

Checked 2026-10-21 against the sources linked below. Runtime and tool pins live in `.ruby-version`, `.node-version`, `package.json` (`packageManager`) and `docker-compose.yml`; libraries are locked in `Gemfile.lock` and `pnpm-lock.yaml`.

## Runtimes and tools

| Item | Pin | Support and notes | Source |
|---|---|---|---|
| Ruby | 4.0.7 | 4.0 is in normal maintenance. | [ruby-lang.org branches](https://www.ruby-lang.org/en/downloads/branches/) |
| Rails | 8.1.4 | Bug fixes ended 2026-10-10; security fixes until 2027-10-10. 8.2 is not released. | [Maintenance policy](https://rubyonrails.org/maintenance), [RubyGems](https://rubygems.org/gems/rails/versions) |
| Bundler | 4.0.20 | Supports a `cooldown` on the gem source (4.0.13+). | [RubyGems blog](https://blog.rubygems.org/2026/06/03/cooldown-let-new-gems-be-vetted.html) |
| Node.js | 24.22.0 | 24 "Krypton" is the active LTS. 24.22.1 (2026-10-20) was not yet in node-build. Node 25+ does not bundle corepack. | [Node.js releases](https://nodejs.org/en/about/previous-releases), [Corepack docs](https://nodejs.org/dist/latest/docs/api/corepack.html) |
| pnpm | 12.14.0 | Defaults: `minimumReleaseAge` 1440 minutes, `strictDepBuilds` true. | [pnpm settings](https://pnpm.io/settings/dependency-resolution), [build settings](https://pnpm.io/settings/build) |
| PostgreSQL | 18.6 (`postgres:18.6` image) | Supported until 2030-11-14. 19 is a release candidate. | [Versioning policy](https://www.postgresql.org/support/versioning/) |
| Kamal | 2.12.0 | No 3.x exists. | [RubyGems](https://rubygems.org/gems/kamal/versions) |

## Libraries chosen by the generator

The base comes from [inertia-rails/generator](https://github.com/inertia-rails/generator) (`dist/template.rb`, sha256 `e810051d8c6b7b2a85b95211d548295892c3a3f2afd567507563ae63e004212d`).

| Library | Locked | Notes |
|---|---|---|
| inertia_rails / @inertiajs/vue3 | 3.23.0 / 3.9.1 | Inertia 3. |
| rails_vite / rails-vite-plugin | 0.3.0 / 0.3.0 | The generator refuses to run next to `vite_rails`. |
| vite | 8.3.4 | The generator asked for 8.3.5, published hours earlier; the floor was lowered instead of excluding it from the release-age policy. |
| vue | 3.5.44 | |
| typescript / vue-tsc | 6.0.3 / 3.3.13 | `vue-tsc` does not run on TypeScript 7 yet. `typescript-native-bridge` (6.0.3-bridge.18.tsgo.7.0.2) aliases `typescript` and runs the check on tsgo. Not adopted: the check takes about 3 s today. [vuejs/language-tools#5381](https://github.com/vuejs/language-tools/issues/5381) |
| tailwindcss | 4.3.3 | `@tailwindcss/typography` was removed: unused, and it pulled a vulnerable `postcss-selector-parser`. |
| @lucide/vue | 1.60.0 | Same floor adjustment as vite (1.61.0 was hours old). The generator also installs the deprecated `lucide-vue-next`, which the pages still import. |
| eslint / eslint-plugin-vue / prettier | 9.39.5 / 10.11.1 / 3.9.10 | ESLint 9 is out of support. Biome is not used yet because its Vue support is experimental. [Biome language support](https://biomejs.dev/internals/language-support) |
| typelizer / alba / alba-inertia | 0.14.0 / 4.0.1 / 0.1.4 | |
| authentication-zero | 4.0.3 | Generates the auth code into the app; no release since 2024-12. |
| solid_queue / solid_cache / solid_cable | 1.7.0 / 1.0.10 / 4.1.0 | |
| puma / thruster | 8.0.2 / 0.1.27 | |

## Added on top of the generator

| Library | Locked | Why |
|---|---|---|
| dotenv | 3.2.0 | Loads `.env` (written by `bin/setup`) in development and test, so Rails and docker compose read the same database port. |

## Audit exceptions

| Advisory | Package | Why it is ignored |
|---|---|---|
| [GHSA-vfj7-8cjw-p6xm](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm) | braces 3.0.3 | No patched version. Reached only through `@vue/eslint-config-typescript`, and it only expands globs written in this repo. |
