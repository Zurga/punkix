defmodule Mix.Tasks.Punkix.Gen.Schema do
  use Mix.Task
  use Punkix
  use Punkix.Patches.Schema
  alias Mix.Tasks.Phx.Gen.Schema

  def run(args), do: patched(Gen.Schema).run(args)
end
