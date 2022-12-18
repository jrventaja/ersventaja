import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ersventaja, Ersventaja.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ersventaja_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ersventaja, ErsventajaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "u1GAZjYZl1nBmI6qfWuNy2uAT6xQ/JI6FhYWD1rYVLpOQn0Uj1Xz39/3AxtwTWyX",
  server: false

# In test we don't send emails.
config :ersventaja, Ersventaja.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
