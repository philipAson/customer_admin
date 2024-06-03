defmodule CustomerAdminWeb.HomeLive do

  use CustomerAdminWeb, :live_view
  alias CustomerAdmin.User
  alias CustomerAdmin.Users
  alias CustomerAdmin.Repo
  alias CustomerAdmin.Companies

  def mount(_params, _session, socket) do
    filter_params = %{
      email_name: nil,
      company_name: nil,
      show_deleted: false,
      sort_by: "company_name",
      limit: 20
    }

    companies =
      Companies.get_companies()
      |> Enum.map(fn %{:id => id, :name => name} ->
        {name, id}
      end)
      |> Enum.sort()

    names_of_companies =
      Enum.map(companies, fn {name, _} -> name end)
      |> Enum.uniq()
      |> List.insert_at(0, {"Show all", ""})

    users = Users.get_users(filter_params)

    socket =
      assign(socket,
        users: users,
        filter_params: filter_params,
        selected_user: nil,
        new_user: nil,
        companies: companies,
        names_of_companies: names_of_companies,
        users_form: nil,
        email_errors: []

      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    case Users.get_user(id) do

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "User not found")
         |> assign(selected_user: nil)
        }
      user ->

      IO.inspect(user, label: "User")

      {:noreply,
       socket
       |> assign(new_user: nil)
       |> assign(selected_user: user)
      }
    end
  end

  def handle_params(%{"user" => "new"}, _uri, socket) do
    {:noreply,
     socket
     |> assign(selected_user: nil)
     |> assign(new_user: %{full_name: "", email: "", company_id: "", category: ""})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(selected_user: nil)
     |> assign(new_user: nil)}
  end

  def render(assigns) do
    ~H"""

    <div class="flex w-full items-start justify-between px-4 sm:px-6 lg:px-8">
      <form phx-change="filter" class="sm:flex gap-x-4 w-5/6 mx-auto justify-center">
        <div class="md:flex items-center  gap-x-4">
          <.input
            type="text"
            name="email_name"
            phx-debounce="500"
            value={@filter_params.email_name}
            placeholder="Email or Name"
            autocomplete="off"
            label="Search with"
          />
          <.input
            label="Company"
            type="select"
            name="company_name"
            value={@filter_params.company_name}
            options={@names_of_companies}
          />
        </div>
        <div class="md:flex items-center gap-x-4">
          <.input
            label="Sort by"
            type="select"
            name="sorter"
            value={@filter_params.sort_by}
            options={sorting_options()}
          />
          <.input
            label="Limit"
            type="select"
            name="limit"
            phx-debounce="500"
            min="20"
            max="200"
            options={Enum.map(20..200//20, &{&1, &1})}
            value={@filter_params.limit}
          />
          <div class="self-end">
            <.input
              label="Show deleted"
              type="checkbox"
              name="show_deleted"
              value="true"
              checked={@filter_params.show_deleted}
            />
          </div>
        </div>
      </form>
      <div class="flex items-center gap-x-4">
        <.button phx-click={JS.patch(~p"/?user=new")}>
          Add user
        </.button>
      </div>
    </div>
    <ul role="list" class="max-w-5xl mx-auto divide-y divide-gray-100 dark:divide-gray-800 overflow-hidden bg-white dark:bg-gray-900 shadow-sm ring-1 ring-gray-900/5 dark:ring-gray-900/90 sm:rounded-xl mt-2">

      <li :for={u <- @users} class="relative flex justify-between items-start gap-x-6 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-950 sm:px-6 group">
        <div class="flex min-w-0 sm:w-1/2">
          <div class="min-w-0 flex-auto space-y-0.5">
            <p class="text-sm font-semibold text-gray-900 dark:text-gray-100">
              <.link patch={~p"/?#{[id: u.id]}"}>
                <span class="absolute inset-x-0 -top-px bottom-0"></span>
                <%= u.full_name %>
              </.link>
            </p>
            <p class="flex text-xs text-gray-500 dark:text-gray-400">
              <a href={"mailto:#{u.email}"} class="relative truncate hover:underline"><%= u.email %></a>
            </p>
          </div>
        </div>

        <div class="flex items-center justify-end sm:w-1/4">
          <div class="hidden sm:flex sm:flex-col sm:items-end space-y-0.5">
            <p class="text-sm font-semibold text-gray-600 dark:text-gray-400"><%= u.company_name %></p>
            <p class="text-xs text-gray-900 dark:text-gray-400"><%= u.category %></p>
          </div>
        </div>
        <div class="flex items-center justify-end sm:w-1/4">
          <div class="hidden sm:flex sm:flex-col sm:items-end space-y-0.5">
            <p class="text-xs text-gray-500 dark:text-gray-400">
              <%= DateTime.to_date(u.inserted_at) %>
            </p>
            <div :if={!u.status} class="flex items-center gap-x-1.5">
              <div class="flex-none rounded-full bg-emerald-500/20 p-1">
                <div class="h-1.5 w-1.5 rounded-full bg-emerald-500"></div>
              </div>
              <p class="text-xs leading-5 text-gray-500">Active</p>
            </div>
            <div :if={u.status} class="flex items-center gap-x-1.5">
              <div class="flex-none rounded-full bg-red-500/20 p-1">
                <div class="h-1.5 w-1.5 rounded-full bg-red-500"></div>
              </div>
              <p class="text-xs leading-5 text-red-400">Deleted</p>
            </div>

          </div>
          <div class="pl-4 flex items-end justify-end gap-x-1 text-gray-400 transition opacity-30 group-hover:opacity-100">
            <.icon name="hero-window" class="h-5 w-5 flex-none" />
            <span class="text-xs">Edit</span>
          </div>
        </div>
      </li>

    </ul>



      <.modal :if={@selected_user} id="edit-modal" show on_cancel={JS.patch(~p"/")}>
        <.live_component
          module={CustomerAdminWeb.EditUserModal}
          id="edit-user-modal"
          selected_user={@selected_user}
          companies={@companies}
        />
      </.modal>

      <.modal :if={@new_user} id="new-modal" show on_cancel={JS.patch(~p"/")}>
        <.live_component
          module={CustomerAdminWeb.NewUserModal}
          id="new-user-modal"
          new_user={@new_user}
          companies={@companies}
          email_errors={@email_errors}
        />
      </.modal>

    """
  end

  # def handle_event(
  #       "filter",
  #       %{
  #         "show_deleted" => show_deleted,
  #         "company_name" => company_name,
  #         "email_name" => email_name,
  #         "limit" => limit,
  #         "sorter" => sorter
  #       },
  #       socket
  #     ) do
  #   show_deleted = show_deleted == "true"
  #   limit = String.to_integer(limit)

  #   filter_params = %{
  #     show_deleted: show_deleted,
  #     limit: limit,
  #     email_name: email_name,
  #     company_name: company_name,
  #     sort_by: sorter
  #   }

  #   users = Users.get_users(filter_params)

  #   {:noreply,
  #    socket
  #    |> assign(users: users)
  #    |> assign(filter_params: filter_params)}

  # end
  def handle_event("filter", params, socket) do
    # Convert parameters to appropriate types
    show_deleted = Map.get(params, "show_deleted", "false") == "true"
    limit = Map.get(params, "limit", "20") |> String.to_integer()
    email_name = Map.get(params, "email_name", nil)
    company_name = Map.get(params, "company_name", nil)
    sorter = Map.get(params, "sorter", "company_name")

    # Merge with existing filter_params
    filter_params = Map.merge(socket.assigns.filter_params, %{
      show_deleted: show_deleted,
      limit: limit,
      email_name: email_name,
      company_name: company_name,
      sort_by: sorter
    })

    users = Users.get_users(filter_params)

    {:noreply,
     socket
     |> assign(users: users)
     |> assign(filter_params: filter_params)}
  end

  def handle_event("delete_user", _, socket) do

    user = Repo.get(User, socket.assigns.selected_user.id)
    changeset = User.changeset(user, %{deleted: true})

    case Repo.update(changeset) do
      {:ok, _} ->
        {:noreply, socket |> push_patch(to: ~p"/") |> put_flash(:info, "User deleted")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Err: User not deleted")}
    end
  end

  defp sorting_options do
    [
      {"Email", "email"},
      {"Name", "name"},
      {"Created", "inserted_at"},
      {"Company", "company_name"}
    ]
  end
end
