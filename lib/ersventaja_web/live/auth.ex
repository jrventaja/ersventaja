defmodule ErsventajaWeb.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Ersventaja.UserManager.Guardian

  def on_mount(:ensure_authenticated, _params, session, socket) do
    token = Map.get(session, "guardian_default_token")
    case token && Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:cont, assign(socket, current_user: user)}

      _ ->
        {:halt, redirect(socket, to: "/login")}
    end
  end

  def on_mount(:optional_auth, _params, session, socket) do
    token = Map.get(session, "guardian_default_token")
    case token && Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:cont, assign(socket, current_user: user)}

      _ ->
        {:cont, assign(socket, current_user: nil)}
    end
  end
end
