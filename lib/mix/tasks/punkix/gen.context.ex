defmodule Mix.Tasks.Punkix.Gen.Context do
  use Mix.Task

  use Punkix
  use Punkix.Patches.Schema
  patch(Mix.Tasks.Phx.Gen.Context)

  def inject_assocs(schema), do: Mix.Tasks.Punkix.Gen.Schema.inject_assocs(schema)

  def run(args) do
    Mix.Task.run("compile")
    patched(Mix.Tasks.Phx.Gen.Context).run(args)
  end
end
