defmodule Punkix.Schema.Assoc do
  @moduledoc """
  Describes an assoc given to a generator and will parse the input string. 

  Extra information for a `references` field
  can be given in a generator is the following:
   - type (required), `belongs_to`, `has_one`, `has_many`, `many_to_many`
   - reverse
   - through, for `has_one` and `has_many`
   - join_through, for `many_to_many`
   - foreign_key
   - on_replace, defaults to `:update` 
   - on_delete, defaults to `:delete`
   
  They can be specified in the following format: key;value.

  # Examples
  `mix punkix.gen.context Persons Person persons name:string articles:references:articles,type:belongs_to,reverse:Articles.Article.writer,foreign_key:writer_id
  `mix punkix.gen.context Articles Article articles title:string content:string writer_id:references:persons,reverse:Persons.Person.articles,on_replace:delete
  """

  alias Punkix.Schema

  defstruct [
    :alias,
    :assoc_fun,
    :assoc_table,
    :context,
    :field,
    :foreign_key,
    :key,
    :on_delete,
    :on_replace,
    :plural,
    :required,
    :reverse,
    :schema,
    :through
  ]

  def new({field, key, _plural, s}) do
    [references | opts] = String.split(to_string(s), ",")

    assoc_fun = Schema.find_key(opts, :type) |> String.to_atom()

    if is_nil(assoc_fun) do
      raise "Type should be specified for association #{field} #{key} #{opts}"
    end

    field =
      if assoc_fun == :belongs_to do
        to_string(key) |> String.replace("_id", "") |> String.to_atom()
      else
        field
      end

    assoc_table = String.split(references, ":") |> Enum.at(-1)

    context =
      Schema.find_key(opts, :reverse)
      |> String.split(".")
      |> Enum.at(0)

    {alias, reverse} =
      Schema.find_key(opts, :reverse, "")
      |> String.split(".")
      |> Enum.reduce({"", nil}, fn input, {alias, reverse} ->
        if :string.titlecase(input) == input do
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

    foreign_key = String.to_atom(Schema.find_key(opts, :foreign_key))

    on_replace =
      String.to_atom(Schema.find_key(opts, :on_replace, defaults(assoc_fun, :on_replace)))

    through = Schema.find_key(opts, :through)

    if assoc_fun == :many_to_many and is_nil(through) do
      raise "A many to many must set a through option"
    end

    schema =  (alias && String.split(alias, ".") |> Enum.at(-1)) || ""
    required = !!Schema.find_key(opts, :required, false)

    plural =
      case assoc_fun do
        :many_to_many -> schema |> String.downcase() |> Exflect.pluralize()
        :has_many -> field
        _ -> assoc_table
      end

    %__MODULE__{
      alias: alias,
      assoc_fun: assoc_fun,
      assoc_table: assoc_table,
      context: context,
      field: field,
      foreign_key: foreign_key,
      key: key,
      on_replace: on_replace,
      plural: plural,
      required: required,
      reverse: reverse,
      schema: schema,
      through: through
    }
  end

  def format(assoc) do
    through_alias = assoc.through |> String.split(".") |> Enum.at(-1)

    through =
      (assoc.assoc_fun == :many_to_many && [join_through: through_alias]) ||
        [through: through_alias]

    args =
      format_args(
        [inspect(assoc.field), assoc.schema] ++
          through ++
          [
            on_replace: assoc.on_replace,
            foreign_key: assoc.foreign_key
          ]
      )

    "#{assoc.assoc_fun} #{args}"
  end

  defp format_args(args) do
    args
    |> Enum.filter(fn
      {_k, "nil"} -> false
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

  def defaults(:many_to_many, option) do
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
