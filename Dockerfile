FROM bitwalker/alpine-elixir-phoenix:1.14

# Set locale to UTF-8 to avoid compilation issues
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install additional build dependencies needed for native compilation
# idna requires these for native compilation via rebar3
RUN apk add --no-cache --update \
    build-base \
    gcc \
    g++ \
    make \
    libc-dev \
    erlang-dev \
    git \
    curl \
    ncurses-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Install Hex and Rebar
RUN mix do local.hex --force, local.rebar --force

# Ensure rebar3 is available
# The bitwalker image should have rebar3 at /opt/mix/elixir/1-14/rebar3
# Make sure it exists and is executable, or install it
RUN if [ -f /opt/mix/elixir/1-14/rebar3 ]; then \
    chmod +x /opt/mix/elixir/1-14/rebar3 && \
    /opt/mix/elixir/1-14/rebar3 --version || echo "rebar3 at expected location failed"; \
    elif ! command -v rebar3 &> /dev/null; then \
    curl -L https://github.com/erlang/rebar3/releases/latest/download/rebar3 -o /opt/mix/elixir/1-14/rebar3 && \
    chmod +x /opt/mix/elixir/1-14/rebar3; \
    fi && \
    echo "rebar3 check:" && \
    (rebar3 --version || /opt/mix/elixir/1-14/rebar3 --version || echo "rebar3 not found")

# Copy dependency files
COPY mix.exs .
COPY mix.lock .

# Set build argument for MIX_ENV
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

# Set Erlang flags to help with compilation
ENV ERL_FLAGS="+JPperf true"

# Fetch and compile dependencies
# Clean any existing builds to ensure fresh compilation
RUN mix deps.clean --all || true && \
    mix deps.get --only ${MIX_ENV} && \
    echo "=== Verifying rebar3 ===" && \
    ls -la /opt/mix/elixir/1-14/rebar3* && \
    /opt/mix/elixir/1-14/rebar3 --version && \
    echo "=== Creating necessary paths ===" && \
    mkdir -p /app/_build/${MIX_ENV}/lib && \
    echo "=== Compiling all dependencies ===" && \
    mix deps.compile && \
    echo "=== Verifying idna was compiled successfully ===" && \
    test -f _build/${MIX_ENV}/deps/idna/ebin/idna.app || \
    (echo "=== idna compilation failed, trying manual compilation ===" && \
     cd _build/${MIX_ENV}/deps/idna && \
     echo "=== Running rebar3 bare compile ===" && \
     /opt/mix/elixir/1-14/rebar3 bare compile --paths /app/_build/${MIX_ENV}/lib/*/ebin && \
     cd /app && \
     test -f _build/${MIX_ENV}/deps/idna/ebin/idna.app || \
     (echo "=== Manual compilation also failed ===" && \
      echo "=== idna directory contents ===" && \
      ls -la _build/${MIX_ENV}/deps/idna/ && \
      echo "=== Trying regular rebar3 compile ===" && \
      cd _build/${MIX_ENV}/deps/idna && \
      /opt/mix/elixir/1-14/rebar3 compile && \
      cd /app && \
      test -f _build/${MIX_ENV}/deps/idna/ebin/idna.app || exit 1)) && \
    echo "=== All dependencies compiled successfully ==="

# Copy application code
COPY . .

# Verify dependencies are compiled before compiling application
RUN echo "=== Verifying dependencies are compiled ===" && \
    ls -la _build/${MIX_ENV}/deps/idna/ebin/ 2>/dev/null && \
    echo "=== Dependencies verified, compiling application ===" && \
    mix compile

# Build assets (if needed)
RUN mix assets.deploy || true

# Expose port
EXPOSE 4000

# Use exec form for better signal handling
CMD ["mix", "phx.server"]