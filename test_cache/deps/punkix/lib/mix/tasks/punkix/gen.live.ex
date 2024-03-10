defmodule Mix.Tasks.Punkix.Gen.Live do
  use Mix.Task

  alias Mix.Tasks.Phx.Gen
  alias Mix.Phoenix.Schema

  use Punkix.Patcher

  wrap(
    Mix.Tasks.Phx.Gen.Live,
    :files_to_be_generated,
    1,
    :patch_files
  )

  replace(Mix.Tasks.Phx.Gen.Live, :inputs, 1, :inputs)

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
    |> IO.inspect()
  end

  defdelegate run(args), to: Mix.Tasks.Phx.Gen.Live
  defp rename_to_sface(string), do: String.replace(string, "html.heex", "sface")
  # @doc false
  # def run(args) do
  #   if Mix.Project.umbrella?() do
  #     Mix.raise(
  #       "mix punkix.gen.live must be invoked from within your *_web application root directory"
  #     )
  #   end

  #   {context, schema} =
  #     Gen.Context.build(args)
  #     |> Context.patch()

  #   Gen.Context.prompt_for_code_injection(context)

  #   binding = [
  #     context: context,
  #     schema: schema,
  #     inputs: inputs(schema),
  #     input_aliases: input_aliases(schema)
  #   ]

  #   paths =
  #     Mix.Phoenix.generator_paths()

  #   # Gen.Live.prompt_for_conflicts(context)

  #   Gen.Live.files_to_be_generated(context)
  #   |> IO.inspect(label: :only_new_eex)

  #   raise ""

  #   # context
  #   # |> copy_new_files(binding, paths)
  #   # |> Gen.Live.maybe_inject_imports()
  #   # |> Gen.Live.print_shell_instructions()
  # end

  # defp copy_new_files(%Context{} = context, binding, paths) do
  #   files = files_to_be_generated(context)

  #   binding =
  #     Keyword.merge(binding,
  #       assigns: %{
  #         web_namespace: inspect(context.web_module),
  #         gettext: true
  #       }
  #     )

  #   Mix.Phoenix.copy_from(paths, "priv/templates/phx.gen.live", binding, files)
  #   if context.generate?, do: Gen.Context.copy_new_files(context, paths, binding)

  #   context
  # end

  @type_input_map %{
    ~w[integer float decimal]a => "NumberInput",
    ~w[boolean]a => "Checkbox",
    ~w[array enum]a => "Select",
    ~w[datetime naive_datetime utc_datetime]a => "DateTimeInput",
    ~w[time]a => "TimeInput",
    ~w[string]a => "TextInput"
  }

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
    |> Enum.concat(~w[Field Label]a)
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
    |> Enum.reject(fn {_key, type} -> type == :map end)
    |> Enum.map(fn
      {_, {:references, _}} ->
        nil

      {key, :integer} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <NumberInput/>
        </Field>
        """

      {key, :float} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <NumberInput/>
        </Field>
        """

      {key, :decimal} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <NumberInput/>
        </Field>
        """

      {key, :boolean} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <Checkbox/>
        </Field>
        """

      {key, :text} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <TextInput/>
        </Field>
        """

      {key, :date} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <DateInput/>
        </Field>
        """

      {key, :time} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <TimeInput/>
        </Field>
        """

      {key, :utc_datetime} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <DateTimeInput/>
        </Field>
        """

      {key, :naive_datetime} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <DateTimeInput/>
        </Field>
        """

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

      {key, _} ->
        ~s"""
        <Field name={#{inspect(key)}}>
          <Label>#{label(key)}</Label>
          <TextInput field={#{inspect(key)}} label="#{label(key)}" />)
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
end
