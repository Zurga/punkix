defmodule Mix.Tasks.Punkix.Gen.Auth do
  use Mix.Task
  use Punkix
  use Punkix.Patches.Schema
  alias Mix.Tasks.Phx.Gen.Auth
  import PunkixWeb.FormUtils
  # Remove this after Phoenix 1.7.13 is available
  wrap(Auth, :generator_paths, 0, :add_punkix)
  replace(Auth, :maybe_inject_router_import, 2, :inject_router_import)

  def add_punkix(paths) do
    List.insert_at(paths, 1, :punkix)
  end

  def inject_router_import(context, binding) do
    web_prefix = Mix.Phoenix.web_path(context.context_app)
    file_path = Path.join(web_prefix, "router.ex")
    web_module = :"#{inspect(context.web_module)}"

    with {:ok, source} <- File.read(file_path),
         {:ok, code} <- Sourceror.parse_string(source) do
      new_source =
        Macro.postwalk(code, fn
          {:defmodule, module_meta,
           [
             {:__aliases__, _alias_meta, [^web_module, :Router]} = alias,
             [{{:__block__, do_block_meta, [:do]}, {:__block__, block_meta, block_ast}}]
           ]} ->
            import_line =
              {:import, block_meta,
               [{:__aliases__, [alias: false], [:"#{inspect(binding[:auth_module])}"]}]}

            {:defmodule, module_meta,
             [
               alias,
               [
                 {{:__block__, do_block_meta, [:do]},
                  {:__block__, block_meta, [import_line | block_ast]}}
               ]
             ]}

          other ->
            other
        end)
        |> Sourceror.to_string()

      File.write(file_path, new_source)
    end

    context
  end

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Auth).run(args)

  def inputs(fields) do
    Enum.map(fields, fn
      {_field, _label} = field_label -> field_label
      field -> {field, nil}
    end)
    |> Enum.map(fn {field, label} ->
      field_string = to_string(field)

      cond do
        String.contains?(field_string, "password") ->
          wrap_input(
            field,
            "PasswordInput",
            label
          )

        String.contains?(field_string, "email") ->
          wrap_input(field, "EmailInput", label)
      end
    end)
  end
end