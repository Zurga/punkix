defmodule Mix.Tasks.Punkix.Gen.Auth do
  use Mix.Task

  def run(args) do
    Mix.Tasks.Phx.Gen.Auth.run(args)
  end
end
