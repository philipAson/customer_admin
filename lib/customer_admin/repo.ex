defmodule CustomerAdmin.Repo do
  use Ecto.Repo,
    otp_app: :customer_admin,
    adapter: Ecto.Adapters.Postgres
end
