defmodule Punkix.Schema do
  defmodule Assoc do
    @moduledoc """
    Describes an assoc given to a generator and will parse the input string. Based on the field given,
    a choice is made between a `belongs_to`, `has_one` and `has_many` association. 

    The following rules specify which is chosen in which situation:
      1. [name]_id -> `belongs_to`
      2. [singular_name] -> `has_one`
      3. [pluralized_name] -> `has_many`

    So for example, `post_id` becomes `belongs_to` and `post` will be `has_one`.

    Extra information for a `references` field
    can be given in a generator is the following:
     - reverse
     - through, for `has_one` and `has_many`
     - foreign_key
     - on_replace, defaults to `:update` 
     - on_delete, defaults to `:delete`
     
    They can be specified in the following format: key;value.

    # Examples
    `mix punkix.gen.context Persons Person persons name:string articles:references:articles,reverse:Articles.Article.writer,foreign_key:writer_id
    `mix punkix.gen.context Articles Article articles title:string content:string writer_id:references:persons,reverse:Persons.Person.articles,on_replace:delete
    """

    defstruct [
      :alias,
      :field,
      :key,
      :assoc_table,
      :assoc_fun,
      :schema,
      :foreign_key,
      :on_replace,
      :on_delete,
      :required,
      :reverse,
      :context,
      :plural
    ]

    def new({field, key, plural, s}) do
      {assoc_fun, field} =
        cond do
          Punkix.Schema.is_belongs_to?(key) ->
            {:belongs_to, to_string(field) |> String.replace("_id", "") |> String.to_atom()}

          true ->
            {:"has_#{one_or_many(key)}", field}
        end

      [references | opts] = String.split(to_string(s), ",")
      assoc_table = String.split(references, ":") |> Enum.at(-1)

      context =
        Punkix.Schema.find_key(opts, :reverse)
        |> String.split(".")
        |> Enum.at(0)

      {alias, reverse} =
        Punkix.Schema.find_key(opts, :reverse, "")
        |> String.split(".")
        |> Enum.reduce({"", nil}, fn input, {alias, reverse} ->
          if String.capitalize(input) == input do
            alias =
              if alias == "" do
                input
              else
                "#{alias}.#{input}"
              end

            {alias, reverse}
          else
            {alias, input}
          end
        end)

      foreign_key = String.to_atom(Punkix.Schema.find_key(opts, :foreign_key))

      on_replace =
        String.to_atom(
          Punkix.Schema.find_key(opts, :on_replace, defaults(assoc_fun, :on_replace))
        )

      required = !!Punkix.Schema.find_key(opts, :required, false)

      %__MODULE__{
        key: key,
        assoc_table: assoc_table,
        assoc_fun: assoc_fun,
        field: field,
        alias: alias,
        schema: (alias && String.split(alias, ".") |> Enum.at(-1)) || "",
        foreign_key: foreign_key,
        on_replace: on_replace,
        required: required,
        reverse: reverse,
        context: context,
        plural: assoc_table
      }
    end

    def format(assoc) do
      args =
        [
          inspect(assoc.field),
          assoc.schema,
          on_replace: assoc.on_replace,
          foreign_key: assoc.foreign_key
        ]
        |> Enum.filter(fn
          {_k, nil} -> false
          _ -> true
        end)
        |> Enum.map_join(
          ", ",
          fn
            atom when is_atom(atom) ->
              inspect(atom)

            {k, v} when is_atom(v) ->
              "#{k}: #{inspect(v)}"

            {k, v} ->
              "#{k}: #{v}"

            binary when is_binary(binary) ->
              binary
          end
        )

      "#{assoc.assoc_fun} #{args}"
    end

    defp one_or_many(key) do
      if key |> to_string() |> Exflect.plural?() do
        "many"
      else
        "one"
      end
    end

    def defaults(:has_one, option) do
      case option do
        :on_replace -> "update"
        :on_delete -> "nothing"
      end
    end

    def defaults(:has_many, option) do
      case option do
        :on_replace -> "delete"
        :on_delete -> "nothing"
      end
    end

    def defaults(:belongs_to, option) do
      case option do
        :on_replace -> "update"
        :on_delete -> raise "belongs_to does not have an on_delete option"
      end
    end
  end

  def set_assocs(%{assocs: assocs} = schema) do
    %{schema | assocs: Enum.map(assocs, &Punkix.Schema.Assoc.new/1)}
  end

  def format_assocs(schema) do
    Enum.map_join(schema.assocs, "\n", &Assoc.format/1)
  end

  def assoc_aliasses(schema) do
    Enum.map_join(schema.assocs, ",", fn assoc ->
      assoc.alias
    end)
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

  def optional_fields(schema) do
    field =
      schema.optionals
      |> Enum.map(&elem(&1, 0))

    assoc_fields =
      belongs_assocs(schema)
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
