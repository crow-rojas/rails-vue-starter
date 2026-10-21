# Contributing

Thanks for taking the time. This template tries to stay small: everything in it should be something most new apps need on day one, or a check that keeps agent-written code honest.

## Principles

- **Follow the official generator.** The base comes from [inertia-rails/generator](https://github.com/inertia-rails/generator). Changes that move away from it need a reason in an ADR.
- **Rules are checks.** A convention that matters gets a tool that enforces it, listed in `AGENTS.md`. A rule that only lives in prose will be broken.
- **Fast checks.** A commit takes about a second and `bin/check` about 13 seconds. A change that makes them much slower needs a good reason.
- **Fewer dependencies.** A new gem or package needs a reason and an official source in `docs/research/versions.md`. Gems wait 7 days after release and packages 1 day before the lockfiles accept them.
- **Less is more.** Before adding an option, ask whether someone needs it today. A smaller diff that solves the problem wins.

## Development

```sh
bin/setup          # install, start Postgres, prepare and seed, run the app
bin/check          # the fast check, about 13 s
bin/ci             # everything CI runs, about 40 s
```

Sign in locally as `demo@example.com` with the password `demo-password-123`. `AGENTS.md` lists the rest of the commands and where things live; read it even if you are not an agent.

## Code style

- RuboCop, ESLint and Prettier decide formatting, and the git hooks run them. Don't silence a check inline; fix the cause or propose a change to the rule.
- Code, docs, commits and pull requests are in English. User-facing copy goes in `config/locales/en.yml` and `es.yml` together, never in a template or controller.
- Comments explain why, never what. Code that reads on its own gets no comment.
- New resources follow the shape of `projects` ([ADR-005](docs/adr/005-application-shape.md)).

## Pull requests

1. One change per pull request, with the problem it solves. Commits follow [Conventional Commits](https://www.conventionalcommits.org) and are signed.
2. `bin/ci` passes.
3. Bug fixes start with a failing test.
4. UI changes include before and after screenshots taken with the demo account.
5. A change to a decision updates its ADR in the same pull request.

Changes to the harness itself (`bin/guard`, `config/ci.rb`, `lefthook.yml`, `.claude/`, the workflows and linter configs) fail `bin/guard` until the maintainer reviews them; say why in the description.

## Reporting a bug

Open an issue with what you expected, what happened, the steps to reproduce it, your OS, and `ruby -v`, `node -v` and `pnpm -v`. Include the relevant lines from `log/development.log` or the browser console, with any private data removed.

Security issues go through [SECURITY.md](SECURITY.md), not public issues.
