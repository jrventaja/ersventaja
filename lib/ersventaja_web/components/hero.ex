defmodule ErsventajaWeb.Components.Hero do
  use Phoenix.Component

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil

  def hero(assigns) do
    ~H"""
    <style>
      .hero-section { margin-top: 50px; height: 300px; width: 100%; background-color: rgb(39, 39, 39); display: flex; align-items: center; justify-content: center; position: relative; }
    </style>

    <div class="hero-section">
      <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
        <img alt="RS Ventaja" src="/images/rs_logo_transparent.png" width="120" height="120" style="margin-bottom: 1.5em;" />
        <h1 style="font-size: 42px; margin: 0; font-weight: 400; color: white; letter-spacing: 2px; font-family: 'Playfair Display', Georgia, serif;"><%= @title %></h1>
        <%= if @subtitle do %>
          <p style="font-size: 18px; font-style: italic; margin: 0.5em 0 0 0; color: white; font-family: 'Playfair Display', Georgia, serif;"><%= @subtitle %></p>
        <% end %>
      </div>
    </div>
    """
  end
end
