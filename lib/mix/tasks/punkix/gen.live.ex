defmodule Mix.Tasks.Punkix.Gen.Live do
  use Mix.Task
  use Punkix

  use Punkix.Patcher
  use Punkix.Patches.Schema
  import PunkixWeb.FormUtils
  alias Mix.Phoenix.Schema
  alias Mix.Phoenix.Context

  patch(Mix.Tasks.Phx.Gen.Context)
  replace(Mix.Tasks.Phx.Gen.Live, :files_to_be_generated, 1, :files_to_be_generated)

  replace(Mix.Tasks.Phx.Gen.Live, :inputs, 1, :inputs)

  @type_input_map %{
    ~w[integer float decimal]a => "NumberInput",
    ~w[boolean]a => "Checkbox",
    ~w[array enum]a => "Select",
    ~w[datetime naive_datetime utc_datetime]a => "DateTimeInput",
    ~w[date]a => "DateInput",
    ~w[time]a => "TimeInput",
    ~w[string]a => "TextInput"
  }

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Live).run(args)

  def files_to_be_generated(%Context{schema: schema, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)
    test_prefix = Mix.Phoenix.web_test_path(context_app)
    web_path = to_string(schema.web_path)
    live_subdir = "#{schema.singular}_live"
    web_live = Path.join([web_prefix, "live", web_path, live_subdir])
    test_live = Path.join([test_prefix, "live", web_path])

    [
      {:eex, "show.ex", Path.join(web_live, "show.ex")},
      {:eex, "index.ex", Path.join(web_live, "index.ex")},
      {:eex, "schema_component.ex", Path.join(web_live, "#{schema.singular}_component.ex")},
      {:eex, "index.sface", Path.join(web_live, "index.sface")},
      {:eex, "show.sface", Path.join(web_live, "show.sface")},
      {:eex, "live_test.exs", Path.join(test_live, "#{schema.singular}_live_test.exs")}
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
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.join(", ")
    |> case do
      "" -> ""
      aliases -> "alias Surface.Components.Form.{#{aliases}}"
    end
  end

  @doc false
  def inputs(%Schema{} = schema) do
    schema.attrs
    |> Enum.reject(fn
      {_, {:references, _}} ->
        true

      {_key, type} ->
        type == :map
    end)
    |> Enum.map(fn
      {key, {:array, _} = type} ->
        ~s"""
        <Select
          field={#{inspect(key)}}
          multiple
          label="#{label(key)}"
          options={#{inspect(default_options(type))}}
        />
        """

      {key, {:enum, _}} ->
        ~s"""
        <Select
          field={#{inspect(key)}}
          label="#{label(key)}"
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
  defp rename_to_sface(string), do: String.replace(string, "html.heex", "sface")
end
