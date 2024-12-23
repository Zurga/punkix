defmodule Punkix.Repo do
  import Ecto.Query, except: [preload: 2]
  import Phoenix.PubSub, only: [broadcast: 3]

  def authorize(condition), do: validate(condition, :unauthorized)

  @doc """
  Apply a filter to a query.
  """
  def filter(query, struct, filter) do
    # The top level of the query is always an AND condition
    conditions = build_and(struct, filter) || []
    from(q in query, where: ^conditions)
  end

  def nil_to_error(result) do
    case result do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  def validate(true, _), do: :ok
  def validate(false, reason), do: {:error, reason}

  def with_assocs(struct, assocs) do
    for {key, assoc_struct} <- assocs, reduce: %{} do
      acc ->
        if not is_nil(assoc_struct) do
          Ecto.build_assoc(assoc_struct, key, acc)
        else
          acc
        end
    end
    |> then(&if(map_size(&1), do: struct, else: &1))
  end

  def maybe_broadcast(ok_or_error, type, pubsub, topic_fun \\ &schema_topic/1)

  def maybe_broadcast({:error, _} = result, _type, _pubsub, _topic_fun), do: result

  def maybe_broadcast({:ok, schema}, type, pubsub, topic_fun),
    do: broadcast(pubsub, topic_fun.(schema), {type, schema})

  def maybe_broadcast(schema, type, pubsub, topic_fun),
    do: broadcast(pubsub, topic_fun.(schema), {type, schema})

  defp schema_topic(schema), do: apply(schema, :__schema__, [:source])

  defmacro __using__(opts) do
    # Copied from Sasa Juric's medium posts where he describes their Core module
    # https://medium.com/very-big-things/towards-maintainable-elixir-the-anatomy-of-a-core-module-b7372009ca6d
    quote do
      use Ecto.Repo, unquote(opts)
      defdelegate filter(query, struct, filter), to: Punkix.Repo

      def fetch_one(query), do: nil_to_error(one(query))
      def fetch_one(schema, id), do: nil_to_error(get(schema, id))

      def fetch_by(schema, condition, opts \\ []),
        do: nil_to_error(get_by(schema, condition, opts))

      def maybe_preload(result, nil), do: result

      def maybe_preload({:ok, struct}, preloads), do: {:ok, preload(struct, preloads)}
      def maybe_preload({:error, _} = result, _), do: result

      def maybe_preload(structs, preloads) when is_list(structs),
        do: for(result <- structs, do: maybe_preload(result, preloads))

      def maybe_preload(struct, preloads), do: preload(struct, preloads)

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

      defdelegate authorize(condition), to: Punkix.Repo
      defdelegate nil_to_error(result), to: Punkix.Repo
      defdelegate validate(valid, reason), to: Punkix.Repo
      defdelegate with_assocs(struct, assocs), to: Punkix.Repo
      defdelegate maybe_broadcast(schema, type, pubsub, topic_fun), to: Punkix.Repo
    end
  end

  # Building a group of AND-connected conditions
  defp build_and(struct, filter) do
    Enum.reduce(filter, nil, fn
      {k, v}, nil ->
        build_condition(struct, k, v)

      {k, v}, conditions ->
        dynamic([c], ^build_condition(struct, k, v) and ^conditions)
    end)
  end

  # Building a group of OR-connected conditions
  defp build_or(struct, filter) do
    Enum.reduce(filter, nil, fn
      filter, nil ->
        build_and(struct, filter)

      filter, conditions ->
        dynamic([c], ^build_and(struct, filter) or ^conditions)
    end)
  end

  defp build_condition(struct, field_or_operator, filter)

  defp build_condition(struct, "$or", filter),
    do: build_or(struct, filter)

  defp build_condition(struct, field, filter) when is_binary(field) do
    allowed_fields = struct.filter_fields()

    if allowed_fields == :all or field in allowed_fields do
      build_condition(struct, String.to_existing_atom(field), filter)
    end
  end

  defp build_condition(_struct, field, value)
       when is_atom(field),
       do: dynamic([c], field(c, ^field) == ^value)
end
