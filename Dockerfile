# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t armstrong_quiz .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name armstrong_quiz armstrong_quiz

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Build Tailwind CSS + daisyUI here (yarn build:css is NOT run in Rails stage — this replaces it)
FROM docker.io/library/node:20-slim AS tailwind
WORKDIR /app
COPY package.json yarn.lock ./
RUN corepack enable && yarn install && npm install @tailwindcss/cli
COPY app/assets/tailwind app/assets/tailwind
COPY app/views app/views
RUN mkdir -p app/assets/builds && npx @tailwindcss/cli -i app/assets/tailwind/application.css -o app/assets/builds/tailwind.css

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock vendor ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Copy application code
COPY . .

# Prebuilt Tailwind CSS (so assets:precompile won't run yarn build:css)
COPY --from=tailwind /app/app/assets/builds/tailwind.css app/assets/builds/tailwind.css

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production (Tailwind already built; TAILWIND_SKIP_BUILD avoids yarn in this image)
RUN SECRET_KEY_BASE_DUMMY=1 TAILWIND_SKIP_BUILD=1 ./bin/rails assets:precompile && \
    test -f app/assets/builds/tailwind.css && \
    (ls public/assets/tailwind*.css 2>/dev/null | head -1) || (echo "ERROR: tailwind.css not in public/assets" && exit 1)




# Final stage for app image (no Node/yarn — Tailwind already in public/assets from build stage)
FROM base

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
