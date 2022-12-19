defmodule ErsventajaWeb.InsurerController do
  use ErsventajaWeb, :controller

  alias Ersventaja.Policies

  def list(conn, _attrs) do
    resp_json(conn, Policies.get_insurers())
  end

  def create(conn, %{"id" => id, "name" => name}) do
    resp_json(conn, Policies.add_insurer(id, name))
  end

  def create(conn, %{"name" => name}) do
    resp_json(conn, Policies.add_insurer(name))
  end
end
