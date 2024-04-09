defmodule Mix.Tasks.Punkix.Gen.Live do
  use Mix.Task
  use Punkix

  use Punkix.Patcher
  use Punkix.Patches.Schema
  alias Mix.Phoenix.Schema

  patch(Mix.Tasks.Phx.Gen.Context)
  wrap(Mix.Tasks.Phx.Gen.Live, :files_to_be_generated, 1, :patch_files)

  replace(Mix.Tasks.Phx.Gen.Live, :inputs, 1, :inputs)

  @type_input_map %{
    ~w[integer float decimal]a => "NumberInput",
    ~w[boolean]a => "Checkbox",
    ~w[array enum]a => "Select",
    ~w[datetime naive_datetime utc_datetime]a => "DateTimeInput",
    ~w[time]a => "TimeInput",
    ~w[string]a => "TextInput"
  }

  def run(args), do: patched(Mix.Tasks.Phx.Gen.Live).run(args)

  def patch_files(files) do
    Enum.flat_map(files, fn {type, template, path} = file ->
      cond do
        String.ends_with?(template, "html.heex") ->
          [{type, rename_to_sface(template), rename_to_sface(path)}]

        template == "core_components.ex" ->
          []

        true ->
          [file]
      end
    end)
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
    |> Enum.concat(~w[Field Label ErrorTag]a)
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

        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <#{input} />
          <ErrorTag />
        </Field>
        """
    end)
  end

  defp label(key), do: Phoenix.Naming.humanize(to_string(key))

  defp default_options({:array, :string}),
    do: Enum.map([1, 2], &{"Option #{&1}", "option#{&1}"})

  defp default_options({:array, :integer}),
    do: Enum.map([1, 2], &{"#{&1}", &1})

  defp default_options({:array, _}), do: []
  defp rename_to_sface(string), do: String.replace(string, "html.heex", "sface")
end
