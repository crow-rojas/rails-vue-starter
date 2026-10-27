# Recipe: LLM features

The steps behind [ADR-008](../adr/008-llm-features.md). Step 1 comes first; take the others only when a feature needs them. Every snippet ran in a scratch copy of this app on 2026-10-21 (ruby_llm 2.1.1, mcp 1.7.0, neighbor 1.2.0, pgvector 0.8.7, @rails/actioncable 8.1.400) with RuboCop, ESLint, Prettier, the type check, i18n-tasks, Brakeman, database_consistency and the Rails tests passing. Not exercised there: a real provider call, the stream in a browser, and the image switch on a server.

Each new gem or package gets its row in `docs/research/versions.md` (rule 10).

## 1. A chat and its job

```sh
bundle add ruby_llm
bundle add minitest-mock --group test
bin/rails generate ruby_llm:install --skip-active-storage
```

Before migrating, give the generated `create_chats` migration its owner, then run `bin/rails db:migrate`:

```ruby
t.references :user, null: false, foreign_key: true
```

Replace the generated initializer. Check a model id with `RubyLLM.models.find("claude-sonnet-5-5", provider: :anthropic)` before using it.

```ruby
# config/initializers/ruby_llm.rb
RubyLLM.configure do |config|
  # Production gets the key from Kamal; tests set their own in test_helper.rb.
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  config.default_model = "claude-sonnet-5-5"
end
```

The key goes in `.env` for development and through Kamal for production (ADR-006):

```yaml
# config/deploy.yml
env:
  secret:
    - ANTHROPIC_API_KEY
```

```sh
# .kamal/secrets
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
```

The models. The cap lives in `User`, the enqueue in `Chat`:

```ruby
# app/models/user.rb
has_many :chats, dependent: :destroy
has_many :ruby_llm_usages, as: :owner, class_name: "RubyLLM::ActiveRecord::Usage", dependent: :nullify

DAILY_LLM_TOKENS = 200_000

def llm_budget_left?
  ruby_llm_usages.where(created_at: Time.current.all_day)
    .sum(Arel.sql("coalesce(input_tokens, 0) + coalesce(output_tokens, 0)")) < DAILY_LLM_TOKENS
end
```

```ruby
# app/models/chat.rb
class Chat < ApplicationRecord
  acts_as_chat

  belongs_to :user

  # acts_as_chat resolves the model before save; resolving it before validation lets presence be checked.
  before_validation :resolve_model
  validates :model, presence: true

  # Saves the user's message now; ChatReplyJob calls the provider, never the request.
  def submit(content)
    return false unless user.llm_budget_left?

    ask_later(content)
    ChatReplyJob.perform_later(self)
    true
  end
end
```

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  acts_as_message

  validates :role, presence: true
end
```

`database_consistency` then asks for one exclusion, which a human adds with `Guard-Override: harness` (ADR-008 explains why the key must stay):

```yaml
# .database_consistency.yml
Chat:
  model:
    # RubyLLM refreshes its registry by deleting rows and relies on this foreign key refusing
    # the delete for models a chat uses; a cascade would delete those chats.
    MissingDependentDestroyChecker:
      enabled: false
```

The job and the controllers. `ChatsShowSerializer` is `one :chat` and `has_many :messages`, with a `MessageSerializer` of `:id, :role, :content, :created_at`.

```ruby
# app/jobs/chat_reply_job.rb
class ChatReplyJob < ApplicationJob
  def perform(chat)
    RubyLLM.with_usage_owner(chat.user) { chat.complete }
  end
end
```

```ruby
# config/routes.rb
resources :chats, only: %i[show create] do
  resources :messages, only: :create
end
```

```ruby
# app/controllers/chats_controller.rb
class ChatsController < InertiaController
  def show
    @chat = Current.user.chats.find(params.expect(:id))
    @messages = @chat.messages.where(role: %w[user assistant])
  end

  def create
    redirect_to Current.user.chats.create!
  end
end
```

```ruby
# app/controllers/messages_controller.rb
class MessagesController < InertiaController
  # Per user, not per IP: every call costs money, and many users can share one IP.
  rate_limit to: 10, within: 1.minute, by: -> { Current.user.id }, only: :create,
    with: -> { redirect_back_or_to root_path, alert: t("errors.rate_limited") }

  def create
    chat = Current.user.chats.find(params.expect(:chat_id))

    if chat.submit(params.expect(:content))
      redirect_to chat
    else
      redirect_to chat, alert: t("chats.budget_exhausted")
    end
  end
end
```

Without streaming, the page polls with `usePoll(2000, { only: ["messages"] })` while the last message is the user's; step 2 gives the streaming page.

Tests. A registry fixture keeps RubyLLM from loading its whole catalog in every test, which prosopite would also fail as an N+1:

```ruby
# test/test_helper.rb, after Prosopite.raise
# Tests stub the provider; a call that escapes a stub fails at once instead of reaching the network.
RubyLLM.configure do |config|
  config.anthropic_api_key = "test"
  config.anthropic_api_base = "http://127.0.0.1:9"
  config.max_retries = 0
end
```

```yaml
# test/fixtures/ruby_llm_models.yml
_fixture:
  model_class: RubyLLM::ActiveRecord::Model

sonnet:
  model_id: claude-sonnet-5-5
  name: Claude Sonnet 5.5
  provider: anthropic
```

```yaml
# test/fixtures/chats.yml
one:
  user: one
  model: sonnet

two:
  user: two
  model: sonnet
```

```ruby
# test/controllers/messages_controller_test.rb
setup { sign_in users(:one) }

test "saves the message and replies in a job" do
  assert_enqueued_with(job: ChatReplyJob, args: [ chats(:one) ]) do
    post chat_messages_path(chats(:one)), params: { content: "Hello" }
  end
  assert_equal "Hello", chats(:one).messages.last.content
end

test "stops at the daily token cap" do
  chats(:one).ruby_llm_usages.create!(owner: users(:one), operation: "chat", provider: "anthropic",
    model: "claude-sonnet-5-5", status: "succeeded", input_tokens: User::DAILY_LLM_TOKENS)

  assert_no_enqueued_jobs { post chat_messages_path(chats(:one)), params: { content: "Hello" } }
  assert_equal I18n.t("chats.budget_exhausted"), flash[:alert]
end

test "another user's chat is not found" do
  post chat_messages_path(chats(:two)), params: { content: "Hello" }

  assert_response :not_found
end
```

## 2. Streaming

```sh
pnpm add @rails/actioncable
pnpm add -D @types/rails__actioncable
```

`acts_as_chat` makes a chat `Enumerable`, so `ChatChannel.broadcast_to(chat, ...)` would iterate its messages. Name the stream instead:

```ruby
# app/models/chat.rb
def stream_name = "chat_#{id}"
```

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = Session.find_active(cookies.signed[:session_token])&.user || reject_unauthorized_connection
    end
  end
end
```

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Scoped like a controller: another user's chat is rejected.
  def subscribed
    chat = current_user.chats.find_by(id: params[:id])
    chat ? stream_from(chat.stream_name) : reject
  end
end
```

```ruby
# app/jobs/chat_reply_job.rb
def perform(chat)
  RubyLLM.with_usage_owner(chat.user) do
    chat.complete { |chunk| ActionCable.server.broadcast(chat.stream_name, { content: chunk.content }) if chunk.content }
  end
ensure
  # The page reloads the saved messages, so the serializer stays the source of truth.
  ActionCable.server.broadcast(chat.stream_name, { done: true })
end
```

Production broadcasts through Solid Cable (`config/cable.yml`), so the job and Puma need not share a process. Development uses the async adapter, which works because development jobs run in the Puma process too. `/cable` is same-origin, so the CSP's `connect-src 'self'` covers it.

```ts
// app/javascript/composables/useChatStream.ts
import { router } from "@inertiajs/vue3"
import { type Subscription, createConsumer } from "@rails/actioncable"
import { onMounted, onUnmounted, ref } from "vue"

const consumer = createConsumer()

// Shows the reply while ChatReplyJob streams it, then reloads the saved messages:
// the serializer stays the source of truth, and chunks that arrived out of order are replaced.
export function useChatStream(chatId: number) {
  const draft = ref("")
  let subscription: Subscription | undefined

  onMounted(() => {
    subscription = consumer.subscriptions.create(
      { channel: "ChatChannel", id: chatId },
      {
        received(data: { content?: string; done?: boolean }) {
          if (data.content) draft.value += data.content
          if (data.done) {
            router.reload({
              only: ["messages"],
              onFinish: () => (draft.value = ""),
            })
          }
        },
      },
    )
  })

  onUnmounted(() => subscription?.unsubscribe())

  return { draft }
}
```

```vue
<!-- app/javascript/pages/chats/show.vue -->
<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useChatStream } from "@/composables/useChatStream"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import { messages as messagesRoutes } from "@/routes"
import type { ChatsShow } from "@/types"

const props = defineProps<ChatsShow>()

const { t } = useI18n()
const { draft } = useChatStream(props.chat.id)
</script>

<template>
  <Head :title="t('ui.chats.show.title')" />

  <AppLayout>
    <div class="flex flex-col gap-4 p-4">
      <ol class="flex flex-col gap-2">
        <li v-for="message in messages" :key="message.id">
          {{ message.content }}
        </li>
        <li v-if="draft">{{ draft }}</li>
      </ol>

      <Form
        :action="messagesRoutes.create(chat.id)"
        resetOnSuccess
        class="flex gap-2"
        #default="{ processing }"
      >
        <Input
          name="content"
          required
          :aria-label="t('ui.chats.show.message')"
        />
        <Button :disabled="processing">{{ t("ui.chats.show.send") }}</Button>
      </Form>
    </div>
  </AppLayout>
</template>
```

The copy goes in both locale files: `chats.budget_exhausted` and `ui.chats.show.{title,message,send}`, then `bundle exec i18n-tasks normalize`.

```ruby
# test/jobs/chat_reply_job_test.rb
class ChatReplyJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "streams the reply and then tells the page to reload" do
    chat = chats(:one)
    chunk = Data.define(:content).new(content: "Hi")

    # The provider boundary: bin/ci never calls a model.
    chat.stub(:complete, ->(&on_chunk) { on_chunk.call(chunk) }) do
      ChatReplyJob.perform_now(chat)
    end

    assert_broadcast_on chat.stream_name, content: "Hi"
    assert_broadcast_on chat.stream_name, done: true
  end
end
```

```ruby
# test/channels/chat_channel_test.rb
class ChatChannelTest < ActionCable::Channel::TestCase
  setup { stub_connection current_user: users(:one) }

  test "streams the user's own chat" do
    subscribe id: chats(:one).id

    assert_has_stream chats(:one).stream_name
  end

  test "rejects another user's chat" do
    subscribe id: chats(:two).id

    assert subscription.rejected?
  end
end
```

## 3. Evals

An evaluation runs the real model against a dataset and checks the structured answer in Ruby. It lives in `app/evals`, named after its class, with its dataset beside it:

```ruby
# app/schemas/triage_schema.rb
class TriageSchema < Schematist::Schema
  string :category, enum: %w[billing bug question]
end
```

```ruby
# app/evals/triage_evaluation.rb
class TriageEvaluation < RubyLLM::Evaluation
  evaluator false # Ruby assertions only: no grading model, so a run pays only for the calls under test.

  def perform(input)
    RubyLLM.chat.with_schema(TriageSchema).ask(input) # in an app, the model method under test
  end

  def assertions
    assert_equal expected_output, result.parsed["category"]
  end
end
```

```yaml
# app/evals/triage_evaluation.yml
cases:
  - name: refund
    inputs: I was charged twice this month.
    expected_output: billing
  - name: crash
    inputs: The export button shows a blank page.
    expected_output: bug
```

Run it with a key, never from `bin/ci`. `EVAL_REPETITIONS=5` runs each case five times, and the JSON report lands in `tmp/evaluations` with tokens and cost:

```sh
bin/rails "ruby_llm:eval[TriageEvaluation]"
```

## 4. Embeddings with pgvector

Use the `-trixie` tag: it carries the same Postgres build as `postgres:18.6` (18.6-1.pgdg13+2, Debian trixie). The plain `-pg18` tag is built on bookworm, whose older glibc makes Postgres warn of a collation version mismatch on the existing data, a sign that text indexes may need rebuilding.

```yaml
# docker-compose.yml, and the db accessory in config/deploy.yml
image: pgvector/pgvector:0.8.7-pg18-trixie
```

In production, test the backups before touching the database container. `kamal deploy` never changes an accessory, so the switch is a reboot, and the app loses its database for a few seconds:

```sh
bin/kamal backup && bin/kamal backup-drill   # stop here unless the drill reports your tables and users
bin/kamal accessory reboot db                # recreates the container on the new image; the data directory stays
bin/kamal deploy                             # runs the migrations below
bin/kamal backup && bin/kamal backup-drill   # the dumps now need the vector extension to restore
```

```sh
bundle add neighbor
bin/rails generate neighbor:vector   # enable_extension "vector"
```

```ruby
# db/migrate/..._add_embedding_to_documents.rb
class AddEmbeddingToDocuments < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :documents, :embedding, :vector, limit: 1536 # the embedding model's dimensions
    add_index :documents, :embedding, using: :hnsw, opclass: :vector_cosine_ops, algorithm: :concurrently
  end
end
```

```ruby
# app/models/document.rb
has_neighbors :embedding

def self.search(query)
  nearest_neighbors(:embedding, RubyLLM.embed(query).vectors, distance: "cosine").first(5)
end
```

Embed records in a job, never in a save callback (`RubyLLM.embed(content).vectors`). Search through the user's scope (`Current.user.documents.search(query)`), and run it in a job too when the query is slow enough to matter. The default embedding model, `text-embedding-3-small`, is OpenAI's: it needs `OPENAI_API_KEY` set like the Anthropic key, and its 1536 dimensions must match the column.

## 5. An MCP server

```sh
bundle add mcp
```

Tokens are per user, stored hashed, and revoked by destroying them. A random 32-character token needs no slow hash, so SHA-256 lets the lookup use an index. The migration is `create_table :api_tokens` with `t.references :user, null: false, foreign_key: true` and `t.string :token_digest, null: false, index: { unique: true }`, plus `has_many :api_tokens, dependent: :destroy` on `User`.

```ruby
# app/models/api_token.rb
# A personal token for the MCP endpoint. Only its SHA-256 is stored, so a database leak
# reveals no usable token; destroying the record revokes it.
class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true

  # Returns the plaintext once; it cannot be shown again.
  def self.issue(user)
    token = SecureRandom.base58(32)
    user.api_tokens.create!(token_digest: digest(token))
    token
  end

  def self.authenticate(token) = find_by(token_digest: digest(token))&.user

  def self.digest(token) = OpenSSL::Digest::SHA256.hexdigest(token)
end
```

Tools call the same model methods and scopes as the controllers; the user comes from `server_context`. A tool's name is its class name in snake case (`list_projects`).

```ruby
# app/mcp/list_projects.rb
class ListProjects < MCP::Tool
  description "Lists the user's projects"

  def self.call(server_context:)
    names = server_context[:user].projects.order(:name).pluck(:name)
    MCP::Tool::Response.new([ { type: "text", text: names.join("\n") } ])
  end
end
```

The endpoint builds a server per request, which is the SDK's controller pattern, so each request carries its own user. It is stateless, so no session outlives a request, a deploy or a Puma worker. It is an API controller: it has no cookies or CSRF, and Brakeman stays quiet. `limit_attempts` redirects, which an MCP client cannot follow, so the controller applies the same limit to wrong tokens (10 per 3 minutes per IP) and answers 429.

```ruby
# config/routes.rb
post "mcp", to: "mcp#create"
```

```ruby
# app/controllers/mcp_controller.rb
class McpController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # A wrong token is a failed secret check: limit those per IP, like limit_attempts, but with a 429.
  rate_limit to: 10, within: 3.minutes, name: "bad-token", unless: :user
  rate_limit to: 60, within: 1.minute, name: "per-user", by: -> { user.id }, if: :user
  before_action { head :unauthorized unless user }

  def create
    server = MCP::Server.new(name: "rails-vue-starter", version: "1.0.0", tools: [ ListProjects ], server_context: { user: })
    # Rails' host authorization has already checked request.host.
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      server, stateless: true, serve_subscriptions_listen: false, allowed_hosts: [ request.host ]
    )
    status, headers, body = transport.handle_request(request)
    # Copied as they are: the transport answers JSON or SSE depending on the client's protocol version.
    response.headers.merge!(headers)
    self.status = status
    self.response_body = body
  end

  private

  def user
    return @user if defined?(@user)

    @user = authenticate_with_http_token { |token| ApiToken.authenticate(token) }
  end
end
```

The SDK's docs end with `render(json: body.first, status:, headers:)`, but Rails' `render` has no `headers:` option, so an SSE answer would go out labeled as JSON. The users' page for issuing and revoking tokens is an ordinary resource, scoped through `Current.user.api_tokens`.

```ruby
# test/controllers/mcp_controller_test.rb
test "calls a tool as the token's user" do
  call_tool ApiToken.issue(users(:one)), "list_projects"

  assert_equal "Product launch\nWebsite redesign", response.parsed_body.dig("result", "content", 0, "text")
end

test "rejects a revoked token" do
  token = ApiToken.issue(users(:one))
  users(:one).api_tokens.destroy_all
  call_tool token, "list_projects"

  assert_response :unauthorized
end

test "limits wrong tokens per IP" do
  11.times { call_tool "wrong", "list_projects" }

  assert_response :too_many_requests
end

private

def call_tool(token, name)
  post mcp_path, as: :json,
    params: { jsonrpc: "2.0", id: 1, method: "tools/call", params: { name:, arguments: {} } },
    headers: { "Authorization" => "Bearer #{token}", "Accept" => "application/json, text/event-stream" }
end
```
