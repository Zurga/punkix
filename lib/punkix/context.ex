defmodule Punkix.Context do
  alias TypedEctoSchema.EctoTypeMapper

  def context_fun_args(schema), do: context_fun_args("", schema)

  def context_fun_args(argument, schema) do
    Enum.map_join(schema.attrs, ", ", &elem(&1, 0))
    |> maybe_prepend(argument)
  end

  def context_fun_spec(schema), do: context_fun_spec("", schema)

  def context_fun_spec(argument, schema) do
    required_fields = Enum.map(Mix.Phoenix.Schema.required_fields(schema), &elem(&1, 0))

    Enum.map_join(
      schema.types,
      ", ",
      fn
        {_name, {:enum, [values: values]}} ->
          Enum.map_join(values, " | ", &inspect(&1))

        {name, type} ->
          EctoTypeMapper.type_for(type, nil, nil, null: name in required_fields)
          |> Macro.to_string()
      end
    )
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

    schema.attrs
    |> Enum.map_join(", ", &inspect(Map.get(params, elem(&1, 0))))
    |> maybe_prepend(argument)
  end

  def invalid_args_to_params(schema, fun), do: invalid_args_to_params("", schema, fun)

  def invalid_args_to_params(argument, schema, _fun) do
    Enum.map_join(schema.attrs, ", ", fn _ -> "nil" end)
    |> maybe_prepend(argument)
  end

  def spec_alias(module), do: Module.split(module) |> Enum.reverse() |> hd()

  defp maybe_prepend("", argument), do: argument
  defp maybe_prepend(args, ""), do: args
  defp maybe_prepend(other_args, argument), do: "#{argument}, #{other_args}"
end
