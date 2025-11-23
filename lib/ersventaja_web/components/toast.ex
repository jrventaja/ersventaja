defmodule ErsventajaWeb.Components.Toast do
  use Phoenix.Component

  def toast(assigns) do
    ~H"""
    <div id="toast-container" class="fixed top-20 right-4 z-50 space-y-2">
      <%= if live_flash(@flash, :info) do %>
        <div class="bg-blue-50 border-l-4 border-blue-400 p-4 rounded-lg shadow-lg flex items-center min-w-[300px] max-w-md transform transition-all duration-300 ease-in-out translate-x-0 opacity-100">
          <i class="fas fa-info-circle text-blue-400 mr-3 text-lg"></i>
          <p class="text-lg text-blue-800 flex-1 font-serif"><%= live_flash(@flash, :info) %></p>
          <button phx-click="lv:clear-flash" phx-value-key="info" class="text-blue-400 hover:text-blue-600 ml-2 transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
      <% end %>
      <%= if live_flash(@flash, :success) do %>
        <div class="bg-green-50 border-l-4 border-green-400 p-4 rounded-lg shadow-lg flex items-center min-w-[300px] max-w-md transform transition-all duration-300 ease-in-out translate-x-0 opacity-100">
          <i class="fas fa-check-circle text-green-400 mr-3 text-lg"></i>
          <p class="text-lg text-green-800 flex-1 font-serif"><%= live_flash(@flash, :success) %></p>
          <button phx-click="lv:clear-flash" phx-value-key="success" class="text-green-400 hover:text-green-600 ml-2 transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
      <% end %>
      <%= if live_flash(@flash, :error) do %>
        <div class="bg-red-50 border-l-4 border-red-400 p-4 rounded-lg shadow-lg flex items-center min-w-[300px] max-w-md transform transition-all duration-300 ease-in-out translate-x-0 opacity-100">
          <i class="fas fa-exclamation-circle text-red-400 mr-3 text-lg"></i>
          <p class="text-lg text-red-700 flex-1 font-serif"><%= live_flash(@flash, :error) %></p>
          <button phx-click="lv:clear-flash" phx-value-key="error" class="text-red-400 hover:text-red-600 ml-2 transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
      <% end %>
      <%= if live_flash(@flash, :warning) do %>
        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded-lg shadow-lg flex items-center min-w-[300px] max-w-md transform transition-all duration-300 ease-in-out translate-x-0 opacity-100">
          <i class="fas fa-exclamation-triangle text-yellow-400 mr-3 text-lg"></i>
          <p class="text-lg text-yellow-800 flex-1 font-serif"><%= live_flash(@flash, :warning) %></p>
          <button phx-click="lv:clear-flash" phx-value-key="warning" class="text-yellow-400 hover:text-yellow-600 ml-2 transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
      <% end %>
    </div>
    """
  end
end
