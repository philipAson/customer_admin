# CustomerAdmin

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To add mock data on your DB:

  * Start of with open a new terminal and run `iex -S mix`.
  * Then Create a set number of companies with `CustomerAdmin.Companies.generate_mock_companies(x)`, `x` is the amount of companies you would like to generate.
  * Now you are ready to Create some users with `CustomerAdmin.Users.create_mock_users(x)`.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
