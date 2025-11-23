defmodule ErsventajaWeb.HealthController do
  use ErsventajaWeb, :controller

  def health(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
