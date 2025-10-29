defmodule Punkix.Live do
  def maybe_insert_current_user(schema) do
    for %{is_current_user: true} = assoc <- schema.assocs do
      "|> Map.put(:#{assoc.field}, ~a|current_user|)"
    end
    |> Enum.join("\n")
  end

  def assocs_as_fields(schema) do
    for assoc <- Punkix.Schema.one_assocs(schema) do
      assoc.key
    end ++
      for assoc <- Punkix.Schema.many_assocs(schema) do
        "#{assoc.plural}"
      end
  end
end
