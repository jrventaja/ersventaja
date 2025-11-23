defmodule ErsventajaWeb.HomepageLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Navbar

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      /* Force full width for homepage */
      body { margin: 0 !important; padding: 0 !important; font-family: 'Playfair Display', Georgia, serif; color: #504f4f; width: 100% !important; max-width: 100% !important; }
      .homepage-wrapper { width: 100% !important; max-width: 100% !important; margin: 0 !important; padding: 0 !important; }
      .homepage-wrapper .container { max-width: 100% !important; width: 100% !important; padding: 0 !important; margin: 0 !important; }

      /* Hero */
      .hero-section { margin-top: 50px; height: 350px; width: 100% !important; max-width: 100% !important; background-color: rgb(39, 39, 39); display: flex; align-items: center; justify-content: center; position: relative; }

      /* Content */
      .main-content { background-color: white; width: 100% !important; max-width: 100% !important; }
      .section { padding: 3em 2em; text-align: center; width: 100% !important; max-width: 100% !important; }
      .section-title { font-size: 36px; font-weight: 400; letter-spacing: 2px; margin-bottom: 1.5em; font-family: 'Playfair Display', Georgia, serif; }
      .about-text { max-width: 70%; margin: 0 auto; font-size: 20px; line-height: 30px; letter-spacing: 1px; text-indent: 4em; font-family: 'Playfair Display', Georgia, serif; }

    </style>

    <div class="homepage-wrapper" style="width: 100%; max-width: 100%; margin: 0; padding: 0;">
      <.navbar />

      <!-- Hero Section -->
      <div class="hero-section">
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
          <img alt="RS Ventaja" src="/images/rs_logo_transparent.png" width="140" height="140" style="margin-bottom: 1.5em;" />
          <h1 style="font-size: 48px; margin: 0; font-weight: 400; color: white; letter-spacing: 2px; font-family: 'Playfair Display', Georgia, serif;">RS Ventaja</h1>
          <p style="font-size: 20px; font-style: italic; margin: 0.5em 0 0 0; color: white; font-family: 'Playfair Display', Georgia, serif;">Corretora de Seguros</p>
        </div>
      </div>

      <!-- Main Content -->
      <div class="main-content" style="width: 100%;">
        <!-- Quem somos -->
        <section class="section">
          <h2 class="section-title">Quem somos</h2>
          <p class="about-text">
            No mercado há 20 anos, trabalhamos com atenção especial às necessidades individuais do cliente. Temos orgulho em
            construir relações de confiança, possuindo clientes satisfeitos pelo nosso atendimento personalizado e bem
            amparados pelas coberturas que oferecemos.
          </p>
        </section>
      </div>
    </div>
    """
  end
end
