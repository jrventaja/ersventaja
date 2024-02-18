defmodule ErsventajaWeb.PolicyController do
  use ErsventajaWeb, :controller

  alias Ersventaja.Policies
  use OpenApiSpex.ControllerSpecs

  alias ErsventajaWeb.Schemas.{
    CreatePolicyRequest,
    CreatePolicyResponse,
    CreatePolicyResponseList,
    UpdatePolicyStatusRequest
  }

  operation :create,
    description: "Create policy",
    tags: ["policy"],
    responses: %{
      200 => {"Policy", "application/json", CreatePolicyResponse}
    },
    security: [%{"bearerAuth" => []}],
    request_body: {"Policy params", "application/json", CreatePolicyRequest}

  def create(conn, attrs) do
    resp_json(conn, Policies.add_policy(attrs))
  end

  operation :last_30_days,
    description: "Get policies in last 30 days",
    tags: ["policy"],
    responses: %{
      200 => {"Policies list", "application/json", CreatePolicyResponseList}
    },
    security: [%{"bearerAuth" => []}]

  def last_30_days(conn, _attrs) do
    resp_json(conn, Policies.last_30_days())
  end

  operation :get_policies,
    description: "Get policies filtered",
    tags: ["policy"],
    parameters: [
      current_only: [
        in: :query,
        description: "Current policies only",
        type: :boolean
      ],
      name: [
        in: :query,
        description: "Policy name",
        type: :string
      ]
    ],
    responses: %{
      200 => {"Policies list", "application/json", CreatePolicyResponseList}
    },
    security: [%{"bearerAuth" => []}]

  def get_policies(conn, %{"current_only" => current_only, "name" => name}) do
    resp_json(conn, Policies.get_policies(current_only, name))
  end

  operation :delete,
    description: "Delete policy",
    tags: ["policy"],
    responses: %{
      200 => {"Policy", "application/json", CreatePolicyResponse}
    },
    security: [%{"bearerAuth" => []}],
    parameters: [
      id: [
        in: :path,
        description: "Policy ID",
        type: :integer,
        example: 1
      ]
    ]

  def delete(conn, %{"id" => id}) do
    resp_json(conn, Policies.delete_policy(id))
  end

  operation :update_status,
    description: "Update policy status",
    tags: ["policy"],
    responses: %{
      200 => {"Policy", "application/json", CreatePolicyResponse}
    },
    security: [%{"bearerAuth" => []}],
    parameters: [
      id: [
        in: :path,
        description: "Policy ID",
        type: :integer,
        example: 1
      ]
    ],
    request_body: {"Policy status", "application/json", UpdatePolicyStatusRequest}

  def update_status(conn, %{"id" => id, "status" => status}) do
    resp_json(conn, Policies.update_status(id, status))
  end
end
