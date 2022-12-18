defmodule Ersventaja.Policies do
  alias Ersventaja.Repo
  alias Ersventaja.Policies.Adapters.RequestAdapter
  alias Ersventaja.Policies.Adapters.ResponseAdapter
  alias Ersventaja.Policies.Models.Insurer
  alias Ersventaja.Policies.Models.Policy
  @bucket "policiesrsventaja"
  @region "sa-east-1"
  @regex ~r/[^\w]/

  import Ecto.Query

  def get_insurers() do
    Repo.all(Insurer)
  end

  def add_policy(attrs) do
    with request <- RequestAdapter.create_policy_request(attrs) do
      policy =
        Repo.insert!(%Policy{
          customer_name: request.name,
          detail: request.detail,
          start_date: request.start_date,
          end_date: request.end_date,
          insurer_id: request.insurer_id,
          calculated: false
        })

      file_name = get_file_name(policy.id)

      @bucket
      |> ExAws.S3.put_object(file_name, Base.decode64!(request.encoded_file))
      |> ExAws.request!(region: @region)

      policy
    end
  end

  def delete_policy(id) do
   Repo.one!(Policy, id: String.to_integer(id))
  end

  def last_30_days do
    today = Date.utc_today()
    next_month = Date.add(today, 30)

    query =
      from p in Policy,
        where: p.end_date >= ^today and p.end_date <= ^next_month

    policies_from_query(query)
  end

  def get_policies(current_only, name) do
    today = Date.utc_today()

    like = "%#{name |> String.split(" ") |> Enum.join("%")}%"

    case String.to_atom(current_only) do
      true ->
        query =
          from p in Policy,
            where:
              p.start_date <= ^today and p.end_date >= ^today and like(p.customer_name, ^like)

        policies_from_query(query)

      _ ->
        query =
          from p in Policy,
            where: like(p.customer_name, ^like)

        policies_from_query(query)
    end
  end

  defp policies_from_query(query) do
    query
    |> Repo.all()
    |> Enum.map(&Map.merge(&1, %{file_name: get_file_name(&1.id)}))
    |> ResponseAdapter.get_policy_response()
  end

  defp get_file_name(id) do
    secret_key =
      :ersventaja
      |> Application.fetch_env!(:crypto)
      |> Keyword.get(:key)

    hmac =
      :hmac
      |> :crypto.mac(:sha, secret_key, Integer.to_string(id))
      |> Base.encode64()

    "#{Regex.replace(@regex, hmac, "")}.pdf"
  end
end
