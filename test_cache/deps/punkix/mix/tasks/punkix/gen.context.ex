defmodule Mix.Tasks.Punkix.Gen.Context do
  use Mix.Task

  alias Mix.Tasks.Phx.Gen
  alias Mix.Tasks.Punkix.Gen.Schema

  def run(args) do
    {context, schema} = Gen.Context.build(args)
    schema = Schema.patch(schema, context.dir)

    context = %{context | schema: schema, dir: nil}
    binding = [context: context, schema: schema]
    paths = Mix.Phoenix.generator_paths()

    context
    |> Gen.Context.copy_new_files(paths, binding)
    |> Gen.Context.print_shell_instructions()
  end
end
