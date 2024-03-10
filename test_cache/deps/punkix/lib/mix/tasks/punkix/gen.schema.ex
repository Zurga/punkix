defmodule Mix.Tasks.Punkix.Gen.Schema do
  use Mix.Task

  use Punkix.Patcher

  wrap(Mix.Tasks.Phx.Gen.Schema, :build, 3, :patch_schema)

  alias Mix.Tasks.Phx.Gen

  def run(args), do: Gen.Schema.run(args)

  def patch_schema(schema) do
    schema
    |> set_path()
    |> set_module_name()
  end

  def set_module_name(schema) do
    module_name =
      Module.split(schema.module)
      |> List.insert_at(1, "Schemas")
      |> Module.concat()

    %{schema | module: module_name}
  end

  defp set_path(schema) do
    file_name = Path.basename(schema.file)

    [lib, app_name | rest] =
      Path.split(schema.file)

    [context | _] = rest
    context = (context != file_name && List.wrap(context)) || []

    schemas_path =
      Path.join([lib, app_name] ++ ["schemas"] ++ context)

    schemas_path
    |> File.mkdir()

    %{schema | file: Path.join(schemas_path, file_name)}
  end
end
