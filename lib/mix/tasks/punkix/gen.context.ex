defmodule Mix.Tasks.Punkix.Gen.Context do
  use Mix.Task

  use Punkix
  use Punkix.Patches.Schema
  patch(Mix.Tasks.Phx.Gen.Context)

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Context).run(args)
end
