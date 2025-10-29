defmodule Mix.Tasks.Punkix.Gen.Live do
  @moduledoc false
  use Mix.Task
  use Punkix

  use Punkix.Patches.Schema
  import Punkix.Web.FormUtils
  alias Mix.Phoenix.Schema
  alias Mix.Phoenix.Context

  patch(Mix.Tasks.Phx.Gen.Context)
  replace(Mix.Tasks.Phx.Gen.Live, :files_to_be_generated, 1, :files_to_be_generated)
  replace(Mix.Tasks.Phx.Gen.Live, :live_route_instructions, 1)

  replace(Mix.Tasks.Phx.Gen.Live, :inputs, 1, :inputs)
  replace(Mix.Tasks.Phx.Gen.Live, :print_shell_instructions, 1, :inject_routes)
  wrap(Mix.Tasks.Phx.Gen.Live, :copy_new_files, 3, :add_watchers)

  @type_input_map %{
    ~w[integer float decimal]a => "NumberInput",
    ~w[boolean]a => "Checkbox",
    ~w[array enum]a => "Select",
    ~w[datetime naive_datetime utc_datetime]a => "DateTimeInput",
    ~w[date]a => "DateInput",
    ~w[time]a => "TimeInput",
    ~w[string]a => "TextInput"
  }

  def run(args) do
    Mix.Task.run("compile")
    patched(Mix.Tasks.Phx.Gen.Live).run(args |> IO.inspect(label: :args))
  end

  def files_to_be_generated(%Context{schema: schema, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)
    # test_prefix = Mix.Phoenix.web_test_path(context_app)
    web_path = to_string(schema.web_path)
    live_subdir = "#{schema.singular}_live"
    web_live = Path.join([web_prefix, "live", web_path, live_subdir])
    # test_live = Path.join([test_prefix, "live", web_path])

    integration_test_live =
      Path.join(["integration_test", "#{context_app}_web", "live", web_path])

    [
      {:eex, "assigns.ex", Path.join(web_live, "assigns.ex")},
      {:eex, "show.ex", Path.join(web_live, "show.ex")},
      {:eex, "index.ex", Path.join(web_live, "index.ex")},
      {:eex, "schema_component.ex", Path.join(web_live, "#{schema.singular}_component.ex")},
      {:eex, "index.sface", Path.join(web_live, "index.sface")},
      {:eex, "show.sface", Path.join(web_live, "show.sface")},
      # {:eex, "live_test.exs", Path.join(test_live, "#{schema.singular}_live_test.exs")}
      {:eex, "live_test.exs",
       Path.join(integration_test_live, "#{schema.singular}_live_test.exs")}
    ]
  end

  def inject_routes(context) do
    web_prefix = Mix.Phoenix.web_path(context.context_app)
    file_path = Path.join(web_prefix, "router.ex")
    web_module = :"#{inspect(context.web_module)}"

    # Check if the live generation requires access to the current user
    live_session_to_match =
      case Enum.filter(context.schema.assocs, & &1.is_current_user) do
        [] -> :default
        _ -> :require_authenticated_user
      end

    routes =
      live_route_instructions(context.schema)
      |> inject_code(file_path, fn
        {:live_session, live_meta,
         [{:__block__, block_meta, [:require_authenticated_user]} = authenticated | inner]},
        to_add ->
          [[{{:__block__, inner_meta, [:do]}, scopes}] | middle] = Enum.reverse(inner)
          new = maybe_merge_blocks(scopes, to_add)

          {:live_session, live_meta,
           [authenticated] ++ middle ++ [[{{:__block__, inner_meta, [:do]}, new}]]}

        _, _ ->
          nil
      end)
  end

  def live_route_instructions(schema) do
    """
    scope "/#{schema.plural}" do
      live "/", #{inspect(schema.alias)}Live.Index, :index
      live "/new", #{inspect(schema.alias)}Live.Index, :new
      live "/:id/edit", #{inspect(schema.alias)}Live.Index, :edit
      live "/:id", #{inspect(schema.alias)}Live.Show, :show
      live "/:id/show/edit", #{inspect(schema.alias)}Live.Show, :edit
    end
    """
  end

  def input_aliases(schema) do
    schema.attrs
    |> Enum.reject(fn
      {_, {:references, _}} ->
        true

      {_key, type} ->
        type == :map
    end)
    |> Enum.map(fn {_, type} ->
      Enum.find_value(@type_input_map, fn {types, name} ->
        type in types && name
      end)
    end)
    |> then(fn aliases ->
      if schema.assocs == [] do
        aliases
      else
        aliases ++
          Enum.map(schema.assocs, fn
            %{assoc_fun: fun} when fun in ~w/has_many many_to_many/a ->
              "MultipleSelect"

            _ ->
              "Select"
          end)
      end
    end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.join(", ")
    |> case do
      "" -> ""
      aliases -> "alias Surface.Components.Form.{#{aliases}}"
    end
  end

  def inputs(schema) do
    assoc_inputs =
      Enum.map(schema.assocs, fn
        %{assoc_fun: :belongs_to, field: field, plural: plural, schema: assoc_schema} ->
          key = :"#{field}_id"
          singular = String.downcase(assoc_schema)

          input = """
          Select options={@#{plural} |> Enum.with_index(1) |> Enum.map(fn {#{singular}, index} -> {"#{assoc_schema} \#{index}", #{singular}} end)}
          """

          wrap_input(key, input)

        %{assoc_fun: many, field: field, plural: plural, schema: assoc_schema}
        when many in ~w/has_many many_to_many/a ->
          """
          <.assoc_select field={@changeset[:#{field}]} options={@#{plural}} />
          """

          # wrap_input(key, input)
      end)

    attr_inputs(schema) ++ assoc_inputs
  end

  @doc false
  def attr_inputs(%Schema{attrs: attrs} = schema) do
    attrs
    |> Enum.reject(fn
      {_key, type} ->
        type == :map
    end)
    |> Enum.map(fn
      {key, {:array, _} = type} ->
        """
        <Select
          field={#{inspect(key)}}
          multiple
          options={#{inspect(default_options(type))}}
        />
        """

      {key, {:enum, _}} ->
        """
        <Select
          field={#{inspect(key)}}
          prompt="Choose a value"
          options={Ecto.Enum.values(#{inspect(schema.module)}, #{inspect(key)})}
        />
        """

      {key, type} ->
        input =
          Enum.find_value(@type_input_map, "<TextInput />", fn {types, name} ->
            type in types && name
          end)

        wrap_input(key, input)
    end)
  end

  defp default_options({:array, :string}),
    do: Enum.map([1, 2], &{"Option #{&1}", "option#{&1}"})

  defp default_options({:array, :integer}),
    do: Enum.map([1, 2], &{"#{&1}", &1})

  defp default_options({:array, _}), do: []

  def to_route(paths) do
    "~p\"/#{Enum.join(paths, "/")}\""
  end
end
