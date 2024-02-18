defmodule ErsventajaWeb.AuthenticationController do
  use ErsventajaWeb, :controller

  alias Ersventaja.{UserManager, UserManager.Guardian}
  alias ErsventajaWeb.Schemas.AuthenticationRequest

  import Plug.Conn
  use OpenApiSpex.ControllerSpecs

  operation :login,
    description: "Login to the system",
    tags: ["authentication"],
    responses: [],
    request_body: {"User params", "application/json", AuthenticationRequest}

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    UserManager.authenticate_user(username, password)
    |> login_reply(conn)
    |> halt()
  end

  defp login_reply({:ok, user}, conn) do
    authed_conn = Guardian.Plug.sign_in(conn, user)

    authed_conn
    |> resp_json(build_token_response(Guardian.Plug.current_token(authed_conn)))
  end

  defp login_reply({:error, _reason}, conn) do
    conn
    |> send_resp(401, "unauthorized")
  end

  defp build_token_response(token), do: %{access_token: token}
end
