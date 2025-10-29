defmodule Punkix.Web do
  import Phoenix.LiveView, only: [put_flash: 3, push_patch: 2]
  import Phoenix.Component

  defmacro sigil_a(expr, _modifiers) do
    socket = Macro.var(:socket, nil)

    quote bind_quoted: [socket: socket, expr: expr] do
      Map.get(socket.assigns, String.to_existing_atom(expr))
    end
  end

  def extract_date_range_from_params(params) do
    today = Date.utc_today()

    case {params["from"], params["to"]} do
      {nil, nil} -> [Date.new!(today.year, 1, 1), today]
      {from, nil} -> [Date.from_iso8601!(from), today]
      {nil, to} -> [~D[1970-01-01], Date.from_iso8601!(to)]
      {from, to} -> [Date.from_iso8601!(from), Date.from_iso8601!(to)]
    end
    |> then(&apply(Date, :range, &1))
  end

  def put_form_embed(changeset, _, nil, _), do: changeset

  def put_form_embed(changeset, key, attrs, values) do
    checked =
      Enum.reduce(attrs, [], fn
        {id, %{"checked" => "true"}}, acc ->
          id = String.to_integer(id)
          [Enum.find(values, &(&1.id == id)) | acc]

        _, acc ->
          acc
      end)

    changeset
    |> Ecto.Changeset.put_change(key, checked)
  end

  def maybe_patch_and_flash(socket, path, flash) do
    socket
    |> put_flash(:info, flash)
    |> push_patch(to: path)
  end

  def on_create(struct) do
    send(self(), {struct, :inserted})
  end

  def on_update(struct) do
    send(self(), {struct, :updated})
  end

  def resolve_by_id(value, field, haystack, ids) when is_list(ids) do
    Map.put(
      value,
      field,
      Enum.map(ids, fn id ->
        Enum.find(haystack, &(&1.id == id))
      end)
      |> Enum.reject(&is_nil/1)
    )
  end

  def resolve_by_id(value, field, haystack, id) do
    Map.put(value, field, Enum.find(haystack, &(&1.id == id)))
  end

  def find_by_id(%Phoenix.LiveView.Socket{assigns: assigns}, key, ids) do
    with [schema | _] = schemas <- Map.get(assigns, key, []) do
      primary_keys = schema.__struct__.__schema__(:primary_key)

      case primary_keys do
        [key] ->
          for id <- ids do
            Enum.find(schemas, &(Map.get(&1, key) == id))
          end

        keys ->
          for id <- ids do
            Enum.find(schemas, &(Map.filter(&1, Map.keys(keys)) == id))
          end
      end
      |> Enum.reject(&is_nil/1)
    end
  end

  def assoc_select(assigns) do
    assigns = update(assigns, :options, fn options -> 
      Enum.reduce(options, %{}, fn option, acc ->
        {label, struct} = case option do
          {label, struct} -> option
          struct -> {to_string(struct), struct}
        end
        Map.put(acc, struct, {label, assigns.field.name <> "[#{struct}]", maybe_selected(assigns.field, struct)})
      end)
    end)
    ~H"""
    <div :for={{%{id: id} = struct, {label, name, selected}} <- @options} :key={{id, selected}}>
      <label>
        <input type="hidden" name={name} />
        <input type="checkbox" name={name <> "[checked]"} value="true" checked={selected} />
      </label>
    </div>
    """
  end

  # defp assoc_checkboxes(assigns) do
  #   assigns = assign_new(assigns, :name, fn ->@field.name <> "[#{@option}][]" end) 
  #   ~H"""
  #   <.assoc_checkbox name={@name} field={@field} />
  #   """
  # end

  # defp assoc_checkbox(assigns) do
  #   ~H"""
  #   """
  # end
  defp make_value({_label, struct}) when is_struct(struct) do
    struct.id
  end

  defp make_value(struct) when is_struct(struct) do
    struct.id
  end

  defp maybe_selected(%{value: map},  struct) when is_map(map) do
    Enum.reduce_while(map, false, fn
      {id, %{"checked" => "true"}}, acc ->
        if String.to_integer(id) == get_id(struct) do
          {:halt, true}
        else
          {:cont, acc}
        end

      _, acc ->
        {:cont, acc}
    end)
  end

  defp maybe_selected(%{value: list}, struct) when is_list(list) do
    list
    |> Enum.map(&get_id/1)
    |> Enum.find(&(&1 == struct.id))
  end

  defp get_id(%Ecto.Changeset{action: :replace, data: %{id: value_id}}), do: nil
  defp get_id(%Ecto.Changeset{data: %{id: value_id}}), do: value_id
  defp get_id(struct) when is_struct(struct), do: struct.id
  defp get_id(_), do: nil
  defp maybe_selected(_, _), do: false
end
