defmodule Mix.Tasks.Punkix.Init do
  use Mix.Task
  # alias Mix.Phoenix.Schema

  def run(argv) do
    IO.inspect(argv)

    {_generators, _, _} =
      OptionParser.parse(argv,
        switches: [live: :keep, html: :keep, context: :keep, schema: :keep]
      )

    # for gen_live <- Keyword.get_values(generators, :live) do
    # end
  end
end
