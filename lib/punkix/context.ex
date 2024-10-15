defmodule Punkix.Context do
  alias TypedEctoSchema.EctoTypeMapper

  def context_fun_args(schema), do: context_fun_args("", schema)

  def context_fun_args(argument, schema) do
    "#{schema.singular}_attrs"
    |> maybe_prepend(argument)
  end

  # TODO add fixtures in tests

  def build_assocs(schema) do
    Enum.map_join(schema.assocs, ", ", fn assoc ->
      _struct_name = String.downcase(assoc.schema)
      "#{assoc.reverse}: #{assoc.field}"
    end)
  end

  def assoc_fixtures(schema) do
    base_app = Module.split(schema.module) |> Enum.at(0)

    required_assocs(schema)
    |> Enum.map_join("\n", fn assoc ->
      context = String.split(assoc.alias, ".") |> Enum.at(0)
      "import #{base_app}.#{context}Fixtures"
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

  def context_fun_spec(%{assocs: _assocs} = schema, :create) do
    struct_args =
      required_assocs(schema)
      |> Enum.map_join(",", &"#{&1.schema}.t()")

    context_fun_spec(struct_args, schema)
  end

  def context_fun_spec(schema), do: context_fun_spec("", schema)

  def context_fun_spec(argument, schema) do
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
    |> then(&"%{#{&1}}")
    |> maybe_prepend(argument)
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

  def maybe_prepend("", argument), do: argument
  def maybe_prepend(args, ""), do: args
  def maybe_prepend(other_args, argument), do: "#{argument}, #{other_args}"
end
