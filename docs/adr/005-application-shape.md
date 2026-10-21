# ADR-005: Application shape

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

Agents copy what they find. A codebase with three ways to do the same thing gets a fourth, so there has to be one shape, visible in working code and checked by tools where possible. Projects (`ProjectsController` and its pages, models, serializers and tests) is that working code.

## Decision

**Vanilla Rails first.** Business rules live in models: validations, normalization, associations, scopes and methods named after what the business calls them. Concerns hold behavior several models share. Controllers stay thin: load through a scope, call the model, redirect or render.

**Authorization is scoping.** Every query for user-owned records starts from `Current.user` (`Current.user.projects.find(id)`), so another user's record is a 404, never a 403 that confirms it exists. A test covers the other-user case for every resource. Add Action Policy when the app gets roles or shared records.

**Database constraints mirror validations.** Every `presence` has a `NOT NULL`, every `uniqueness` a unique index, every length a column limit, every association a foreign key. `database_consistency` checks it, and a model test proves the constraint holds without the validation.

**Props are serialized and typed.** Each page gets a `<Controller><Action>Serializer` (Alba), which `alba-inertia` finds by convention and Typelizer turns into a TypeScript type; the page declares `defineProps<ProjectsShow>()` with that type, never a hand-written interface. Links and form actions use the generated route helpers from `@/routes`, never path strings.

**Forms** are Inertia `<Form>` components posting flat fields; the controller permits them and redirects back with `inertia: { errors: record.errors }` on failure. Shared form markup lives in `app/javascript/components/<resource>/`, because everything under `pages/` is a page.

**Tests, per resource**: a model test (rules and the database constraint), an integration test (each action, the error path, the other-user 404, the guest redirect) and one system test for the main flow.

## When to add a layer, and not before

| Layer | Add when | Shape |
|---|---|---|
| Operation | One user action writes several models and must succeed or fail as a whole. | `app/models/<domain>/<verb>.rb`, a class with `.call(**)` that wraps its work in `transaction` and raises on failure; the controller calls it like a model method. |
| Form object | A form does not map onto one model. | `ActiveModel::Model` with its own validations, in `app/models/`. |
| Query object | A query is reused in several places and is more than a scope. | A scope first; a class only when a scope cannot express it. |

The reference has none of these because it does not need them; an agent that adds one without the reason in its row is only adding indirection.

## Consequences

- A new resource is a copy of projects with names changed, plus its own rules.
- No service objects by default: a `ProjectService` next to `Project` would be a second home for the same rules.
