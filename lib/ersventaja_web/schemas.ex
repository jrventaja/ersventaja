defmodule ErsventajaWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule AuthenticationRequest do
    require OpenApiSpex

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
end
