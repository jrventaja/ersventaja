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

# Fetch dependencies
RUN mix deps.clean --all || true && \
    mix deps.get --only ${MIX_ENV}

# Verify rebar3 is available
RUN echo "=== Verifying rebar3 ===" && \
    ls -la /opt/mix/elixir/1-14/rebar3* && \
    /opt/mix/elixir/1-14/rebar3 --version

# Create necessary paths
RUN mkdir -p /app/_build/${MIX_ENV}/lib

# Check what dependencies were fetched
RUN echo "=== Checking fetched dependencies ===" && \
    ls -la deps/ 2>/dev/null | head -20 || echo "deps directory does not exist" && \
    echo "=== Checking _build deps ===" && \
    ls -la _build/${MIX_ENV}/deps/ 2>/dev/null | head -20 || echo "_build deps directory does not exist"

# Try to compile dependencies - capture full output
RUN echo "=== Compiling dependencies ===" && \
    mix deps.compile 2>&1 | tee /tmp/deps_compile.log; \
    COMPILE_EXIT=$?; \
    if [ $COMPILE_EXIT -ne 0 ]; then \
      echo "=== mix deps.compile failed with exit code $COMPILE_EXIT ===" && \
      echo "=== Full output: ===" && \
      cat /tmp/deps_compile.log && \
      echo "" && \
      echo "=== Checking what deps directories exist ===" && \
      ls -la _build/${MIX_ENV}/deps/ 2>/dev/null || echo "No deps in _build" && \
      echo "" && \
      echo "=== Looking for idna ===" && \
      find _build -name idna -type d 2>/dev/null || echo "idna not found" && \
      if [ -d "_build/${MIX_ENV}/deps/idna" ]; then \
        echo "=== idna directory found, attempting manual compilation ===" && \
        cd _build/${MIX_ENV}/deps/idna && \
        echo "=== idna directory: $(pwd) ===" && \
        echo "=== Contents: ===" && \
        ls -la && \
        echo "" && \
        echo "=== rebar.config: ===" && \
        cat rebar.config 2>/dev/null || echo "No rebar.config" && \
        echo "" && \
        echo "=== Running rebar3 bare compile (as mix does) ===" && \
        /opt/mix/elixir/1-14/rebar3 bare compile --paths /app/_build/${MIX_ENV}/lib/*/ebin -v 2>&1 | tee /tmp/rebar3_bare.log || \
        (echo "=== bare compile failed, output: ===" && \
         cat /tmp/rebar3_bare.log && \
         echo "" && \
         echo "=== Trying regular rebar3 compile ===" && \
         /opt/mix/elixir/1-14/rebar3 compile -v 2>&1 | tee /tmp/rebar3_regular.log || \
         (echo "=== regular compile also failed, output: ===" && \
          cat /tmp/rebar3_regular.log)); \
        cd /app; \
      else \
        echo "=== idna directory not found - deps.get may have failed ==="; \
      fi && \
      exit $COMPILE_EXIT; \
    fi

# Verify idna compiled successfully and show details if it didn't
RUN if [ -f _build/${MIX_ENV}/deps/idna/ebin/idna.app ]; then \
      echo "=== idna compiled successfully ==="; \
    else \
      echo "=== ERROR: idna.app not found ===" && \
      echo "=== Checking idna directory structure ===" && \
      ls -la _build/${MIX_ENV}/deps/idna/ 2>/dev/null || echo "idna directory does not exist" && \
      echo "=== Checking for ebin directory ===" && \
      ls -la _build/${MIX_ENV}/deps/idna/ebin/ 2>/dev/null || echo "ebin directory does not exist" && \
      echo "=== Checking for any compiled files ===" && \
      find _build/${MIX_ENV}/deps/idna -name "*.beam" -o -name "*.app" 2>/dev/null || echo "No compiled files found" && \
      exit 1; \
    fi

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