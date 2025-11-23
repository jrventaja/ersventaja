defmodule ErsventajaWeb.LayoutView do
  use Phoenix.Component
  use Phoenix.HTML
  alias ErsventajaWeb.Router.Helpers, as: Routes

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def root(assigns) do
    conn_or_socket = assigns[:conn] || assigns[:socket] || assigns.socket
    page_title = assigns[:page_title] || Map.get(assigns, :page_title, "RS Ventaja")

    assigns = assign(assigns, :conn_or_socket, conn_or_socket)
    assigns = assign(assigns, :page_title, page_title)

    ~H"""
    <!DOCTYPE html>
    <html lang="pt-BR">
      <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="csrf-token" content={csrf_token_value()}>
        <.live_title suffix=" · Corretora de Seguros"><%= @page_title %></.live_title>

        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Google Fonts - Playfair Display (Classic Serif) -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;1,400&display=swap" rel="stylesheet">

        <!-- FontAwesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

        <!-- App assets -->
        <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn_or_socket, "/assets/app.css")}/>
        <script defer phx-track-static type="text/javascript" src={Routes.static_path(@conn_or_socket, "/assets/app.js")}></script>
        <script>
          document.addEventListener("DOMContentLoaded", function() {
            document.body.addEventListener("change", function(e) {
              if (e.target.type === "file" && e.target.files && e.target.files.length > 0) {
                const view = document.querySelector("[data-phx-main]")?.__view;
                if (view) {
                  view.pushEvent("file_selected", {});
                }
              }
            });
          });
        </script>

        <style>
          html { width: 100%; }
          body { margin: 0; padding: 0; width: 100%; max-width: 100%; overflow-x: hidden; }
          * { box-sizing: border-box; }
        </style>
      </head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  def live(assigns) do
    ~H"""
    <main style="width: 100%; max-width: 100%; margin: 0; padding: 0;">
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info"><%= live_flash(@flash, :info) %></p>

      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error"><%= live_flash(@flash, :error) %></p>

      <%= @inner_content %>
    </main>
    """
  end
end
