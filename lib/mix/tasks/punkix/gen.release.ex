defmodule Mix.Tasks.Punkix.Gen.Release do
  @moduledoc false
  use Mix.Task
  use Punkix
  patch(Mix.Tasks.Phx.Gen.Release)

  wrap(Mix.Tasks.Phx.Gen.Release, :paths, 0, :add_punkix)

  def add_punkix(paths) do
    List.insert_at(paths, 1, :punkix)
  end

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Release).run(args |> IO.inspect())
end
