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
    ls -la /opt/mix/elixir/1-14/rebar3* || echo "rebar3 not at expected path" && \
    /opt/mix/elixir/1-14/rebar3 --version || echo "rebar3 version check failed" && \
    echo "=== Creating necessary paths ===" && \
    mkdir -p /app/_build/${MIX_ENV}/lib && \
    echo "=== Compiling dependencies ===" && \
    mix deps.compile 2>&1 | tee /tmp/deps_compile.log || \
    (echo "=== Full compilation output ===" && \
     tail -100 /tmp/deps_compile.log 2>/dev/null || echo "No log file" && \
     echo "=== Trying to compile idna manually with detailed output ===" && \
     if [ -d "_build/${MIX_ENV}/deps/idna" ]; then \
       cd _build/${MIX_ENV}/deps/idna && \
       echo "=== Directory: $(pwd) ===" && \
       echo "=== Contents ===" && \
       ls -la && \
       echo "=== rebar.config ===" && \
       cat rebar.config 2>/dev/null || echo "No rebar.config" && \
       echo "=== rebar.lock ===" && \
       cat rebar.lock 2>/dev/null || echo "No rebar.lock" && \
       echo "=== Trying rebar3 bare compile with exact command mix uses ===" && \
       /opt/mix/elixir/1-14/rebar3 bare compile --paths /app/_build/${MIX_ENV}/lib/*/ebin 2>&1 && \
       echo "=== bare compile succeeded ===" || \
       (echo "=== bare compile failed, trying regular compile ===" && \
        /opt/mix/elixir/1-14/rebar3 compile 2>&1 && \
        echo "=== regular compile succeeded ===" || \
        (echo "=== Both compile methods failed ===" && \
         echo "=== Checking if paths exist ===" && \
         ls -la /app/_build/${MIX_ENV}/lib/ 2>/dev/null || echo "lib directory does not exist" && \
         exit 1)); \
     else \
       echo "=== idna directory not found ===" && \
       find _build -name idna -type d 2>/dev/null && \
       exit 1; \
     fi && \
     cd /app && \
     echo "=== Retrying full compilation ===" && \
     mix deps.compile)

# Copy application code
COPY . .

# Compile the application
RUN mix compile

# Build assets (if needed)
RUN mix assets.deploy || true

# Expose port
EXPOSE 4000

# Use exec form for better signal handling
CMD ["mix", "phx.server"]