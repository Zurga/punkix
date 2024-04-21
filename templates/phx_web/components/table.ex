defmodule <%= @web_namespace %>.Components.Table do
  @moduledoc """
  A simple HTML table.

  You can create a table by setting a souce `data` to it and defining
  columns using the `Table.Column` component.
  """

  use <%= @web_namespace %>.Component

  @doc "The data that populates the table"
  prop data, :generator, required: true

  @doc "Whether or not the data prop comes from a stream or not"
  prop stream, :boolean

  @doc "The CSS class for the wrapping `<div>` element"
  prop class, :css_class

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
        <tbody phx-update={(@stream && "stream") || ""}>
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
end
