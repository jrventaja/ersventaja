FROM bitwalker/alpine-elixir-phoenix:1.14

# Install additional build dependencies needed for native compilation
# idna requires these for native compilation via rebar3
RUN apk add --no-cache --update \
    gcc \
    g++ \
    make \
    libc-dev \
    erlang-dev \
    git \
    curl \
    && rm -rf /var/cache/apk/*

# Install rebar3 if not already available
# The bitwalker image should have it, but ensure it's accessible
RUN which rebar3 || (curl -L https://github.com/erlang/rebar3/releases/latest/download/rebar3 -o /usr/local/bin/rebar3 && \
    chmod +x /usr/local/bin/rebar3)

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
RUN mix deps.get --only ${MIX_ENV} && \
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