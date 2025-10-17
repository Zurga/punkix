defmodule <%= @app_module %>.Schema do
  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
     
      defimpl Phoenix.HTML.Safe, for: __MODULE__ do
        defdelegate to_iodata(struct), to: <%= @app_module %>.Schema, as: :join_primary_keys
      end

      defimpl String.Chars, for: __MODULE__ do
        defdelegate to_string(struct), to: <%= @app_module %>.Schema, as: :join_primary_keys
      end
    end
  end

  def join_primary_keys(struct) do
    struct.__struct__.__schema__(:primary_key)
    |> Enum.map_join(",", &Map.get(struct, &1) |> to_string())
  end
end
