defmodule Mix.Tasks.Punkix.Gen.Json do
  @moduledoc false
  use Mix.Task
  use Punkix

  use Punkix.Patches.Schema

  patch(Mix.Tasks.Phx.Gen.Context)

  def run(args) do
    Mix.Task.run("compile")
    patched(Mix.Tasks.Phx.Gen.Json).run(args)
  end
end
