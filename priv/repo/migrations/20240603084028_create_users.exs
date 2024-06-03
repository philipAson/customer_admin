defmodule CustomerAdmin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :full_name, :string
      add :password, :string
      add :email, :string
      add :category, :string
      add :deleted, :boolean, default: false, null: false
      add :api_keys, {:array, :string}
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:users, [:company_id])
  end
end
