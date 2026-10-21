# Security policy

## Supported versions

Only the latest `main` is supported. Fixes land there and in the next release; there are no backports.

An app created from this template is its own project from the first commit. Fixes here reach it only when its owner ports them, so watch the releases and [CHANGELOG.md](CHANGELOG.md).

## Reporting a vulnerability

Report vulnerabilities privately through GitHub Security Advisories: open the [Security tab](https://github.com/crow-rojas/rails-vue-starter/security) and click **Report a vulnerability**. Don't open a public issue. You'll get an answer as soon as possible, and credit in the fix if you want it.

## Scope

Reports about the template's own code and defaults are in scope, for example:

- Authentication: sign in, sign up, sessions, password reset, email verification and their rate limits.
- Authorization: a user reaching another user's records, or a non-admin reaching `/admin/errors` or `/admin/jobs`.
- The content security policy, security headers, CSRF handling and cookie flags.
- The production configuration in `config/` and the deploy files (`config/deploy.yml`, `.kamal/secrets`, `script/backup_drill.sh`), including anything that could leak a secret or a backup.
- The agent harness letting an agent read secrets it is denied or push to `main` without checks.

Vulnerabilities in Rails, Inertia, Vue or another dependency belong to that project; report them upstream. Reports that need an attacker who already runs code on your server or has your deploy secrets are out of scope.
