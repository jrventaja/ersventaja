defmodule ErsventajaWeb.PolicyController do
  use ErsventajaWeb, :controller

  alias Ersventaja.Policies

  def create(conn, attrs) do
    resp_json(conn, Policies.add_policy(attrs))
  end

  def last_30_days(conn, _attrs) do
    resp_json(conn, Policies.last_30_days())
  end

  def get_policies(conn, %{"current_only" => current_only, "name" => name}) do
    resp_json(conn, Policies.get_policies(current_only, name))
  end

  def delete(conn, %{"id" => id}) do
    resp_json(conn, Policies.delete_policy(id))
  end
end
