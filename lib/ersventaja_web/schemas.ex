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
end
