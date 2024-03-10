defmodule Mix.Tasks.Punkix do
  use Mix.Task

  def run(argv) do
    Mix.Tasks.Phx.New.run(argv, Punkix.Generator.Single, :project_path)
  end
end
