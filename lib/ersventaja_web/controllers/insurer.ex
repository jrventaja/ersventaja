defmodule ErsventajaWeb.InsurerController do
  use ErsventajaWeb, :controller

  alias Ersventaja.Policies

  def list(conn, _attrs) do
    resp_json(conn, Policies.get_insurers())
  end
end
