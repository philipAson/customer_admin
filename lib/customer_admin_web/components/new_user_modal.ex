defmodule CustomerAdminWeb.NewUserModal do
  use CustomerAdminWeb, :live_component

  alias CustomerAdmin.Users
  # alias CustomerAdmin.UserAggregate
  alias CustomerAdmin.Repo
  alias CustomerAdminWeb.Components.UserForm

  def update(assigns, socket) do
    IO.inspect(assigns, label: "Assigns")

    socket =
      socket
      |> assign(assigns)
      |> assign(:user_form, UserForm.user_form())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.flash_group flash={@flash} />
      <h1 class="text-xl font-semibold dark:text-white">New user</h1>

        <.form phx-submit="save_new_user" for={@user_form} phx-target={@myself} class="space-y-4">
          <.input type="text" label="Name" name="full_name" field={@user_form[:full_name]} />
          <.input type="email" label="Email" name="email" field={@user_form[:email]} errors={@email_errors} />
          <.input
            name="company_id"
            label="Company"
            type="select"
            prompt="Select a company"
            field={@user_form[:company_id]}
            options={@companies}
          />
          <.input type="text" label="Category" name="category" field={@user_form[:category]} />


          <.button
            type="submit"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Save
          </.button>
        </.form>
    </div>
    """
  end

  def handle_event(
        "save_new_user",
        %{
          "full_name" => full_name,
          "email" => email,
          "company_id" => company_id,
          "category" => category
        },
        socket
      ) do

        new_user = %{
          full_name: full_name,
          email: email,
          company_id: company_id,
          category: category
        }

    case Users.email_is_valid(email) do
      {:ok, _} ->

        changeset = CustomerAdmin.User.changeset(%CustomerAdmin.User{}, new_user)
        case Repo.insert(changeset) do
          {:ok, user} ->
            {:noreply,
            socket
            |> put_flash(:info, "User created")
            |> push_patch(to: ~p"/?#{[id: user.id]}")}

          {:error, reason} ->
            IO.inspect(reason, label: "Reason")
            {:noreply,
            socket
            |> assign(:user_form, to_form(changeset, as: :user_form))
            |> put_flash(:error, "Err: User not created")}
        end
      {:error, message} ->
        {:noreply,
        socket
        # |> assign(:user_form, to_form(changeset, as: :user_form))
        |> put_flash(:error, message)}
    end
  end
end
