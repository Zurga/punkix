defmodule Punkix.Patches.Schema do
  # TODO parse extra options in schema attrs to support:
  # belongs_to:
  # has_one
  # has_many

  # An example would be the following attrs:
  # Example of belongs_to
  # Comment comments body:text post_id:references:Post
  # Example of has_one
  # Comment comments body:text post:references:Post
  # Example of has_many
  # Comment comments body:text posts:references:Post

  defmacro __using__(_) do
    quote do
      alias Mix.Tasks.Phx.Gen.Schema
      wrap(Schema, :build, 3, :patch_schema)

      defdelegate patch_schema(schema), to: Punkix.Patches.Schema
    end
  end

  def patch_schema(schema) do
    # __MODULE__.patch_schema(schema)

    schema
    |> set_path()
    |> set_module_name()
    # |> Map.put(:plural, Exflect.pluralize(schema.singular))
    |> Punkix.Schema.set_assocs()
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
