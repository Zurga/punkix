defmodule Mix.Tasks.Punkix.Gen.Json do
  @moduledoc false
  use Mix.Task
  use Punkix

  use Punkix.Patches.Schema

  patch(Mix.Tasks.Phx.Gen.Context)

  wrap(Mix.Tasks.Phx.Gen.Json, :copy_new_files, 3, :add_watchers)
  def run(args), do: patched(Mix.Tasks.Phx.Gen.Json).run(args)
end
