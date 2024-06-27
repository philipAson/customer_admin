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

  # This function will generate a number of companies with random names
  def generate_mock_companies(x) do
    for _ <- 1..x do
      company = %Company{
        name: Faker.Company.name()
      }
      Repo.insert!(company)
    end
  end

  def get_list_of_companies_id do
    query =
      from(c in Company,
        select: c.id
      )
    Repo.all(query)
  end
end
