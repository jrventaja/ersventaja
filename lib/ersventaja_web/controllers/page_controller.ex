defmodule ErsventajaWeb.PageController do
  use ErsventajaWeb, :controller

  # Serve index.html for all non-API routes (SPA fallback)
  # This allows Angular app to handle client-side routing
  def index(conn, _params) do
    html_file = Application.app_dir(:ersventaja, "priv/static/html/index.html")

    if File.exists?(html_file) do
      html_content = File.read!(html_file)

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, html_content)
    else
      # Fallback if file doesn't exist
      conn
      |> put_status(404)
      |> text(
        "Angular app files not found. Please ensure html/ directory is mounted to priv/static/html"
      )
    end
  end
end
