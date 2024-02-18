defmodule ErsventajaWeb.Router do
  alias ErsventajaWeb.PolicyController
  alias ErsventajaWeb.InsurerController
  alias ErsventajaWeb.AuthenticationController
  use ErsventajaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ErsventajaWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: ErsventajaWeb.ApiSpec)
  end

  pipeline :auth do
    plug(Ersventaja.UserManager.Pipeline)
  end

  scope "/", ErsventajaWeb do
    pipe_through(:browser)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ErsventajaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ErsventajaWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end

    get("/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi")
  end

  scope "/api" do
    pipe_through(:api)

    post("/login", AuthenticationController, :login)
    get("/openapi", OpenApiSpex.Plug.RenderSpec, [])

    scope "/" do
      pipe_through(:auth)
      post("/insurers", InsurerController, :create)
      get("/insurers", InsurerController, :list)
      post("/policies", PolicyController, :create)
      put("/policies/:id", PolicyController, :update_status)
      get("/policies/last-30-days", PolicyController, :last_30_days)
      get("/policies", PolicyController, :get_policies)
      delete("/policies/:id", PolicyController, :delete)
    end
  end
end
