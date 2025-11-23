FROM bitwalker/alpine-elixir-phoenix:1.14

# Install additional build dependencies needed for native compilation
RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    libc-dev \
    erlang-dev \
    && rm -rf /var/cache/apk/*

# Set Erlang flags to reduce memory usage during compilation
# This helps prevent OOM when compiling native dependencies
ENV ERL_FLAGS="+S 2:2 +A 8"

WORKDIR /app

# Install Hex and Rebar
RUN mix do local.hex --force, local.rebar --force

# Copy dependency files
COPY mix.exs .
COPY mix.lock .

# Set build argument for MIX_ENV
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

# Fetch and compile dependencies
# Compile idna separately first to avoid OOM issues
RUN mix deps.get --only ${MIX_ENV} && \
    (mix deps.compile idna || \
     (echo "=== idna compilation failed, trying with reduced parallelism ===" && \
      ERL_FLAGS="+S 1:1 +A 4" mix deps.compile idna)) && \
    mix deps.compile

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