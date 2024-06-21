defmodule Punkix.Repo do
  defmacro __using__(opts) do
    # Copied from Sasa Juric's medium posts where he describes their Core module
    # https://medium.com/very-big-things/towards-maintainable-elixir-the-anatomy-of-a-core-module-b7372009ca6d
    quote do
      use Ecto.Repo, unquote(opts)

      def fetch_one(query), do: nil_to_error(one(query))
      def fetch_one(schema, id), do: nil_to_error(get(schema, id))
      def fetch_by(schema, condition, opts \\ []), do: nil_to_error(get_by(schema, condition, opts))

      def validate(true, _), do: :ok
      def validate(false, reason), do: {:error, reason}

      def authorize(condition), do: validate(condition, :unauthorized)

      def transact(fun, opts \\ []) do
        transaction(
          fn repo ->
            Function.info(fun, :arity)
            |> case do
              {:arity, 0} -> fun.()
              {:arity, 1} -> fun.(repo)
            end
            |> case do
              {:ok, result} -> result
              {:error, reason} -> repo.rollback(reason)
            end
          end,
          opts
        )
      end

      defp nil_to_error(result) do
        case result do
          nil -> {:error, :not_found}
          record -> {:ok, record}
        end
      end
    end
  end
end
