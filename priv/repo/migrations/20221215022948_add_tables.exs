defmodule Ersventaja.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    create table(:insurers) do
      add :name, :string

      timestamps()
    end

    create table(:policies) do
      add :customer_name, :string
      add :detail, :string
      add :start_date, :date
      add :end_date, :date
      add :calculated, :boolean
      add :insurer_id, references(:insurers)

      timestamps()
    end
  end
end
