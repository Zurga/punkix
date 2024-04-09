defmodule Mix.Tasks.Punkix do
  use Mix.Task

  def run(argv) do
    Mix.Tasks.Phx.New.run(argv, Punkix.Generator.Single, :base_path)
  end
end
