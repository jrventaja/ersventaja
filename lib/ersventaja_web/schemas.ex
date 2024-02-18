defmodule ErsventajaWeb.Schemas do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  defmodule AuthenticationRequest do
    OpenApiSpex.schema(%{
      title: "AuthenticationRequest",
      description: "A request to authenticate a user",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            username: %Schema{type: :string, description: "The username"},
            password: %Schema{type: :string, description: "The password"}
          }
        }
      }
    })
  end

  defmodule AuthenticationResponse do
    OpenApiSpex.schema(%{
      title: "AuthenticationResponse",
      description: "An authentication response",
      type: :object,
      properties: %{
        access_token: %Schema{type: :string, description: "JWT token"}
      }
    })
  end

  defmodule GetInsurersResponse do
    OpenApiSpex.schema(%{
      title: "GetInsurersResponse",
      description: "A response to get insurers",
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          id: %Schema{type: :integer, description: "The insurer's id"},
          name: %Schema{type: :string, description: "The insurer's name"}
        }
      }
    })
  end

  defmodule CreateInsurerResponse do
    OpenApiSpex.schema(%{
      title: "CreateInsurerResponse",
      description: "A response to create insurer",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "The insurer's id"},
        name: %Schema{type: :string, description: "The insurer's name"}
      }
    })
  end

  defmodule CreateInsurerRequest do
    OpenApiSpex.schema(%{
      title: "CreateInsurerRequest",
      description: "A request to create an insurer",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "The insurer's id"},
        name: %Schema{type: :string, description: "The insurer's name"}
      }
    })
  end

  defmodule CreatePolicyRequest do
    OpenApiSpex.schema(%{
      title: "CreatePolicyRequest",
      description: "A request to create a policy",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "The customer's name"},
        detail: %Schema{type: :string, description: "The policy's detail"},
        start_date: %Schema{type: :string, description: "The policy's start date"},
        end_date: %Schema{type: :string, description: "The policy's end date"},
        insurer_id: %Schema{type: :integer, description: "The insurer's id"},
        encoded_file: %Schema{type: :string, description: "The policy's file"}
      },
      example: %{
        name: "John Doe",
        detail: "A policy",
        start_date: "2021-01-01",
        end_date: "2021-12-31",
        insurer_id: 1,
        encoded_file: "YmFzZTY0ZW5jb2RlZGZpbGU="
      }
    })
  end

  defmodule CreatePolicyResponse do
    OpenApiSpex.schema(%{
      title: "CreatePolicyResponse",
      description: "A response to create a policy",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "The policy's id"},
        customer_name: %Schema{type: :string, description: "The customer's name"},
        detail: %Schema{type: :string, description: "The policy's detail"},
        start_date: %Schema{type: :string, description: "The policy's start date"},
        end_date: %Schema{type: :string, description: "The policy's end date"},
        calculated: %Schema{type: :boolean, description: "The policy is calculated"}
      }
    })
  end

  defmodule CreatePolicyResponseList do
    OpenApiSpex.schema(%{
      title: "CreatePolicyResponseList",
      description: "A response to create a policy",
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          id: %Schema{type: :integer, description: "The policy's id"},
          customer_name: %Schema{type: :string, description: "The customer's name"},
          detail: %Schema{type: :string, description: "The policy's detail"},
          start_date: %Schema{type: :string, description: "The policy's start date"},
          end_date: %Schema{type: :string, description: "The policy's end date"},
          calculated: %Schema{type: :boolean, description: "The policy is calculated"}
        }
      }
    })
  end

  defmodule UpdatePolicyStatusRequest do
    OpenApiSpex.schema(%{
      title: "UpdatePolicyStatusRequest",
      description: "A request to update a policy's status",
      type: :object,
      properties: %{
        status: %Schema{type: :boolean, description: "The policy's status"}
      }
    })
  end
end
