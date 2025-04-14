defmodule Punkix.Context do
  alias TypedEctoSchema.EctoTypeMapper
  alias Punkix.Schema

  def create_args(schema) do
    schema_attrs(schema)
    |> add_opts(schema)
  end

  def update_args(schema),
    do:
      "#{schema.singular}_id, #{schema_attrs(schema)}"
      |> add_opts(schema)

  def store_args(schema),
    do: "#{schema.singular}, #{schema_attrs(schema)}, opts"

  def schema_attrs(schema) do
    "#{schema.singular}_attrs"
  end

  def assocs_context_aliasses(schema) do
    [base_app | _] = Module.split(schema.module)

    schema
    |> Schema.belongs_assocs()
    |> Enum.map(& &1.context)
    |> Enum.uniq()
    |> then(fn contexts ->
      base = "alias #{base_app}."
      maybe_group_aliasses(base, contexts)
    end)
  end

  # TODO add fixtures in tests
  def assocs_schema_aliasses(schema) do
    [base_app | _] = Module.split(schema.module)

    schema
    |> Schema.belongs_assocs()
    |> Enum.group_by(& &1.context)
    |> Enum.map_join("\n", fn {context, assocs} ->
      base = "alias #{base_app}.Schemas.#{context}."

      maybe_group_aliasses(base, assocs, & &1.schema)
    end)
  end

  defp maybe_group_aliasses(base, modules, map_fun \\ & &1)

  defp maybe_group_aliasses(_base, [], _map_fun), do: ""

  defp maybe_group_aliasses(base, [module], map_fun) do
    base <> map_fun.(module)
  end

  defp maybe_group_aliasses(base, modules, map_fun) do
    base <> "{#{Enum.map_join(modules, ", ", map_fun)}}"
  end

  def build_assocs(schema) do
    schema
    |> Schema.belongs_assocs()
    |> Enum.map_join(", ", fn assoc ->
      "#{assoc.reverse}: #{schema_attrs(schema)}[:#{assoc.field}]"
    end)
  end

  def assoc_fixtures(schema) do
    [base_app, _, schema_context | _] = Module.split(schema.module)

    required_assocs(schema)
    |> Enum.map_join("\n", fn %{context: context} = _assoc ->
      if context != schema_context do
        "  import #{base_app}.#{context}Fixtures"
      end
    end)
  end

  def required_assocs(schema) do
    for %{required: true} = assoc <- schema.assocs do
      assoc
    end
  end

  def required_assocs_as_arguments(schema) do
    for %{required: true} = assoc <- schema.assocs do
      assoc
    end
    |> Enum.map_join(",", & &1.field)
  end

  def context_fun_spec(schema), do: context_fun_spec("", schema)

  def context_fun_spec(%{assocs: _assocs} = schema, :create) do
    schema_spec = schema_spec_types(schema)

    belongs_to_assocs =
      schema
      |> Schema.belongs_assocs()
      |> assocs_spec()

    wrap_in_map([schema_spec, belongs_to_assocs])
  end

  def context_fun_spec(argument, schema) do
    schema
    |> schema_spec_types()
    |> wrap_in_map()
    |> maybe_prepend(argument)
  end

  defp wrap_in_map(input) when is_list(input) do
    input
    |> Enum.reject(&(is_nil(&1) or &1 == ""))
    |> Enum.join(", ")
    |> wrap_in_map()
  end

  defp wrap_in_map(input) when is_binary(input) do
    "%{#{input}}"
  end

  defp assocs_spec(assocs), do: Enum.map_join(assocs, ", ", &":#{&1.field} => #{&1.schema}.t()")

  defp schema_spec_types(schema) do
    required_fields = Enum.map(Mix.Phoenix.Schema.required_fields(schema), &elem(&1, 0))

    Enum.map_join(
      schema.types,
      ", ",
      fn {name, _} = type ->
        spec_type =
          case type do
            {_name, {:enum, [values: values]}} ->
              Enum.map_join(values, " | ", &inspect(&1))

            {name, type} ->
              EctoTypeMapper.type_for(type, nil, nil, null: name in required_fields)
              |> Macro.to_string()
          end

        "optional(:#{name}) => #{spec_type}"
      end
    )
  end

  def args_as_attributes(struct, schema), do: args_as_attributes("", struct, schema)

  def args_as_attributes(argument, struct, schema) do
    Enum.map_join(schema.attrs, ", ", &"#{struct}.#{elem(&1, 0)}")
    |> maybe_prepend(argument)
  end

  def args_to_params(schema, fun), do: args_to_params("", schema, fun)

  def args_to_params(argument, schema, fun) do
    params = schema.params[fun]

    params =
      schema.attrs
      |> Enum.map_join(", ", &"#{elem(&1, 0)}: #{inspect(Map.get(params, elem(&1, 0)))}")
      |> maybe_prepend(argument)

    "%{#{params}}"
  end

  def invalid_args_to_params(schema, fun), do: invalid_args_to_params("", schema, fun)

  def invalid_args_to_params(argument, schema, _fun) do
    schema.attrs
    |> Enum.map_join(", ", &"#{elem(&1, 0)}: nil")
    |> maybe_prepend(argument)
  end

  def spec_alias(module), do: Module.split(module) |> Enum.reverse() |> hd()

  def maybe_prepend(args, list) when is_list(list) do
    maybe_prepend(args, Enum.join(list, ", "))
  end

  def maybe_prepend("", argument), do: argument
  def maybe_prepend(args, ""), do: args
  def maybe_prepend(other_args, argument), do: "#{argument}, #{other_args}"

  def add_opts(_schema) do
    "opts \\\\ [preloads: nil]"
  end

  def add_opts(args, _schema) do
    args <> ", opts \\\\ [preloads: nil]"
  end
end
