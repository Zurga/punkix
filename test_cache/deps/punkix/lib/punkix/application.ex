defmodule Punkix.Application do
  use Application

  def start(_type, _args) do
    children = [
      Patch.Mock.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Punkix.Supervisor]

    Supervisor.start_link(children, opts)
    |> IO.inspect(label: :sup)
  end
end
