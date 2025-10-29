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
  import Punkix
  alias Punkix.Schema.Assoc

  defmacro __using__(_) do
    quote do
      alias Mix.Tasks.Phx.Gen.Schema
      patch(Mix.Tasks.Phx.Gen.Schema)
      wrap(Mix.Tasks.Phx.Gen.Schema, :build, 3, :patch_schema)
      wrap(Mix.Tasks.Phx.Gen.Schema, :copy_new_files, 3, :inject_assocs)

      defdelegate patch_schema(schema), to: Punkix.Patches.Schema
      defdelegate inject_assocs(schema), to: Punkix.Patches.Schema
    end
  end

  def patch_schema(schema) do
    # __MODULE__.patch_schema(schema)

    schema
    |> set_path()
    |> set_module_name()
    |> Map.put(:scope, nil)
    # |> Map.put(:plural, Exflect.pluralize(schema.singular))
    |> Punkix.Schema.set_assocs()
  end

  def inject_assocs(schema) do
    Mix.Task.run("compile")
    [lib, app_name | _rest] = Path.split(schema.file)

    for %{reverse: reverse} = assoc when not is_nil(reverse) <-
          Punkix.Schema.normal_assocs(schema) do
      module = Module.concat([Macro.camelize(app_name), "Schemas", assoc.alias])
      assoc_file = Path.join([lib, app_name, assoc.path])
      assoc_string = Assoc.reverse_format(assoc, schema)
      reverse_field = String.to_atom(assoc.reverse)

      with {:module, _} <- Code.ensure_compiled(module) do
        assocs = module.__schema__(:associations)

        case Enum.find(assocs, &(&1 == reverse_field)) do
          ^reverse_field ->
            IO.puts("Nothing to inject for #{reverse_field}")

          nil ->
            inject_code(assoc_string, assoc_file, fn
              # Single field
              {node, schema_meta, [name, [{{_, _, [:do]} = do_block, children}]]}, to_add
              when node in ~w/schema typed_schema/a ->
                new = maybe_merge_blocks(children, to_add)
                {:typed_schema, schema_meta, [name, [{do_block, new}]]}

              _, _ ->
                nil
            end)

            Punkix.inject_after_module_definition(
              "alias #{Mix.Phoenix.base()}.Schemas.#{inspect(schema.alias)}",
              assoc_file
            )
        end
      end
    end

    schema
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
