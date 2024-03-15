defmodule <%= @web_namespace %>.Components.Table do
  @moduledoc """
  A simple HTML table.

  You can create a table by setting a souce `data` to it and defining
  columns using the `Table.Column` component.
  """

  use <%= @web_namespace %>.Component

  @doc "The data that populates the table"
  prop data, :generator, required: true

  @doc "The CSS class for the wrapping `<div>` element"
  prop class, :css_class

  @doc """
  A function that returns a class for the item's underlying `<tr>`
  element. The function receives the item and index related to
  the row.
  """
  prop row_class, :fun

  @doc "The columns of the table"
  slot cols, generator_prop: :data, required: true

  def render(assigns) do
    ~F"""
    <div class={@class}>
      <table>
        <thead>
          <tr>
            <th :for={col <- @cols}>
              {col.label}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={item <- @data}
          >
            <td :for={col <- @cols}>
              <span><#slot {col} generator_value={item} /></span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp row_class_fun(nil), do: fn _, _ -> "" end
  defp row_class_fun(row_class), do: row_class
end
