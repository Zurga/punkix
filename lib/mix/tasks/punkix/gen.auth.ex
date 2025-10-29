defmodule Mix.Tasks.Punkix.Gen.Auth do
  use Mix.Task
  use Punkix
  # use Punkix.Patches.Schema
  alias Mix.Tasks.Phx.Gen.Auth
  import Punkix.Web.FormUtils
  # Remove this after Phoenix 1.7.13 is available
  patch(Mix.Tasks.Phx.Gen.Context)
  patch(Auth.Injector)

  wrap(Auth.Injector, :app_layout_menu_code_to_inject, 3, :menu_code)
  wrap(Auth.Injector, :router_plug_name, 1, :fetch_current_user)
  wrap(Auth, :generator_paths, 0, :add_punkix)
  wrap(Auth, :files_to_be_generated, 1, :files_to_be_generated)
  replace(Auth, :validate_args!, 1, :validate_args!)
  replace(Auth, :maybe_inject_router_import, 2, :inject_router_import)
  replace(Auth, :maybe_inject_scope_config, 2, :do_nothing)
  # replace(Auth, :maybe_inject_router_plug, 2, :do_nothing)
  replace(Auth, :maybe_inject_app_layout_menu, 2, :do_nothing)
  replace(Auth, :inject_routes, 3, :inject_routes)

  wrap(Auth, :copy_new_files, 3, :add_watchers)
  # replace_module(Mix.Tasks.Phx.Gen.Schema, Mix.Tasks.Punkix.Gen.Schema)

  def run(args) do
    Mix.Task.run("compile")
    patched(Auth).run(args)
  end

  def fetch_current_user(_binding) do
    ":fetch_current_user"
  end

  def do_nothing(context, _) do
    context
  end

  @add_schema_path ~w/schema.ex schema_token.ex/
  @rejected_files ["scope.ex"]
  def files_to_be_generated(files) do
    Enum.map(files, fn
      {type, file, path} when file in @add_schema_path ->
        path = Path.split(path)
        {type, file, Path.join(List.insert_at(path, 2, "schemas"))}

      {_, file, _} when file in @rejected_files ->
        nil

      other ->
        other
    end)
    |> Enum.reject(&is_nil/1)
  end

  def inject_router_import(context, binding) do
    web_prefix = Mix.Phoenix.web_path(context.context_app)
    file_path = Path.join(web_prefix, "router.ex")
    web_module = :"#{inspect(context.web_module)}"

    inject_after_module_definition(file_path, "import #{binding[:auth_module]}")

    context
  end

  def inject_routes(%{context_app: ctx_app} = context, paths, binding) do
    web_prefix = Mix.Phoenix.web_path(ctx_app)
    file_path = Path.join(web_prefix, "router.ex")

    paths
    |> Mix.Phoenix.eval_from("priv/templates/phx.gen.auth/routes.ex", binding)
    |> inject_code(file_path, fn
      {:preprocess_using, args, [alias, [{{:__block__, meta, [:do]}, routes}]]}, to_add ->
        new =
          maybe_merge_blocks(routes, to_add)

        {:preprocess_using, args, [alias, [{{:__block__, meta, [:do]}, new}]]}

      quoted, _ ->
        nil
    end)

    context
  end

  def validate_args!([_, _, _ | _]), do: :ok
  def validate_args!(_), do: patched(Auth).raise_with_help("Invalid arguments")

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

  def menu_code({already_injected_str, html}) do
    {already_injected_str, String.replace(html, ~r/class="[a-zA-Z0-9:;_\.\s\(\)\[\]\-]*"/, "")}
  end
end
