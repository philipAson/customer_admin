defmodule CustomerAdmin.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :category, :string
    field :password, :string
    field :full_name, :string
    field :email, :string
    field :deleted, :boolean, default: false
    field :api_keys, {:array, :string}
    field :company_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :password, :email, :category, :deleted, :api_keys, :company_id])
    |> validate_required([:full_name, :email, :company_id])
    |> validate_format(:email, ~r/^[\w.!#$%&'*+\/=?^_\`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/)
    |> unique_constraint(:email)
    |> validate_length(:full_name, min: 1, max: 30, message: "Full name must be between 1 and 30 characters")
  end
end
