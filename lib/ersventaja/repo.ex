defmodule Ersventaja.Repo do
  use Ecto.Repo,
    otp_app: :ersventaja,
    adapter: Ecto.Adapters.Postgres
end
