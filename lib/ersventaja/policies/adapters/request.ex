defmodule Ersventaja.Policies.Adapters.RequestAdapter do
  @moduledoc false

  alias Ersventaja.Policies.Schemas.In.CreatePolicyRequest

  @spec create_policy_request(map) :: Ersventaja.Policies.Schemas.In.CreatePolicyRequest.t()
  def create_policy_request(%{
        "encoded_file" => encoded_file,
        "name" => name,
        "detail" => detail,
        "start_date" => start_date,
        "end_date" => end_date,
        "insurer_id" => insurer_id
      }),
      do: %CreatePolicyRequest{
        encoded_file: encoded_file,
        name: name,
        detail: detail,
        start_date: Date.from_iso8601!(start_date),
        end_date: Date.from_iso8601!(end_date),
        insurer_id: insurer_id
      }
end
