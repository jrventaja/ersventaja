defmodule ErsventajaWeb.InsurerController do
  use ErsventajaWeb, :controller

  alias Ersventaja.Policies
  use OpenApiSpex.ControllerSpecs
  alias ErsventajaWeb.Schemas.{CreateInsurerRequest, CreateInsurerResponse, GetInsurersResponse}

  operation :list,
    description: "Get insurers",
    tags: ["insurer"],
    responses: %{
      200 => {"Insurers list", "application/json", GetInsurersResponse}
    },
    security: [%{"bearerAuth" => []}]

  def list(conn, _attrs) do
    resp_json(conn, Policies.get_insurers())
  end

  operation :create,
    description: "Create insurer",
    tags: ["insurer"],
    responses: %{
      200 => {"Insurer", "application/json", CreateInsurerResponse}
    },
    security: [%{"bearerAuth" => []}],
    request_body: {"User params", "application/json", CreateInsurerRequest}

  def create(conn, %{"id" => id, "name" => name}) do
    resp_json(conn, Policies.add_insurer(id, name))
  end

  def create(conn, %{"name" => name}) do
    resp_json(conn, Policies.add_insurer(name))
  end
end
