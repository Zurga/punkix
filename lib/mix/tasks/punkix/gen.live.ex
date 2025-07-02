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

  def run(args), do: IO.inspect(patched(Mix.Tasks.Phx.Gen.Live)).run(args)

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

  def live_route_instructions(schema) do
    [
      ~s|scope "/#{schema.plural}" do\n|,
      ~s|  live "/", #{inspect(schema.alias)}Live.Index, :index\n|,
      ~s|  live "/new", #{inspect(schema.alias)}Live.Index, :new\n|,
      ~s|  live "/:id/edit", #{inspect(schema.alias)}Live.Index, :edit\n|,
      ~s|  live "/:id", #{inspect(schema.alias)}Live.Show, :show\n|,
      ~s|  live "/:id/show/edit", #{inspect(schema.alias)}Live.Show, :edit\n|,
      ~s|end|
    ]
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
    |> then(&if schema.assocs == [], do: &1, else: ["Select" | &1])
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.join(", ")
    |> case do
      "" -> ""
      aliases -> "alias Surface.Components.Form.{#{aliases}}"
    end
  end

  def inputs(schema) do
    attr_inputs(schema) ++
      (Punkix.Schema.belongs_assocs(schema)
       |> Enum.map(fn
         %{field: field, plural: plural, schema: assoc_schema} ->
           key = :"#{field}_id"
           singular = String.downcase(assoc_schema)

           input = """
           Select options={@#{plural} |> Enum.with_index(1) |> Enum.map(fn {#{singular}, index} -> {"#{assoc_schema} \#{index}", #{singular}.id} end)}
           """

           wrap_input(key, input)
       end))
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
