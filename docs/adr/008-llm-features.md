# ADR-008: LLM features

- Status: accepted
- Date: 2026-10-21
- Deciders: owner

## Context

The template ships no LLM feature, but apps built from it will add one, and an agent left to choose invents its own shape: a provider SDK called from a controller, a key in the credentials file, a bill nobody capped. This app makes the wrong shape expensive: Puma runs 3 threads (`config/puma.rb`) and Solid Queue runs inside Puma (`config/deploy.yml`), so one 30 s provider call in a request takes a third of the app's capacity. This ADR fixes the shape before the first feature; [`docs/recipes/llm.md`](../recipes/llm.md) has the steps and code.

## Decision

- Library: [RubyLLM](https://rubyllm.com/rails/) 2.x (`ruby_llm`), one API across providers with Active Record persistence, a usage ledger, structured output and evaluations. It enters the Gemfile with the first feature that needs it, not before (rule 10). The official `anthropic` or `openai` gem is the fallback for a provider-only feature RubyLLM does not cover.
- Records: `ruby_llm:install` generates `Chat` (`acts_as_chat`) and `Message` (`acts_as_message`), ordinary models under ADR-005: a chat `belongs_to :user`, is always loaded through `Current.user.chats`, and reaches pages through serializers. RubyLLM owns its `ruby_llm_*` tables.
- The provider call always runs in an Active Job, never in the request. The model saves the user's message (`ask_later`) and enqueues the job; the job calls `complete`.
- The key is an environment variable: a line under `env.secret` in `config/deploy.yml` plus one in `.kamal/secrets` (ADR-006), never the credentials file. Development reads it from `.env`.
- Cost: LLM endpoints are rate limited per user, not per IP (`rate_limit ... by: -> { Current.user.id }`), because every call costs money and one office shares an IP. Jobs call the provider inside `RubyLLM.with_usage_owner(user)`, so RubyLLM's ledger (`ruby_llm_usages`, one row per provider attempt, linked to its message) stores token usage per message and per user. A daily token cap is a `User` method, and `Chat` checks it before enqueuing.
- Tests stay offline: they stub the RubyLLM boundary (`chat.stub(:complete, ...)`, from `minitest-mock`, which Minitest 6 split out), and `test/test_helper.rb` points the provider at a closed port, so a call that escapes a stub fails instead of reaching the network.
- Evals are RubyLLM evaluations in `app/evals`, where its `ruby_llm:eval` task finds them, with `evaluator false` and Ruby assertions on structured output (`with_schema`, then `message.parsed`), so a run pays only for the calls under test. They run on demand, never in `bin/ci`: they need a key, cost money and are not deterministic.

## Add when

| Capability | Add when | Shape |
|---|---|---|
| Streaming | Replies take long enough that users watch them arrive. Until then the page reloads its messages with Inertia's `usePoll` while a reply is pending. | The job broadcasts chunks over Action Cable (Solid Cable in production); a `useChatStream` composable shows them and reloads the saved messages when the job ends. |
| Embeddings and pgvector | A feature searches by meaning rather than by words. | `pgvector/pgvector:<version>-pg18-trixie` in place of `postgres:18.6`, the `neighbor` gem, a `vector` column with an HNSW cosine index, embeddings computed in a job. |
| MCP server | Users want their own agents to read or change their data. | The official `mcp` gem behind a stateless endpoint at `/mcp`, tools that call the same model methods as the controllers, per-user hashed and revocable API tokens. |

## Alternatives not taken

- The `ruby_llm:chat_ui` generator: Turbo Streams and ERB views, a second frontend next to Inertia (ADR-005).
- Server-sent events as the default stream: each open stream holds one of Puma's 3 threads.
- A pgvector image in the template: its tags pin pgvector and the Postgres major, not the minor, which every app would pay for whether or not it searches by meaning.
- Third-party MCP gems: the official SDK is stable and follows the spec.
- langchainrb: another abstraction over the same calls; RubyLLM already covers chats, tools, embeddings and Rails persistence.
- `llms.txt`: it describes public content to crawlers, and an app behind sign-in has none.

## Consequences

- `database_consistency` flags the foreign key from `chats` to `ruby_llm_models`. It has to stay as it is: RubyLLM refreshes its registry by deleting rows and relies on that key refusing the delete for a model a chat uses, so a cascade would delete chats. The first feature adds this one exclusion to `.database_consistency.yml`, which needs a human's `Guard-Override: harness`.
- `acts_as_chat` makes a chat `Enumerable` over its messages, so Action Cable's `stream_for` and `broadcast_to` would iterate it; streams use a name built from the chat's id.
- Solid Queue has 3 worker threads (`config/queue.yml`), so a burst of chats delays email jobs.
- The ledger has a row per attempt, so the cap counts retries and cancelled streams too.

## Triggers that reopen this ADR

| Topic | Reopens when |
|---|---|
| Job queue | Chat jobs delay emails; give them their own queue and worker in `config/queue.yml`. |
| MCP authorization | Third-party clients need OAuth; the `mcp` gem's `MCP::Server::OAuth` (1.8+) makes `/mcp` a resource server. |
| Provider keys per user | Users bring their own keys; `RubyLLM.context` sets them per call. |
