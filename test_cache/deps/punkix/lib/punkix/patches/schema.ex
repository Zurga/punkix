defmodule Punkix.Patches.Schema do
  defmacro __using__(_) do
    quote do
      alias Mix.Tasks.Phx.Gen
      wrap(Gen.Schema, :build, 3, :patch_schema)

      def patch_schema(schema) do
        schema
        |> set_path()
        |> set_module_name()
        |> IO.inspect(label: :schema)
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
  end
end
