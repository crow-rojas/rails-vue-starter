# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t rails-vue-starter .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name rails-vue-starter rails-vue-starter

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Set to "true" to build and ship the SSR runtime; flip and rebuild to toggle.
ARG SSR_ENABLED=false

# Base images are pinned by tag and digest, so a rebuild gets the same bytes; Dependabot bumps both.
# Keep the versions in step with .node-version and .ruby-version.
FROM docker.io/library/node:26.11.1-trixie-slim@sha256:193fe51b64e77981119c98c2002c9e32a70e2f006fb4d25068ce0558998917f0 AS node

FROM docker.io/library/ruby:4.0.7-slim@sha256:6c6b7b8c7d750604178aa60c2fa436890cd17c5695bdbd3213db2e4efbf98eb9 AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Node.js and corepack from the official image (needed for builds; node is kept in runtime for SSR)
COPY --from=node /usr/local/bin/node /usr/local/node/bin/node
COPY --from=node /usr/local/lib/node_modules/corepack /usr/local/node/lib/node_modules/corepack
RUN ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/node/bin/corepack
ENV PATH=/usr/local/node/bin:$PATH

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Install node modules
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Build SSR bundle when SSR_ENABLED=true, then discard node_modules
ARG SSR_ENABLED
RUN if [ "$SSR_ENABLED" = "true" ]; then pnpm exec vite build --ssr; fi && \
    rm -rf node_modules

# Branch: SSR enabled — ship the JS runtime alongside the app
FROM base AS branch-ssr-true
COPY --from=build /usr/local/node /usr/local/node
ENV PATH=/usr/local/node/bin:$PATH

# Branch: SSR disabled — base only, no JS runtime
FROM base AS branch-ssr-false

# Final stage for app image: picks the right branch by SSR_ENABLED
FROM branch-ssr-${SSR_ENABLED} AS final

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
