defmodule CustomerAdmin.Companies do
  import Ecto.Query
  alias CustomerAdmin.Company
  alias CustomerAdmin.Repo

  def get_companies do
    query =
      from(c in Company,
        select: %{
          id: c.id,
          name: c.name,
        }
      )
    Repo.all(query)
  end
end
