defmodule Ersventaja.Policies.Schemas.In.CreatePolicyRequest do
  @moduledoc false
  @derive Jason.Encoder

  @fields quote(
            do: [
              name: String.t(),
              detail: String.t(),
              start_date: Date.t(),
              end_date: Date.t(),
              insurer_id: integer(),
              encoded_file: String.t()
            ]
          )

  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
