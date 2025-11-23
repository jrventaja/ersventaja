defmodule ErsventajaWeb.InsurersLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Navbar

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      body { margin: 0; padding: 0; font-family: 'Playfair Display', Georgia, serif; color: #504f4f; }

      /* Content */
      .main-content { padding-top: 50px; background-color: white; min-height: 100vh; }
      .section { padding: 4em 2em; text-align: center; }
      .section-title { font-size: 42px; font-weight: 400; letter-spacing: 2px; margin-bottom: 1.5em; color: #504f4f; }

      /* Insurers */
      .insurers-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 3em; margin: 3em auto; max-width: 900px; padding: 0 2em; }
      .insurer-box { text-align: center; display: flex; flex-direction: column; align-items: center; }
      .insurer-box img { width: 80px; height: 80px; object-fit: contain; border-radius: 10%; }
      .insurer-box p { margin-top: 1em; font-size: 16px; color: #504f4f; }
    </style>

    <.navbar />

    <div class="main-content">
      <section class="section">
        <h2 class="section-title">Seguradoras</h2>
        <div class="insurers-grid">
          <%= for insurer <- [
            %{name: "Porto Seguro", img: "porto.jpg", url: "https://www.portoseguro.com.br/"},
            %{name: "Unimed", img: "unimed.jpg", url: "https://www.segurosunimed.com.br/"},
            %{name: "Mapfre", img: "mapfre.png", url: "https://www.mapfre.com.br/"},
            %{name: "Azul", img: "azul.jpg", url: "https://www.azulseguros.com.br/"},
            %{name: "HDI", img: "hdi.jpg", url: "https://www.hdiseguros.com.br/"},
            %{name: "SulAmérica", img: "sulamerica.png", url: "https://portal.sulamericaseguros.com.br/"},
            %{name: "Itaú", img: "itau.png", url: "https://www.itau.com.br/seguros/"},
            %{name: "Tokio Marine", img: "tokiomarine.png", url: "https://www.tokiomarine.com.br/"},
            %{name: "Sompo", img: "sompo.png", url: "https://sompo.com.br/"}
          ] do %>
            <div class="insurer-box">
              <a href={insurer.url} target="_blank">
                <img alt={insurer.name} src={"/images/#{insurer.img}"} />
              </a>
              <p><%= insurer.name %></p>
            </div>
          <% end %>
        </div>
      </section>
    </div>
    """
  end
end
