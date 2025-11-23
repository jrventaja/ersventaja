defmodule ErsventajaWeb.SessionController do
  use ErsventajaWeb, :controller

  def set_session(conn, params) do
    # Get the short-lived session token from query params
    session_token = Map.get(params, "token")

    case session_token && Phoenix.Token.verify(conn, "session", session_token, max_age: 60) do
      {:ok, guardian_token} ->
        # Successfully verified the Phoenix token and got the Guardian token
        conn
        |> put_session("guardian_default_token", guardian_token)
        |> configure_session(renew: true)
        |> put_flash(:info, "Login realizado com sucesso!")
        |> redirect(to: "/controlpanel")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Token de sessão inválido ou expirado")
        |> redirect(to: "/login")

      nil ->
        conn
        |> put_flash(:error, "Token de sessão não encontrado")
        |> redirect(to: "/login")
    end
  end
end
