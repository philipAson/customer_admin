defmodule CustomerAdminWeb.Router do
  use CustomerAdminWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CustomerAdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CustomerAdminWeb do
    pipe_through :browser

    live "/", HomeLive
    # live "/new", HomeLive
    # live "/:id", HomeLive

    live "/home-lab", HomeLabLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", CustomerAdminWeb do
  #   pipe_through :api
  # end
end
