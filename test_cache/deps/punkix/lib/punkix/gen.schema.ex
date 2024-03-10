defmodule Punkix.Gen.Schema do
  use Punkix.Patcher,
    wrap: [{Mix.Tasks.Phx.Gen.Schema, :build, :patch_schema}]

  def patch_schema(schema) do
    schemas_path = Path.join(Path.dirname(schema.file), "schemas")

    schemas_path
    |> File.mkdir()

    %{schema | file: Path.join(schemas_path, Path.basename(schema.file))}
    |> IO.inspect()

    raise "Schema"
  end
end
