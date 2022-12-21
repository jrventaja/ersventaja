FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

ARG MIX_ENV

RUN mix do local.hex --force, local.rebar --force

CMD mix deps.get && mix phx.server