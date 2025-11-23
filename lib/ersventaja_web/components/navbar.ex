defmodule ErsventajaWeb.Components.Navbar do
  use Phoenix.Component

  def navbar(assigns) do
    ~H"""
    <style>
      /* Navigation */
      .fixed-nav { position: fixed; top: 0; left: 0; right: 0; width: 100%; z-index: 9999; background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%); height: 50px; display: flex; align-items: center; justify-content: center; font-family: 'Playfair Display', Georgia, serif; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
      .nav-link-item { color: white; text-decoration: none; padding: 0.5em 1em; font-size: 16px; letter-spacing: 1px; }
      .nav-link-item:hover { background-color: rgba(167, 215, 250, 0.92); border-radius: 4px; color:rgb(32, 71, 145); font-weight: 600; }
    </style>

    <nav class="fixed-nav">
      <.link navigate="/" class="nav-link-item">Início</.link>
      <.link navigate="/produtos" class="nav-link-item">Produtos</.link>
      <.link navigate="/seguradoras" class="nav-link-item">Seguradoras</.link>
      <.link navigate="/contato" class="nav-link-item">Contato</.link>
      <.link navigate="/login" class="nav-link-item">Painel de Controle</.link>
    </nav>
    """
  end
end
