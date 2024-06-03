defmodule CustomerAdminWeb.EditUserModal do
  use CustomerAdminWeb, :live_component

  alias CustomerAdmin.Users
  alias CustomerAdmin.User
  alias CustomerAdmin.Repo
  alias CustomerAdmin.UserAggregate
  alias CustomerAdminWeb.Components.UserForm

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:user_form, UserForm.user_form(assigns.selected_user))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8" id="confirm-delete" phx-hook="ConfirmDelete">
      <.flash_group flash={@flash} />
      <h1 class="font-semibold dark:text-white">Edit: <%= @selected_user.full_name %></h1>
      <%!-- <.form phx-form={@user_form} phx-target={@myself} class="space-y-4"> --%>
      <.form for={@user_form} phx-target={@myself} class="space-y-4">
        <.input
          phx-change="update_full_name"
          phx-debounce="blur"
          label="Name"
          name="full_name"
          field={@user_form[:full_name]}
          value={@selected_user.full_name}
        />
        <.input
          phx-change="update_email"
          phx-debounce="blur"
          label="Email"
          name="email"
          field={@user_form[:email]}
          value={@selected_user.email}
        />
        <.input
          phx-change="update_category"
          phx-debounce="blur"
          label="Category"
          name="category"
          field={@user_form[:category]}
          value={@selected_user.category}
        />
        <.input
          name="company_id"
          label="Company"
          field={@user_form[:company_id]}
          value={@selected_user.company_name}
          disabled
        />
        <%= if @selected_user.api_keys != nil do %>
          <%= for _ <- @selected_user.api_keys do %>
            <.input
              name="api_keys"
              label="API key"
              field={@user_form[:api_keys]}
              value={@selected_user.api_keys}
              disabled
            />
          <% end %>
        <% end %>
        <div class="flex items-center text-xs leading-5 gap-x-4">
          <span class="text-gray-500 dark:text-gray-400">Status:</span>
          <div :if={!@selected_user.deleted} class="flex items-center gap-x-1.5">
            <div class="flex-none rounded-full bg-emerald-500/20 p-1">
              <div class="h-1.5 w-1.5 rounded-full bg-emerald-500"></div>
            </div>
            <p class="text-gray-500">Active</p>
          </div>
          <div :if={@selected_user.deleted} class="flex items-center gap-x-1.5">
            <div class="flex-none rounded-full bg-emerald-500/20 p-1">
              <div class="h-1.5 w-1.5 rounded-full bg-red-500"></div>
            </div>
            <p class="text-red-400">Deleted</p>
          </div>
          <p class="flex items-center space-x-1.5 dark:text-gray-400">
            <span class="text-gray-500 dark:text-gray-400">Created:</span>
            <span class="text-gray-500 dark:text-gray-400"><%=DateTime.to_date(assigns.selected_user.inserted_at)%></span>
          </p>
        </div>
      </.form>
      <%= if !@selected_user.deleted do %>
        <.button phx-click="confirm_delete" phx-target={@myself} class="!bg-red-500 hover:!bg-red-500/80">Delete</.button>
      <% else %>
        <%= if Users.email_is_valid(@selected_user.email) == {:ok, "Email is valid"} do %>
          <.button phx-click={JS.push("restore_user")} phx-target={@myself}>Restore</.button>
        <% else %>
        <%!-- gör en query mot projections
        då det ej är möjligt mot event databasen.
        därav en delay på att möjliggöra en restore
        efter en nyligen deleted user --%>
          <%= if Users.email_is_valid(@selected_user.email)  == {:ok, "Email is valid"} do %>
            <.button phx-click="restore_user" phx-target={@myself}>Restore</.button>
          <% else %>
            <p class="text-red-400">Can't restore user due to conflicting email in database</p>
          <% end %>

        <% end %>
      <% end %>

    </div>
    """
  end

  def handle_event("update_email", %{"email" => email}, socket) do
    user = Repo.get(User, socket.assigns.selected_user.id)
    changeset = User.changeset(user, %{email: email})

    case Repo.update(changeset) do

          {:ok, _} ->
            IO.inspect("Email updated to #{email}")
            {:noreply, socket
            |> assign(selected_user: Map.put(socket.assigns.selected_user, :email, email))
            |> put_flash(:info, "Email updated to #{email}")}


      {:error, reason} ->
        IO.inspect("Email not valid: #{email} message: #{inspect(reason)}")
        {:noreply,
        socket
        # |> push_patch(to: ~p"/")
        |> put_flash(:error, "Err: #{inspect(reason.errors)}")}
      end
  end

  def handle_event("update_full_name", %{"full_name" => full_name}, socket) do
    user = Repo.get(User, socket.assigns.selected_user.id)
    changeset = User.changeset(user, %{full_name: full_name})

    case Repo.update(changeset)
         do
      {:ok, _} ->
        IO.inspect("Full name updated to #{full_name}")
        {:noreply, socket
        |> assign(selected_user: Map.put(socket.assigns.selected_user, :full_name, full_name))
        |> put_flash(:info, "Full name updated to #{full_name}")}

      {:error, _} ->
        IO.inspect("Full name not updated: #{full_name}")
        {:noreply, socket |> put_flash(:error, "Err: Name not updated")}
    end
  end

  def handle_event("update_category", %{"category" => category}, socket) do

    user = Repo.get(User, socket.assigns.selected_user.id)
    changeset = User.changeset(user, %{category: category})

    case Repo.update(changeset) do
      {:ok, _} ->
        IO.inspect("Category updated to #{category}")
        {:noreply, socket
        |> assign(selected_user: Map.put(socket.assigns.selected_user, :category, category))
        |> put_flash(:info, "Category updated to #{category}")}

      {:error, _} ->
        IO.inspect("Category not updated: #{category}")
        {:noreply, socket |> put_flash(:error, "Err: Category not updated")}
    end
  end

  def handle_event("confirm_delete", _, socket) do
    {:noreply,
     socket
     |> push_event("confirm_delete", %{})
    }
  end

  def handle_event("restore_user", _, socket) do

    user = Repo.get(User, socket.assigns.selected_user.id)
    changeset = User.changeset(user, %{deleted: false})

    case Repo.update(changeset) do
      {:ok, _} ->

        {:noreply, socket
        |> assign(selected_user: Map.put(socket.assigns.selected_user, :deleted, false))
        |> put_flash(:info, "User restored")}



      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Err: User not restored")}
    end
  end
end
