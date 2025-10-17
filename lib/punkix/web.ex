defmodule Punkix.Web do
  import Phoenix.LiveView, only: [put_flash: 3, push_patch: 2]

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

  def on_create(struct) do
    send(self(), {struct, :inserted})
  end

  def on_update(struct) do
    send(self(), {struct, :updated})
  end

  def maybe_patch_and_flash(socket, path, flash) do
    socket
    |> put_flash(:info, flash)
    |> push_patch(to: path)
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
end
