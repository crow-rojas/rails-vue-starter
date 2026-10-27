# ADR-002: Agent harness

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

Agents write most of the code here, and nobody reads every line. Their typical failures are not syntax errors: they invent a prop or a route, silence a failing check, delete or skip the test that fails, edit a migration that already ran, write N+1 queries, and add packages that do not exist or were published hours ago. Rules written in prose stop none of that, but tools can, as long as they are fast enough that people and agents do not route around them.

## Decision

Every rule in `AGENTS.md` points to the tool that enforces it, and each tool runs at the cheapest moment that still catches the failure. The hooks give fast feedback, and anyone determined to can bypass them. The gate is GitHub: `main` is protected by the ruleset in `.github/rulesets/main.json` (required `ci` and `image` checks that apply to admins too, signed commits, linear history, no force pushes or deletion), which also disables GitHub's own merge buttons, so `bin/merge` is the only way in: a fast-forward of a pull request whose checks passed and whose commits GitHub verifies.

| Moment | What runs | Time |
|---|---|---|
| After each agent edit (`.claude/hooks/lint-edited-file`) | RuboCop, or ESLint then Prettier, on that file, autocorrecting; what is left goes back to the agent | about 1 s |
| `git commit` (lefthook) | The same linters on staged files, gitleaks on the staged diff, Conventional Commits and no AI co-author trailers | about 1 s |
| End of each agent turn (`.claude/hooks/check-on-stop`) | `bin/check`, skipped when the tree already passed; one retry, then the agent may stop | about 11 s |
| `git push` (lefthook) and GitHub Actions | `bin/ci`, the single list of checks in `config/ci.rb`; pushes to main are refused | about 40 s locally |

The sensors, grouped by the failure they catch:

- Invented props and routes: Typelizer types from the serializers and routes, checked by `vue-tsc`, plus a freshness check on the generated files.
- Silenced checks: RuboCop's `Style/DisableCopsWithinSourceCodeDirective`, ESLint's `noInlineConfig` and a full `ban-ts-comment`, and deny rules for `--no-verify`.
- Weakened tests, rewritten migrations and an edited harness: `bin/guard` compares the branch with its merge-base on main and fails closed if git does. Changing the harness itself (`bin/guard`, `config/ci.rb`, `lefthook.yml`, `.claude/`, `.codex/`, the workflows, the linter, type and test configs, the check wrappers (`bin/setup`, `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`, `bin/gitleaks`) and their allowlists, the guard's own test, and the `package.json` scripts) needs a human's `Guard-Override: harness` trailer. The test count is a heuristic: it sees deleted and skipped tests, not a test whose body was gutted.
- Bugs a style guide does not see: RuboCop's Lint, Rails and Performance departments, which the omakase config turns off.
- Database mistakes: strong_migrations with `safe_by_default`, prosopite raising on N+1 queries in every test, and database_consistency comparing validations with constraints.
- Supply chain: a 7-day gem cooldown, pnpm's 1-day minimum release age, unreviewed build scripts failing the install, `trustPolicy: no-downgrade`, the audits, Brakeman, and gitleaks over the whole history.
- Changes too large to review: a CI job that fails pull requests above 800 changed lines, lockfiles and generated types excluded, unless they carry the `large-pr` label.

## Alternatives not taken

- Separate GitHub Actions jobs per check, as generated: faster in parallel, but they drift from `bin/ci`.
- Sorbet or Steep: no evidence that Ruby types improve agent output; the boundary that matters, Rails to TypeScript, is already typed.
- Mutation testing, packwerk, AI code review bots, MCP servers: worth it for some apps, not as a default. They stay opt-in.
- commitlint: two grep lines in `lefthook.yml` do the same without a Node dependency.

## Consequences

- An agent cannot finish a turn with `bin/check` red without one visible retry, and cannot push with `bin/ci` red.
- A legitimate test removal or migration fix needs a human to add a `Guard-Override:` trailer, which stays in the history. A deny rule keeps Claude Code from typing the trailer; an agent that writes it through a message file is caught only in review.
- gitleaks falls back to its pinned Docker image when it is not installed.
- The checks have to stay fast. When `bin/check` passes 30 s, split the slow tests out or reopen this ADR.
