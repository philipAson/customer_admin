defmodule CustomerAdmin.Users do
  import Ecto.Query
  alias CustomerAdmin.Repo
  alias CustomerAdmin.User
  alias CustomerAdmin.Company

  def get_users(params) do
    query =
      from(u in User,
        join: c in Company,
        on: u.company_id == c.id,
        select: %{
          id: u.id,
          full_name: u.full_name,
          email: u.email,
          inserted_at: u.inserted_at,
          company_name: c.name,
          company_id: c.id,
          status: u.deleted,
          category: u.category,
          api_keys: u.api_keys
        }
      )

    query
    |> apply_show_deleted(params)
    |> apply_email_name_filter(params)
    |> apply_company_filter(params)
    # |> apply_has_api_key()
    |> apply_sorter(params)
    |> apply_limit(params)
    |> Repo.all()
  end

  def create_mock_users(x) do
    companies = CustomerAdmin.Companies.get_list_of_companies_id()

    for _ <- 1..x do
      %User{
        full_name: Faker.Person.name(),
        email: Faker.Internet.email(),
        company_id: Enum.random(companies),
        category: Faker.Commerce.department()
      }
      |> Repo.insert!()
    end
  end


  defp apply_show_deleted(query, %{show_deleted: true}), do: query

  defp apply_show_deleted(query, %{show_deleted: false}),
    do: from(u in query, where: u.deleted == false)

  defp apply_company_filter(query, %{company_name: partition}) do
    from([u, c] in query,
      where: ilike(c.name, ^"%#{partition}%")
    )
  end

  defp apply_company_filter(query, _), do: query

  defp apply_email_name_filter(query, %{email_name: partition}) do
    from(u in query,
      where: ilike(u.email, ^"%#{partition}%") or ilike(u.full_name, ^"%#{partition}%")
    )
  end

  defp apply_email_name_filter(query, _), do: query

  # defp apply_has_api_key(query) do
  #   from(u in query, where: is_nil(u.api_keys) == false)
  # end

  defp apply_sorter(query, %{sort_by: sort_by}) do
    case sort_by do
      "name" -> sort_users_by_name(query)
      "email" -> sort_users_by_email(query)
      "inserted_at" -> sort_users_by_inserted_at(query)
      "company_name" -> sort_users_by_company_name(query)
    end
  end

  defp apply_sorter(query, _), do: query

  defp sort_users_by_name(query) do
    from(u in query, order_by: [asc: u.full_name])
  end

  defp sort_users_by_email(query) do
    from(u in query, order_by: [asc: u.email])
  end

  defp sort_users_by_inserted_at(query) do
    from(u in query, order_by: [asc: u.inserted_at])
  end

  defp sort_users_by_company_name(query) do
    from([u, c] in query, order_by: [asc: c.name])
  end

  defp apply_limit(query, %{limit: limit}) do
    from(u in query, limit: ^limit)
  end

  defp apply_limit(query, _), do: query

  def get_user(id) do
    query =
      from(u in User,
        join: c in Company,
        on: u.company_id == c.id,
        where: u.id == ^id,
        select: %{
          id: u.id,
          full_name: u.full_name,
          email: u.email,
          inserted_at: u.inserted_at,
          company_name: c.name,
          deleted: u.deleted,
          api_keys: u.api_keys,
          category: u.category
        }
      )

    Repo.one(query)
  end

  def email_is_valid(email) do
    valid_format? = Regex.match?(~r/^[\w.!#$%&'*+\/=?^_\`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/, email)
    conflict =
      Repo.all(
        from(u in User,
          where: u.email == ^email,
          where: u.deleted == false
        )
      )

      case {valid_format?, conflict} do
        {false, _} -> {:error, "Invalid email format"}
        {true, []} -> {:ok, "Email is valid"}
        {true, _} -> {:error, "An active user with that email is already registered"}
      end
  end
end
