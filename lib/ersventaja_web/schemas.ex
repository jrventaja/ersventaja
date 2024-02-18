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
end
