defmodule Punkix.Components.Utils do
  def swap(list, from, to) when is_binary(from) and is_binary(to) do
    [from, to] = Enum.map([from, to], &String.to_integer/1)
    swap(list, from, to)
  end

  def swap(list, from, to) do
    {e1, list} = List.pop_at(list, from)
    List.insert_at(list, to, e1)
  end

  def find_by_id(enumerable, id) when is_binary(id),
    do: find_by_id(enumerable, String.to_integer(id))

  def find_by_id(enumerable, id) do
    Enum.find(enumerable, &(&1.id == id))
  end

  def insert_by_index(elements, %{index: index} = element) when is_list(elements) do
    List.insert_at(elements, index, element)
  end

  def insert_by_index(elements, element) when is_list(elements) do
    List.insert_at(elements, length(elements), element)
  end

  def insert_by_index(_elements, element), do: element

  def replace_by_index(elements, element) when is_list(elements) do
    index = element_index(elements, element)

    {_element, elements} = List.pop_at(elements, index)
    List.insert_at(elements, index, element)
  end

  def replace_by_index(_elements, element), do: element

  def element_index(elements, element) do
    Map.get_lazy(element, :index, fn ->
      Enum.find_index(elements, &(&1.id == element.id))
    end)
  end

  def delete_by_id(assigns, path, id) do
    assigns =
      assigns
      |> Map.drop([:flash])

    elements = get_in(assigns, path)

    case find_by_id(elements, id) do
      nil ->
        {nil, nil, assigns}

      element ->
        index = element_index(elements, element)

        elements = List.delete_at(elements, index)

        {element, elements, put_in(assigns, path, elements)}
    end
  end
end
