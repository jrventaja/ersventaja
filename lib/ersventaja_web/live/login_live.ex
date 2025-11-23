defmodule ErsventajaWeb.LoginLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Toast

  alias Ersventaja.{UserManager, UserManager.Guardian}

  def mount(_params, session, socket) do
    # Check if already authenticated
    token = Map.get(session, "guardian_default_token")
    case token && Guardian.resource_from_token(token) do
      {:ok, _user, _claims} ->
        {:ok, redirect(socket, to: "/controlpanel")}

      _ ->
        {:ok, assign(socket, username: "", password: "", authenticating: false)}
    end
  end

  def handle_event("login", %{"username" => username, "password" => password}, socket) do
    socket = assign(socket, authenticating: true)

    if String.length(username) == 0 || String.length(password) == 0 do
      {:noreply, socket |> put_flash(:warning, "Preencha todos os campos.") |> assign(authenticating: false)}
    else
      case UserManager.authenticate_user(username, password) do
        {:ok, user} ->
          {:ok, guardian_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "access")
          # Create a short-lived Phoenix token to pass the Guardian token securely
          session_token = Phoenix.Token.sign(socket, "session", guardian_token, max_age: 60)
          {:noreply, redirect(socket, to: "/session?token=#{session_token}")}

        {:error, _reason} ->
          {:noreply, socket |> put_flash(:error, "Usuário ou senha incorretos.") |> assign(authenticating: false)}
      end
    end
  end

  def handle_event("validate", %{"username" => username, "password" => password}, socket) do
    {:noreply, assign(socket, username: username, password: password)}
  end

  def render(assigns) do
    ~H"""
    <.toast flash={@flash} />
    <div class="min-h-screen bg-gradient-to-br from-brand-blue to-blue-600">
      <nav class="bg-white shadow-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-center items-center h-16">
            <.link navigate={"/"} class="text-brand-blue hover:text-blue-700 transition-colors duration-200 font-medium flex items-center space-x-2">
              <i class="fas fa-arrow-left"></i>
              <span>Voltar à Página Inicial</span>
            </.link>
          </div>
        </div>
      </nav>

      <div class="flex flex-col items-center justify-center px-4 py-12">
        <div class="mb-8">
          <img alt="RS Ventaja" src="/images/rs_logo_transparent.png" class="w-32 h-32 rounded-full shadow-2xl bg-white p-4" />
        </div>

        <div class="w-full max-w-md">
          <div class="bg-white rounded-2xl shadow-2xl p-8">
            <h2 class="text-3xl font-bold text-center text-gray-900 mb-8">Painel de Controle</h2>

            <.form for={%{}} phx-submit="login" phx-change="validate" class="space-y-6">
              <div>
                <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
                  Usuário
                </label>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={@username}
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-brand-blue focus:border-transparent transition-all duration-200"
                  placeholder="Digite seu usuário"
                />
              </div>

              <div>
                <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                  Senha
                </label>
                <input
                  type="password"
                  id="password"
                  name="password"
                  value={@password}
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-brand-blue focus:border-transparent transition-all duration-200"
                  placeholder="Digite sua senha"
                />
              </div>


              <button
                type="submit"
                class="w-full bg-brand-blue text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                disabled={@authenticating}
              >
                <%= if @authenticating do %>
                  <i class="fas fa-spinner fa-spin"></i>
                  <span>Autenticando...</span>
                <% else %>
                  <i class="fas fa-sign-in-alt"></i>
                  <span>Entrar</span>
                <% end %>
              </button>
            </.form>
          </div>

          <p class="text-center text-white text-sm mt-6">
            &copy; 2025 RS Ventaja Corretora de Seguros
          </p>
        </div>
      </div>
    </div>
    """
  end
end
