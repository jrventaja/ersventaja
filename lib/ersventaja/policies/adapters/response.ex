defmodule Ersventaja.Policies.Adapters.ResponseAdapter do
  @moduledoc false

  @spec get_policy_response(list()) :: list()
  def get_policy_response(list),
    do: Enum.map(list, &policy_response(&1))

  defp policy_response(%{
         calculated: calculated,
         customer_name: customer_name,
         detail: detail,
         end_date: end_date,
         file_name: file_name,
         id: id,
         insurer_id: insurer_id,
         start_date: start_date,
         insurer: %{
           name: insurer_name
         }
       }),
       do: %{
         calculated: calculated,
         customer_name: customer_name,
         detail: detail,
         end_date: end_date,
         file_name: file_name,
         id: id,
         insurer_id: insurer_id,
         insurer: insurer_name,
         start_date: start_date
       }
end
