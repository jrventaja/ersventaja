FROM bitwalker/alpine-elixir-phoenix:1.14

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

ARG MIX_ENV

RUN mix do local.hex --force, local.rebar --force

CMD mix deps.get && mix phx.server