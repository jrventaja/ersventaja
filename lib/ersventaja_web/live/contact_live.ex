defmodule ErsventajaWeb.ContactLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Navbar
  import ErsventajaWeb.Components.Hero

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      body { margin: 0; padding: 0; font-family: 'Playfair Display', Georgia, serif; color: #504f4f; }

      /* Content */
      .main-content { background-color: white; min-height: 100vh; }
      .section { padding: 4em 2em; text-align: center; }
      .section-title { font-size: 42px; font-weight: 400; letter-spacing: 2px; margin-bottom: 1.5em; color: #504f4f; }

      /* Contact */
      .contact-info { font-size: 18px; line-height: 2.5; max-width: 600px; margin: 0 auto; }
      .contact-info a { color: #666; text-decoration: none; }
      .contact-info a:hover { color: #2346ae; }
    </style>

    <.navbar />
    <.hero title="RS Ventaja" subtitle="Corretora de Seguros" />

    <div class="main-content">
      <section class="section">
        <h2 class="section-title">Contato</h2>
        <div class="contact-info">
          <p><strong>Roberto Ventaja</strong></p>
          <p style="color: grey;">Corretor de Seguros</p>
          <p>
            <a href="mailto:roberto@rsventaja.com">
              <i class="fas fa-envelope" style="margin-right: 0.5em;"></i>
              roberto@rsventaja.com
            </a>
          </p>
        </div>
      </section>
    </div>
    """
  end
end
