defmodule Punkix.Schema do
  alias Punkix.Schema.Assoc

  def set_assocs(%{assocs: assocs} = schema) do
    %{schema | assocs: Enum.map(assocs, &Assoc.new/1)}
  end

  def format_assocs(schema) do
    Enum.map_join(schema.assocs, "\n", &Assoc.format/1)
  end

  def new_assocs(schema) do
    ones =
      schema
      |> one_assocs()
      |> Enum.map_join(", ", &"#{&1.field}: nil")

    many =
      schema
      |> many_assocs()
      |> Enum.map_join(", ", &"#{&1.field}: []")

    [ones, many]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(", ")
  end

  def assoc_aliases(schema) do
    Enum.flat_map(schema.assocs, fn
      %{assoc_fun: :many_to_many} = assoc ->
        [assoc.alias, assoc.through]

      assoc ->
        [assoc.alias]
    end)
    |> Enum.uniq()
    |> Enum.join(", ")
  end

  def find_key(opts_string, key, default \\ "nil")

  def find_key(opts_string, key, default) when is_binary(opts_string) do
    opts =
      opts_string
      |> to_string()
      |> String.split(",")

    find_key(opts, key, default)
  end

  def find_key(opts, key, default) when is_list(opts) do
    key = to_string(key)

    opts
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.find([nil, default], &(Enum.at(&1, 0) == key))
    |> Enum.at(1)
  end

  def is_belongs_to?(key) do
    key |> to_string() |> String.ends_with?("_id")
  end

  def belongs_assocs(schema) do
    for %{assoc_fun: :belongs_to} = assoc <- schema.assocs do
      assoc
    end
  end

  def one_assocs(schema) do
    Enum.filter(schema.assocs, &(&1.assoc_fun in ~w/belongs_to has_one/a))
  end

  def many_assocs(schema) do
    Enum.filter(schema.assocs, &(&1.assoc_fun in ~w/many_to_many has_many/a))
  end

  def optional_fields(schema) do
    field =
      schema.optionals
      |> Enum.map(&elem(&1, 0))

    assoc_fields =
      schema.assocs
      |> Enum.reject(& &1.required)
      |> Enum.map(& &1.key)

    field ++ assoc_fields
  end

  def required_fields(schema) do
    fields =
      Mix.Phoenix.Schema.required_fields(schema)
      |> Enum.map(&elem(&1, 0))

    assoc_fields =
      belongs_assocs(schema)
      |> Enum.filter(& &1.required)
      |> Enum.map(& &1.key)

    fields ++ assoc_fields
  end
end
