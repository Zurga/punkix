defmodule Mix.Tasks.Punkix.Gen.Schema do
  use Mix.Task

  alias Mix.Tasks.Phx.Gen

  def run(args) do
    schema = Gen.Schema.build(args, [])
    |> IO.inspect()
    |> patch("test")

    binding = [schema: schema]
    paths = Mix.Phoenix.generator_paths()

    schema
    |> Gen.Schema.copy_new_files(paths, binding)
    |> Gen.Schema.print_shell_instructions()
  end

  def patch(schema, dir) do
    schemas_path = Path.join(dir, "../schemas")

    schemas_path
    |> File.mkdir()

    %{schema | file: Path.join(schemas_path, Path.basename(schema.file))}
    end
end
