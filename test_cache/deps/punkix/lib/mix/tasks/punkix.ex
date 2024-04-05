defmodule Mix.Tasks.Punkix do
  use Mix.Task
  use Punkix.Patcher
  alias Mix.Tasks.Phx.New
  export(New, :maybe_cd, 2)

  def run(argv) do
    Mix.Tasks.Phx.New.run(argv, Punkix.Generator.Single, :base_path)
  end
end
