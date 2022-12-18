defmodule ErsventajaWeb.JsonApi do
  import Plug.Conn

  def resp_json(conn, resp_body) do
    conn
    |> Map.merge(%{resp_headers: [{"content-type", "application/json"}]})
    |> send_resp(200, Jason.encode!(resp_body))
  end
end
