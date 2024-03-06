defmodule Punkix.Context do
  alias TypedEctoSchema.EctoTypeMapper

  def context_fun_args(schema) do
    Enum.map_join(schema.attrs, ", ", &elem(&1, 0))
  end

  def context_fun_spec(schema) do
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
  end

  def args_to_params(schema, fun) do
    params = schema.params[fun]

    schema.attrs
    |> Enum.map_join(", ", &inspect(Map.get(params, elem(&1, 0))))
  end

  def spec_alias(module), do: Module.split(module) |> Enum.reverse() |> hd()
end
