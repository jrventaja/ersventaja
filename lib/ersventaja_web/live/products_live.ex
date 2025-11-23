defmodule ErsventajaWeb.ProductsLive do
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

      /* Products */
      .products-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 2em 3em; margin: 2em auto; max-width: 1200px; padding: 0 2em; }
      .product-card { padding: 1em; text-align: center; }
      .product-title { font-size: 20px; font-weight: 500; margin-bottom: 0.5em; }
      .product-icon { font-size: 80px; margin: 0.5em 0; color: #4A7AC2; }
      .product-desc { color: #666; margin-bottom: 1em; }
      .btn-primary { background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%); color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: all 0.2s; }
      .btn-primary:hover { background: rgba(255, 255, 255, 0.85); color: #1e3a6e; font-weight: 600; border: 1px solid #7DCDEB; }
    </style>

    <.navbar />

    <div class="main-content">
      <section class="section">
        <h2 class="section-title">Produtos</h2>
        <div class="products-grid">
          <!-- Seguro de Automóvel -->
          <div class="product-card">
            <h3 class="product-title">Seguro de Automóvel</h3>
            <i class="fas fa-car product-icon"></i>
            <p class="product-desc">Cobertura e assistência 24h</p>
            <a href="https://wwws.portoseguro.com.br/vendaonline/automovel/home.ns?cod=3f559c36a4824742a4b2ce6c6ca42463&utm_source=43254J&utm_medium=geradorLinks&utm_campaign=GeradordeLinks_AIQ7YJ&utm_content=RS_VENTAJA_CORRETORA_DE_SEGUROS_LTDA&origem=Site" target="_blank" class="btn-primary">
              Faça uma cotação
            </a>
          </div>

          <!-- Seguro Residencial -->
          <div class="product-card">
            <h3 class="product-title">Seguro Residencial</h3>
            <i class="fas fa-home product-icon"></i>
            <p class="product-desc">...também para sua casa!</p>
            <a href="https://wwws.portoseguro.com.br/vendaonline/residencia/home.ns?cod=b316cc04aab441c2b853e91f7c31b6fe&utm_source=43254J&utm_medium=geradorLinks&utm_campaign=GeradordeLinks_AIQ7YJ&utm_content=RS_VENTAJA_CORRETORA_DE_SEGUROS_LTDA&origem=Site" target="_blank" class="btn-primary">
              Faça uma cotação
            </a>
          </div>

          <!-- Seguro Empresarial -->
          <div class="product-card">
            <h3 class="product-title">Seguro Empresarial</h3>
            <i class="fas fa-building product-icon"></i>
            <p class="product-desc">...e sua empresa!</p>
            <a href="/contato" data-phx-link="redirect" data-phx-link-state="push" class="btn-primary">
              Faça uma cotação
            </a>
          </div>

          <!-- Responsabilidade Civil -->
          <div class="product-card">
            <h3 class="product-title">Responsabilidade Civil</h3>
            <i class="fas fa-briefcase product-icon"></i>
            <p class="product-desc">Pra quando tudo dá errado</p>
            <a href="/contato" data-phx-link="redirect" data-phx-link-state="push" class="btn-primary">
              Faça uma cotação
            </a>
          </div>

          <!-- Seguro de Vida -->
          <div class="product-card">
            <h3 class="product-title">Seguro de Vida</h3>
            <i class="fas fa-heartbeat product-icon"></i>
            <p class="product-desc">Preocupação com a sua família</p>
            <a href="https://wwws.portoseguro.com.br/vendaonline/vidamaissimples/home.ns?cod=f4c49db5b36c4ad0a84c46770bdf1454&utm_source=43254J&utm_medium=geradorLinks&utm_campaign=GeradordeLinks_AIQ7YJ&utm_content=RS_VENTAJA_CORRETORA_DE_SEGUROS_LTDA&origem=Site" target="_blank" class="btn-primary">
              Faça uma cotação
            </a>
          </div>

          <!-- Riscos Diversos -->
          <div class="product-card">
            <h3 class="product-title">Riscos Diversos</h3>
            <i class="fas fa-mobile-alt product-icon"></i>
            <p class="product-desc">Seus equipamentos protegidos</p>
            <a href="https://wwws.portoseguro.com.br/vendaonline/equipamentosportateis/home.ns?cod=0ba8daaf22d945eea030713c4ce34678&utm_source=43254J&utm_medium=geradorLinks&utm_campaign=GeradordeLinks_AIQ7YJ&utm_content=RS_VENTAJA_CORRETORA_DE_SEGUROS_LTDA&origem=Site" target="_blank" class="btn-primary">
              Faça uma cotação
            </a>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
