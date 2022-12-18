defmodule Ersventaja.Policies.Models.Insurer do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}

  schema "insurers" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(insurer, attrs) do
    insurer
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
