defmodule Mix.Tasks.Punkix.Gen.Schema do
  use Mix.Task
  use Punkix
  use Punkix.Patches.Schema

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Schema).run(args)
end
