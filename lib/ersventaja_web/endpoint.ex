defmodule ErsventajaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ersventaja

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_ersventaja_key",
    signing_salt: "BQ5DAtAg"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :ersventaja,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
  )

  # Serve Angular app HTML files (when html/ is mounted to priv/static/html in production)
  # This serves all static assets (JS, CSS, images, etc.) from the Angular build
  if Application.compile_env(:ersventaja, :serve_html_files, false) do
    plug(Plug.Static,
      at: "/",
      from: {:ersventaja, "priv/static/html"},
      gzip: true
    )
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :ersventaja)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(CORSPlug)
  plug(ErsventajaWeb.Router)
end
