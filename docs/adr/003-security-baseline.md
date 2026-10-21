# ADR-003: Security baseline

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

The generated authentication was solid at its core: tokens that expire, sessions dropped on a password change, history cleared on sign out, and Inertia history encryption in production. Around it, several defaults were missing: no rate limiting at all, a password reset form that told anyone whether an email had an account, production without SSL, no content security policy, and a raw 422 modal on an expired form.

## Decision

- **Rate limiting**: `ApplicationController.limit_attempts` (10 requests per 3 minutes per IP, then a redirect with an alert) on sign in, sign up, password reset requests and verification resends. Any new endpoint that sends email or checks a secret uses it.
- **No account enumeration**: password reset requests get one answer for every email.
- **SSL**: `assume_ssl` and `force_ssl` in production, with `/up` excluded for the health check.
- **Content security policy**, enforced in every environment: scripts only from the app or the running Vite dev server, a per-request nonce for inline scripts, no objects, no framing, no foreign form targets. Styles allow `unsafe-inline` because Vue and reka-ui write style attributes.
- **Permissions-Policy** as a static header that turns off camera, microphone, geolocation, USB, payment and gyroscope. Rails' `permissions_policy` is not used: it still emits the legacy `Feature-Policy` header.
- **CSRF**: an expired token redirects back with an alert instead of a 422.
- **Dependencies**: Dependabot with a 7-day cooldown and grouped minor and patch updates, on top of the gem cooldown and pnpm's policies (ADR-001).

## Not included, and when to add it

| Item | Add when |
|---|---|
| Active Record encryption | A model stores personal or secret data. Its keys live in the production credentials, created with the Kamal setup. |
| Two-factor authentication, passkeys | The app holds data worth the extra step; Rodauth covers both. |
| Breached-password check (`pwned`) | Sign up is public at scale; it calls an external API on every sign up. |
| rack-attack | A global throttle or blocklist is needed beyond per-action limits. |

## Triggers that reopen this ADR

| Topic | Reopens when |
|---|---|
| Dependabot | It fails to update the pnpm 12 lockfile; Renovate supports pnpm's release-age settings natively. |
| CSP styles | Vue and the component library stop needing style attributes, so `unsafe-inline` can go. |
