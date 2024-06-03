defmodule CustomerAdminWeb.Components.UserForm do
  import Phoenix.HTML.FormData

  def user_form(params \\ %{}) do
    changeset = CustomerAdmin.User.changeset(%CustomerAdmin.User{}, params)
    to_form(changeset, as: :user_form)
  end
end
